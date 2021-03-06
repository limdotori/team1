package com.team1.service.user;

import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

import javax.annotation.PostConstruct;
import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.team1.domain.board.HelpFileVO;
import com.team1.domain.board.HelpVO;
import com.team1.domain.board.LifeVO;
import com.team1.domain.board.NewsVO;
import com.team1.domain.board.QuestionVO;
import com.team1.domain.board.UserPostVO;
import com.team1.domain.user.UserFileVO;
import com.team1.domain.user.UserVO;
import com.team1.mapper.user.UserFileMapper;
import com.team1.mapper.user.UserMapper;
import com.team1.service.board.HelpService;
import com.team1.service.board.LifeService;
import com.team1.service.board.NewsService;
import com.team1.service.board.QuestionService;

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
public class UserService {
	
	@Autowired
	private JavaMailSender mailSender;
	
	@Setter(onMethod_ = @Autowired)
	private UserMapper mapper;
	
	@Setter(onMethod_ = @Autowired)
	private UserFileMapper fileMapper;
	
	@Setter(onMethod_ = @Autowired)
	private HelpService helpService;
	
	@Setter(onMethod_ = @Autowired)
	private QuestionService questionService;
	
	@Setter(onMethod_ = @Autowired)
	private LifeService lifeService;
	
	@Setter(onMethod_ = @Autowired)
	private NewsService newsService;
	
	@Value("${aws.accessKeyId}")
	private String accessKeyId;

	@Value("${aws.secretAccessKey}")
	private String secretAccessKey;

	@Value("${aws.bucketName}")
	private String bucketName;
	
	@Value("${aws.staticUrl}")
	private String staticUrl;
	
	private Region region = Region.AP_NORTHEAST_2;
	
	private S3Client s3;
	
	@PostConstruct
	public void init() {
		// spring bean??? ????????? ??? ??? ????????? ???????????? ?????? ??????

		// ?????? ?????? ??????
		AwsBasicCredentials credentials = AwsBasicCredentials.create(accessKeyId, secretAccessKey);

		// crud ????????? s3 client ?????? ??????
		this.s3 = S3Client.builder().credentialsProvider(StaticCredentialsProvider.create(credentials)).region(region)
				.build();
	}

	// s3?????? key??? ???????????? ?????? ??????
	private void deleteObject(String key) {
		DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
				.bucket(bucketName)
				.key(key)
				.build();
		s3.deleteObject(deleteObjectRequest);
	}
	
	// s3?????? key??? ?????? ?????????(put)
	private void putObject(String key, Long size, InputStream source) {
		PutObjectRequest putObjectRequest = PutObjectRequest.builder()
				.bucket(bucketName).key(key).acl(ObjectCannedACL.PUBLIC_READ).build();
		
		
		RequestBody requestBody = RequestBody.fromInputStream(source, size);
		s3.putObject(putObjectRequest, requestBody);
		
	}
	
	public UserVO readByNickName (String nickName) {
		return mapper.selectByNickName(nickName);
	}
	public UserVO readlogin(String email) {
		return mapper.selectlogin(email);
	}
	public UserVO read(String email) {
		return mapper.select(email);
	}

	public UserVO readWithdrwal(String nickname) {
		return mapper.readWithdrwal(nickname);
	}
	
	public UserFileVO getNamesByUserId(Integer id) {
		return fileMapper.selectNamesByUserId(id);
	}
	
	public boolean register(UserVO user) {
		return mapper.insert(user) == 1;
	}
	
	public boolean modify(UserVO user) {
		return mapper.update(user) == 1;
	}
	
	@Transactional
	public void register(UserVO user, MultipartFile file) throws IllegalStateException, IOException {
		
		register(user);
		
		
			UserFileVO fileVO = new UserFileVO();
			
			
			
			if (file != null) {
				// 2.1 ????????? ??????, FILE SYSTEM, s3
				
				fileVO.setUserId(user.getId());
				fileVO.setFileName(file.getOriginalFilename());
				
				String key = "user/profileurl/" + user.getId() + "/" + file.getOriginalFilename();
				putObject(key, file.getSize(), file.getInputStream());
				
				String url = "https://" + bucketName + ".s3." + region.toString() +".amazonaws.com/" +key;
				fileVO.setUrl(url);
				
				// insert into File table, DB
				fileMapper.insert(fileVO);
			} 
		
		
		
	}
	
	@Transactional
	public boolean modify(UserVO user, String removeFile, MultipartFile file)
			throws IllegalStateException, IOException {
		
		modify(user);

		//????????? url ??????
		
			if (file != null) {
				// 1. write file to filesystem, s3
				
				
				UserFileVO userFileVO = new UserFileVO();
			
				String key = "user/profileurl/" + user.getId() + "/" + file.getOriginalFilename();
				putObject(key, file.getSize(), file.getInputStream());
				String url = "https://" + bucketName + ".s3." + region.toString() +".amazonaws.com/" +key;
				
				userFileVO.setFileName(file.getOriginalFilename());
				userFileVO.setUrl(url);
				userFileVO.setUserId(user.getId());
				
				
				fileMapper.insert(userFileVO);
				
			}
			
			if (removeFile != null) {
				
				// file system, s3?????? ??????
				//String key = "user/profileurl/" + user.getId() + "/" + removeFileName;
				String key = removeFile.substring(staticUrl.length());
				
				deleteObject(key);
				// db table?????? ??????
				fileMapper.deleteByUrl(removeFile);
				
			}
		
		return false;
	}
	
	public boolean remove(String email) {
		return mapper.updateRemove(email) == 1;
	}
	 
	public boolean hasNickName(String nickname) {
		UserVO user = mapper.hasByNickName(nickname);
 
		return user != null;
	}
	
	public boolean hasEmail(String email) {
		UserVO user = mapper.hasByEmail(email);
 
		return user != null;
	}
	
	public List<HelpVO> UserBoardHelpList(Integer id) {
		return mapper.selectUserBoardHelp(id);
	}
	
	public List<UserPostVO> getUserPostList(String nickName) {
		
		UserVO userVO = readByNickName(nickName);
		
		List<UserPostVO> postVOs = new ArrayList<UserPostVO>();
		

		try {
			List<HelpVO> helpVOs = helpService.getListByUserId(userVO.getId());
			List<LifeVO> lifeVOs = lifeService.getListByUserId(userVO.getId());
			List<NewsVO> newsVOs = newsService.getListByUserId(userVO.getId());
			List<QuestionVO> questionVOs = questionService.getListByUserId(userVO.getId());

			for(HelpVO helpVO : helpVOs) {
				UserPostVO userPostVO = helpVO.toUserPostVO();
				postVOs.add(userPostVO);
			}
			
			for(LifeVO lifeVO : lifeVOs) {
				UserPostVO userPostVO = lifeVO.toUserPostVO();
				postVOs.add(userPostVO);
			}
			
			for(NewsVO newsVO : newsVOs) {
				UserPostVO userPostVO = newsVO.toUserPostVO();
				postVOs.add(userPostVO);
			}
			
			for(QuestionVO questionVO : questionVOs) {
				UserPostVO userPostVO = questionVO.toUserPostVO();
				postVOs.add(userPostVO);
			}
			
			System.out.println(postVOs);
			
			Comparator<UserPostVO> comparator = (c1, c2) -> { 
				long timeC1 = Date.from(c1.getOriginalInserted().atZone(ZoneId.systemDefault()).toInstant()).getTime();
				long timeC2 = Date.from(c2.getOriginalInserted().atZone(ZoneId.systemDefault()).toInstant()).getTime();

				return Long.valueOf(timeC2).compareTo(timeC1); 
			};
			
			Collections.sort(postVOs, comparator);
			
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}   
		
		return postVOs;
	}
	
	public String sendPassWordFindEmail(String email) throws MessagingException {
		
		UserVO userVO = mapper.select(email);
		
		String result;
		
		if (userVO == null) {
			
			result = "fail";
		}  else {
			
			long time = System.currentTimeMillis(); 
			SimpleDateFormat simpl = new SimpleDateFormat("yyyy??? MM??? dd??? aa hh??? mm??? "); 
			String day = simpl.format(time);

			
	        String subject = "[??????&?????????] ???????????? ?????? ?????? ???????????????.";
	        String content = "???????????????? " +userVO.getNickname()+ " ?????????, ??????&??????????????????.\r\n" + 
	        		day+"??? ???????????? ????????? ???????????? ?????? ????????? ????????? ?????? ?????????????????????.\r\n" + 
	        		"\r\n" + 
	        		userVO.getNickname()+"?????? ??????????????? "+userVO.getPw()+"?????????.\r\n" + 
	        		"\r\n" + 
	        		"???????????? ????????? ??????&????????? ?????? ??????????????????.\r\n" + 
	        		"\r\n" + 
	        		"\r\n" + 
	        		"* ??? ????????? ?????? ?????? ??????????????? ????????? ?????? ??? ?????? ???????????????.\r\n" + 
	        		"* ??? ????????? ???????????? ??? ????????? ????????? ????????? ????????? ???????????????.";
	        
	        
	        String from = "sasa5680@naver.com";
	        String to = email;
			
			
	        System.out.println(content);
	        
			MimeMessage mail = mailSender.createMimeMessage();
	        MimeMessageHelper mailHelper = new MimeMessageHelper(mail,true,"UTF-8");
	        
	        mailHelper.setFrom(from);
	        // ?????? ????????? ????????? ?????? ????????? smtp ????????? ?????? ?????? ?????? ????????? ????????????(setFrom())????????? ??????
	        // ??????????????? ??????????????? ?????????????????? ?????? ?????? ?????? ?????? ??????????????? ????????? ????????? ??????????????? ?????????.
	        //mailHelper.setFrom("???????????? ?????? <???????????? ?????????@???????????????>");
	        mailHelper.setTo(to);
	        mailHelper.setSubject(subject);
	        mailHelper.setText(content, false);
	        
	        mailSender.send(mail);
	        
	        result = "success";
			
		}
		
		return result;
		

	}

	
}
	
