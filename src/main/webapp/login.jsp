<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String base = request.getScheme()
+ "://"
+ request.getServerName()
+ ":"
+ request.getServerPort()
+ request.getContextPath()
+ "/";
%>


<!DOCTYPE html>
<html>
<head>
	<base href="<%=base%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript">


		$(function () {

			//将当前窗口置为顶层窗口
			if(window.top!=window) {
				window.top.location=window.location;
			}


			$("#loginAct").focus();


			//回车登录
			$(window).keydown(function (event) {
				if(event.keyCode==13) {
					login()
				}
			})

			$("#submitBtn").click(function () {
				login()
			})
		})

		function login() {
			var username = $.trim($("#loginAct").val());
			var password = $.trim($("#loginPwd").val());

			if(username=="" || password=="") {
				$("#msg").html("账号密码不能为空");
				return false;
			}

			$.post("userServlet",
					{
						"action":"login" ,
						"username":username,
						"password":password
					}, function (data) {
						//登录成功就跳转
						if(data.success) {
							window.location.href="workbench/index.jsp";
						}
						//否则打印错误信息
						else {
							$("#msg").html(data.msg);
						}
					}, "json");
		}

	</script>
</head>

<body>

	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2017&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form id="loginForm" action="workbench/index.jsp" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" type="text" placeholder="用户名" id="loginAct">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" type="password" placeholder="密码" id="loginPwd">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						
							<span id="msg"></span>
						
					</div>
					<%--不能使用submit类型，如果这样的话放在form里面就相当于submit标签--%>
					<button id = "submitBtn" type="button" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>