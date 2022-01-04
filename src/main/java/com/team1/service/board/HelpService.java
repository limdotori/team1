package com.team1.service.board;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.team1.domain.board.HelpFileVO;
import com.team1.domain.board.HelpVO;
import com.team1.mapper.board.HelpFileMapper;
import com.team1.mapper.board.HelpMapper;
import com.team1.mapper.board.HelpReplyMapper;
import com.team1.mapper.board.HelpUpMapper;

import lombok.Setter;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.ObjectCannedACL;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

@Service
public class HelpService {
	@Setter(onMethod_ = @Autowired)
	private HelpMapper mapper;

	@Setter(onMethod_ = @Autowired)
	private HelpReplyMapper helpReplyMapper;

	@Setter(onMethod_ = @Autowired)
	private HelpFileMapper fileMapper;
	
	@Setter(onMethod_ = @Autowired)
	private HelpUpMapper upMapper;

	@Value("${aws.accessKeyId}")
	private String accessKeyId;

	@Value("${aws.secretAccessKey}")
	private String secretAccessKey;

	@Value("${aws.bucketName}")
	private String bucketName;

	private Region region = Region.AP_NORTHEAST_2;
	private S3Client s3;
	
	@PostConstruct
	public void init() {
		// spring bean이 만들어 진 후 최초로 실행되는 코드 작성

		// 권한 정보 객체
		AwsBasicCredentials credentials = AwsBasicCredentials.create(accessKeyId, secretAccessKey);

		// crud 가능한 s3 client 객체 생성
		this.s3 = S3Client.builder().credentialsProvider(StaticCredentialsProvider.create(credentials)).region(region)
				.build();
	}

	// s3에서 key에 해당하는 객체 삭제
	private void deleteObject(String key) {
		DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
				.bucket(bucketName)
				.key(key)
				.build();
		s3.deleteObject(deleteObjectRequest);
	}
	
	// s3에서 key로 객체 업로드(put)
	private void putObject(String key, Long size, InputStream source) {
		PutObjectRequest putObjectRequest = PutObjectRequest.builder().bucket(bucketName).key(key).acl(ObjectCannedACL.PUBLIC_READ).build();
		RequestBody requestBody = RequestBody.fromInputStream(source, size);
		s3.putObject(putObjectRequest, requestBody);
	}

	@Transactional
	public void register(HelpVO board, MultipartFile[] files) throws IllegalStateException, IOException {
		register(board);
		// 2. s3에 파일 업로드
		for (MultipartFile file : files) {
			if (file != null && file.getSize() > 0) {
				// 2.1 파일을 작성, FILE SYSTEM, s3
				String key = "board/help-board/" + board.getId() + "/" + file.getOriginalFilename();
				putObject(key, file.getSize(), file.getInputStream());
				// insert into File table, DB
				fileMapper.insert(board.getId(), file.getOriginalFilename());
			}
		}
	}

	public String[] getNamesByBoardId(Integer id) {
		return fileMapper.selectNamesByBoardId(id);
	}

	@Transactional
	public boolean modify(HelpVO board, String[] removeFile, MultipartFile[] files)
			throws IllegalStateException, IOException {
		modify(board);
		// write files
		// 파일 삭제
		if (removeFile != null) {
			for (String removeFileName : removeFile) {
				// file system, s3에서 삭제
				String key = "board/help-board/" + board.getId() + "/" + removeFileName;
				deleteObject(key);
				// db table에서 삭제
				fileMapper.delete(board.getId(), removeFileName);
			}
		}

		for (MultipartFile file : files) {
			if (file != null && file.getSize() > 0) {
				// 1. write file to filesystem, s3
				String key = "board/help-board/" + board.getId() + "/" + file.getOriginalFilename();
				putObject(key, file.getSize(), file.getInputStream());
				// 2. db 파일명 insert
				fileMapper.delete(board.getId(), file.getOriginalFilename());
				fileMapper.insert(board.getId(), file.getOriginalFilename());
			}
		}
		return false;
	}

	public List<HelpVO> getList(Integer id) {
		return mapper.getList(id);
	}

	public HelpVO get(Integer id, Integer loginId) {
		return mapper.read(id, loginId);
	}

	public boolean register(HelpVO board) {
		return mapper.insert(board) == 1;
	}

	public boolean modify(HelpVO board) {
		return mapper.update(board) == 1;
	}

	@Transactional
	public boolean remove(Integer id) {

		// 1. 게시물에 달린 댓글 지우기
		helpReplyMapper.deleteByBoardId(id);

		// 2. 파일 지우기 , s3
		// file system에서 삭제
		String[] files = fileMapper.selectNamesByBoardId(id);
		if (files != null) {
			for (String file : files) {
				String key = "board/help-board/" + id + "/" + file;
				deleteObject(key);
			}
		}
		// db에서 삭제
		fileMapper.deleteByBoardId(id);
		// 3. 게시물 지우기
		return mapper.delete(id) == 1;
	}

	public boolean upViews(Integer id) {
		return mapper.upViews(id) == 1;
	}

//	public boolean upUps(Integer id) {
//		return mapper.upUps(id) == 1;
//	}

	public List<HelpVO> getListSearchByContent(String search) {
//			, Integer page, Integer numberPerPage, Integer numberPerPagination) { 검색 결과도 페이지 네이션 구현한다면 필요한 변수 (전에 아직 구현 못함)
//		return mapper.getListSearchByTitle(search, from, numberPerPage, numberPerPagination);
		return mapper.getListSearchByContent(search);
	}

	public List<HelpFileVO> getFiles() {
		return mapper.getFiles();
	}

	public List<HelpFileVO> getFilesById(Integer id) {
		return  mapper.getFilesById(id);
	}

}
