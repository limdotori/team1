<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="b" tagdir="/WEB-INF/tags/"%>
<!DOCTYPE html>

<html>
<head>
<meta charset="EUC-KR">
<title>μΌμμν</title>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css" integrity="sha384-zCbKRCUGaJDkqS1kPbPd7TveP5iyJE0EjAuZQTgFLD2ylzuqKfdKlfG/eSrtxUkn" crossorigin="anonymous">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" integrity="sha512-1ycn6IcaQQ40/MKBW2W4Rhis/DbILU74C1vSrLJxCq57o941Ym01SwNsOMqvEBFlcgUa6xLiPY/NS5R+E6ztJQ==" crossorigin="anonymous" referrerpolicy="no-referrer" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js" integrity="sha512-894YE6QWD5I59HgZOGReFYm4dnWc1Qt5NtvYSaNcOP+u1T9qYdvdihz0PPSiiqn/+/3e7Jo4EaG7TubfWGUrMQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<link href="<%=request.getContextPath()%>/resource/favicon/favicon.png" rel="icon" type="image/x-icon" />

<style>
#help-body-font, #help-body-font2 {
	background-color: #ffe164;
	font-family: 'Jua', sans-serif;
	font-size: 25px;
	margin-top: 10px;
	border-radius: 7px;
}

#list-font {
	font-family: 'IBM Plex Sans KR', sans-serif;
	background-color: #eef2f6;
}

.list-background-color {
	background-color: #eef2f6;
	border: 3px solid #264d73;
	border-radius: 10px;
	border-color: #264d73;
}

#body {
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
	border: solid;
	border-color: #f0615c;
	background-color: white;
	margin-bottom: 5px;
	font-weight: bold;
}

#image {
	width: 80%;
	height: 200px;
	object-fit: cover;
}

/* νμ€νΈκ° νμ€ λμ΄κ°λ©΄ ...μΌλ‘ λλλ€.*/
#contentBox {
	display: inline-block;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	width: 95%;
}

#λ΄μ© {
	padding-left: 154px;
	padding-right: 154px;
}

a {
	width: 100%;
	word-break: break-all;
	display: block;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	text-decoration: none;
	color: inherit;
}

a#title {
	/* border-bottom: solid; */
	font-weight: bold;
	padding-bottom: 5px;
	width: auto;
}

#contentBox {
	border-top-color: #808080;
}

a:hover {
	text-decoration: none;
	color: inherit;
}

.νκ·Ένλλ¦¬ {
	padding-left: 0px;
	padding-right: 0px;
}

.badge {
	
}

.μ λͺ©μλλ³΄λ {
	padding-top: 8px;
	padding-bottom: 3px;
	border-bottom: solid;
	border-bottom-width: 2px;
	border-bottom-color: #264d73;
}

.λλ€μμμΉ {
	padding-bottom: 5px;
    float: right;
    width: 200px;
    text-align: right;
}

#κ²μκΈ-μμ±μκ° {
	font-size: medium;
	text-align: right;
	margin-block: 11px;
	margin-right: 10px
}

.λκΈμμλ° {
	border-top: solid;
	border-top-color: #cccccc;
}

.λκΈμ°½λΆλΆ {
	margin-top: 8px;
	margin-bottom: 8px;
}

.fa-2x {
	font-size: 1.3em;
	margin-left: 5px;
}

.fa-fw {
	width: 1em;
}
</style>
</head>
<body>

	<b:header></b:header>
	<div id="body">
		<div id="inner">
			<b:innerNav></b:innerNav>
			<b:cover></b:cover>
			<c:if test="${not empty sessionScope.loginUser }">
				<a href="${pageContext.request.contextPath }/life/register" id="help-body-font" class="btn">κΈμ°κΈ°</a>
			</c:if>
			<c:if test="${empty sessionScope.loginUser }">
				<a id="help-body-font2" class="btn">κΈμ°κΈ°</a>
			</c:if>
			<!-- κ²μκ²°κ³Ό λ¦¬μ€νΈ -->
			<!-- for λ¬Έ λλ©΄μ listμ μλ μμ(κ²μλ¬Ό)λ€ μΆλ ₯ -->
			<c:forEach items="${list}" var="board" varStatus="vs">
				<c:if test="${location eq board.location || location eq '' || empty location }">
					<div class="container-fluid my-4 list-background-color" id="list-font-${vs.index }" style="display : ${vs.index < 5 ? '' : 'none' }">
						<div class="row md mx-3 my-2 μ λͺ©μλλ³΄λ">
							<div class="col-md-2 my-auto px-auto νκ·Ένλλ¦¬">
								<div id="tag">${board.tag } <br> (${board.location })</div>
							</div>
							<div class="col-md-5 my-auto h5">
								<div class="d-flex justify-content-start">
									<a href="/controller1/life/list/${board.id}" id="title">
										<c:out value="${board.title}" />
									</a>
									<c:if test="${board.newMark <2 }">
										<span class="badge badge-danger" style="margin-left: 5px; line-height: 1; height: 25.5px;">new</span>
									</c:if>
								</div>
							</div>
							<div class="col-md-3 offset-md-2 my-auto h5">
								<div class="λλ€μμμΉ">${board.nickname }</div>
							</div>
						</div>

						<div class="row md px-0 mx-0 my-2">
							<div class="col-md-12 ">
								<div id="line"></div>
							</div>
						</div>

						<!-- μ¬κΈ°κ° μ»¨νμΈ  νν λΆλΆμλλ€. a νκ·Έλ‘ λ΄μ©μ νμν©λλ€. -->
						<div id="contentBox" class="row md px-0 mx-3 h5">
							<a href="/controller1/life/list/${board.id}" id="λ΄μ©">
								<c:out value="${board.content}" />
							</a>
						</div>

						<!-- previewμ μ¬λ¦΄ νμ₯μ μ΄λ―Έμ§, μΈλ€μΌ νμ₯λ§ νμνλ€. -->
						<div class="row md px-0 mx-0 justify-content-center">
							<div class="col-md-8 my-auto mx-0 d-flex justify-content-center">
								<a id="thumbnail" href="/controller1/life/list/${board.id}">

									<!-- postVOκ° κ°μ§ file List μ€ μΈλ€μΌλ‘ μ§μ λ μ΄λ―Έμ§λ§ λμ΄λ€. -->
									<c:if test="${not empty board.fileList }">
										<c:forEach items="${board.fileList }" var="file" varStatus="vs">
											<c:if test="${file.isThumbnail eq 1 }">
												<img src="${file.url}"  style = "width: 600px; height: 300px; object-fit: cover;" alt="${file.url}">

											</c:if>
										</c:forEach>
									</c:if>

								</a>
							</div>
						</div>

						<div class="row my-2">
							<div class="col-md-12 κ²μλ¬Ό-μλ«μ " style="height: 2px; width: 100%">
								<div id="line"></div>
							</div>
						</div>


						<div class="row md mx-3 λκΈμμλ°">
							<div class="col-md-2 λκΈμ°½λΆλΆ">
								<c:if test="${board.upposession !=null}">
									<i class="fa fa-thumbs-up fa-fw fa-1x m-r-3"></i>
								</c:if>
								<c:if test="${empty board.upposession }">
									<i class="far fa-thumbs-up fa-fw fa-1x m-r-3"></i>
								</c:if>
								<span class="fa-2x"> ${board.up} </span>
							</div>
							<div class="col-md-2 λκΈμ°½λΆλΆ">
								<i class="fa fa-comments fa-fw fa-1x m-r-3"></i>
								<span class="fa-2x"> ${board.replyCount } </span>
							</div>
							<div class="col-md-2 λκΈμ°½λΆλΆ">
								<i class="fas fa-eye fa-fw fa-2x m-r-3"></i>
								<span class="fa-2x"> ${board.views } </span>
							</div>
							<div class="col-md-6 ">
								<div id="κ²μκΈ-μμ±μκ°">${board.inserted}</div>
							</div>
						</div>
					</div>
				</c:if>
			</c:forEach>
		</div>
	</div>
	<b:copyright></b:copyright>
	<!-- νκ·Έ -->




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

	<script>
	$(document).ready(function() {
		var tag = "${tag}";
		if(tag==='μΌμ'){
			$("#l_life").attr("class", "btn btn-outline ml-1 active");
		}
		if(tag==='μ·¨λ―Έ'){
			$("#l_hobby").attr("class", "btn btn-outline ml-1 active");
		}
		if(tag==='μνλλΌλ§'){
			$("#l_movdra").attr("class", "btn btn-outline ml-1 active");
		}
		if(tag==='λ°λ €λλ¬Ό'){
			$("#l_pet").attr("class", "btn btn-outline ml-1 active");
		}
		if(tag==='κΈ°ν'){
			$("#l_other").attr("class", "btn btn-outline ml-1 active");
		}
		$("#life").attr("class", "btn btn-outline ml-1 active");
		var count = 5;
		$(window).scroll(function() {
			if ($(window).scrollTop() >= $(document).height()	- $(window).height()) {
				/* alert("λ°μ μ΄"); */
				for (i = 0; i < 5; i++) {
					$("#inner").find("#list-font-" + count).removeAttr("style", "none");
					count++;
				}
			}
		});
	});
	</script>

	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.bundle.min.js" integrity="sha384-fQybjgWLrvvRgtW6bFlB7jaZrFsaBXjsOMm/tB9LTS58ONXgqbR9W8oWht/amnpF" crossorigin="anonymous"></script>
</body>
</html>