package com.team1.service.board;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.team1.domain.board.PReplyVO;
import com.team1.mapper.board.PReplyMapper;
import lombok.Setter;

@Service
public class PReplyService {
	
	@Setter(onMethod_=@Autowired)
	private PReplyMapper mapper;
	
	public List<PReplyVO> getList() {
		return mapper.getList();
	}
	
	public boolean remove(Integer id) {
		return mapper.delete(id) == 1;
	}
	
	public boolean register(PReplyVO reply) {
		return mapper.insert(reply) == 1;
	}
	
	public boolean modify(PReplyVO reply) {
		return mapper.update(reply) == 1;
	}
	
}