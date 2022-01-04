<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="b" tagdir="/WEB-INF/tags/"%>
<!DOCTYPE html>

<html>
<head>
<meta charset="EUC-KR">
<title>해주세요</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
<link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css" integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js" integrity="sha512-894YE6QWD5I59HgZOGReFYm4dnWc1Qt5NtvYSaNcOP+u1T9qYdvdihz0PPSiiqn/+/3e7Jo4EaG7TubfWGUrMQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>

<style>
#body {
	height: 150vh;
	/* height: calc(100vh-72px); */
	width: 100%;
	justify-content: center;
	display: flex;
}

#inner {
	width: 900px;
	height: 100%;
}

#postBody {
	width: 100%;
	border-radius: 10px;
	margin-top: 5px;
}

#tag {
	font-size: 1.0rem;
	text-align: center;
	justify-content: center;
	border-radius: 5px;
	width: 80%;
}

#line {
	height: 2px;
	width: 100%;
}

#image {
	width: 80%;
	height: 200px;
	object-fit: cover;
}

/* 텍스트가 한줄 넘어가면 ...으로 끊는다.*/
#contentBox {
	display: inline-block;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

a {
	text-decoration: none;
	color: inherit;
}

a:hover {
	text-decoration: none;
	color: inherit;
}
</style>
</head>
<body>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous">
		
	</script>

	<b:header></b:header>
	<div id="body">
		<div id="inner">
			<b:innerNav></b:innerNav>
			<b:cover></b:cover>
			<a href="${pageContext.request.contextPath }/help/register">글쓰기</a>
			<!-- 검색결과 리스트 -->
			<!-- for 문 돌면서 list에 있는 요소(게시물)들 출력 -->
			<c:forEach items="${list}" var="board">
				<div class="container-fluid my-1 border border-3 border-secondary">
					<div class="row md mx-3 my-2">
						<div class="col-md-2 my-auto px-auto">
							<div id="tag">${board.tag }</div>
						</div>
						<div class="col-md-6 my-auto h5">
							<div>
								<a href="/controller1/help/list/${board.id}"><c:out value="${board.title}"/> </a>
							</div>
						</div>
						<div class="col-md-2 offset-md-2 my-auto h5">
							<div>${board.inserted}</div>
						</div>

						<div class="row md px-0 mx-0 my-2">
							<div class="col-md-12 ">
								<div id="line"></div>
							</div>
						</div>
						<div id="contentBox" class="row md px-0 mx-3 h5">
							<a href="/controller1/help/list/${board.id}"><c:out value="${board.content}"/></a>
						</div>

						<!-- preview에 올릴 한장의 이미지 -->
						<div class="row md px-0 mx-0 justify-content-center">
							<div class="col-md-8 my-auto mx-0 d-flex justify-content-center">
								<a id="thumbnail" href="/controller1/help/list/${board.id}"> 

								<c:if test="${not empty fileNames }">
									<c:forEach items="${fileNames }" var="fileName" varStatus="vs">
										<c:if test="${fileName.postId eq board.id }">
											<img src="${staticUrl }help-board/${board.id }/${fileName.fileName }" class="d-block w-100" alt="${fileName.fileName }">
										</c:if>
									</c:forEach>
								</c:if>

								</a>
							</div>
						</div>
						<div class="row md px-0 mx-0 my-2">
							<div class="col-md-12 ">
								<div id="line"></div>
							</div>
						</div>

						<div class="row md mx-4">
							<div class="col-md-2">
								<c:if test="${board.upposession !=null}">
								<i class="fa fa-thumbs-up fa-fw fa-3x m-r-3"></i>
								</c:if>
								<c:if test="${empty board.upposession }">
								<i class="far fa-thumbs-up fa-fw fa-3x m-r-3"></i>
								</c:if>
								${board.up}
							</div>
							<div class="col-md-2">
								<i class="fa fa-comments fa-fw fa-2x m-r-3"></i>
								${board.replyCount }
							</div>
							<div class="col-md-2">
								<i class="fas fa-eye fa-fw fa-3x m-r-3"></i>
								${board.views }
							</div>
						</div>
					</div>
				</div>
			</c:forEach>
			<!-- 태그 -->

		</div>
	</div>

	<!-- Result Modal -->
	<c:if test="${not empty result }">
		<div class="modal" tabindex="-1" id="modal1">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title">Process Result</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>
					<div class="modal-body">
						<p>${result }</p>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>
	</c:if>

	<!-- 	<script>
	$(document).ready(function(){
		/*context path*/
		const appRoot = '${pageContext.request.contextPath}';
		/* 현재 게시물의 댓글 목록 불러오는 함수*/
		const listThumbs = function() {
			$("#thumbnail").empty();
			$.ajax({
				url : appRoot + "/help/list/thumb",
				success : function (thumbs) {
					console.log(url);
					for (let i = 0; i<thumbs.length; i++){
						const thumbMediaObject = $(`
							<c:forEach items="${thumbs }" var="fileName" varStatus="vs">
								<c:if test="${fileName.boardId eq board.id }">
									<div class="carousel-item-active">
										<img src="${staticUrl }/${board.id }/${fileName.fileName }" class="d-block w-100" alt="${fileName.fileName }">
									</div>
								</c:if>
							</c:forEach>
						`);
						}
					}
				})
			}
		listThumbs(); // 페이지 로딩 후 댓글 리스트 가져오는 함수 한 번 실행
		});
</script> -->
	<!-- <script>
	$(document).ready(function(){
		$(".carousel-item").attr("class", "active");
	});
</script> -->
</body>
</html>