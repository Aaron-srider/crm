<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<%--	分页插件--%>
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

<script type="text/javascript">

	$(function(){
		//删除
		$("#remove-delBtn").click(function () {

			//将用户选中的所有线索的id拼串
			var $checkedToDel = $(":input[name=xz]:checked");	//获取用户选中的线索

			var params = "";									//拼串
			for(var i = 0; i < $checkedToDel.length; i++) {
				var id = $($checkedToDel[i]).val();
				params += ("id=" + id);
				if(i < $checkedToDel.length - 1) {
					params += "&";
				}
			}

			//发送请求
			$.post("clueServlet","action=removeClues&" + params,function(data) {
				//data:{success:true/false}
				if(data.success) {
					pageList(1,2);
				} else {
					alert("删除失败");
				}
			}, "json")
		})

		//展示线索列表
		pageList(1, 2);

		//日历框架
		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});

		//打开创建模态窗口
		$("#create-addBtn").click(function (){
			$.post("clueServlet","action=getUserList", function (data) {
				var html = "<option></option>";

				//n是data中的每一个user对象
				$.each(data, function (i, n) {
					html += "<option value = '"+ n.id +"'>"+ n.name +"</option>";
				})
				$("#create-owner").html(html);

				//将下拉框的初始值设置为当前登录的用户
				$("#create-owner").val("${sessionScope.user.id}");

				//打开模态窗口
				$("#createClueModal").modal("show");
			}, "json")
		})

		//创建线索
		$("#create-save").click(function () {
			$.post("clueServlet", {
				"action":"saveClue" ,

				"fullname":$.trim($("#create-fullname").val()),
				"appellation":$.trim($("#create-appellation").val()),
				"owner":$.trim($("#create-owner").val()),
				"company":$.trim($("#create-company").val()),
				"job":$.trim($("#create-job").val()),
				"email":$.trim($("#create-email").val()),
				"phone":$.trim($("#create-phone").val()),
				"website":$.trim($("#create-website").val()),
				"mphone":$.trim($("#create-mphone").val()),
				"state":$.trim($("#create-state").val()),
				"source":$.trim($("#create-source").val()),
				"description":$.trim($("#create-description").val()),
				"contactSummary":$.trim($("#create-contactSummary").val()),
				"nextContactTime":$.trim($("#create-nextContactTime").val()),
				"address":$.trim($("#create-address").val())
			},
			function (data) {
				//data:{"success":true/false}

				//成功关闭模态窗口，并刷新列表
				if(data.success) {
					$("#createClueModal").modal("hide");
					pageList(1, 2);
				}
				//否则打印错误信息
				else {
					alert("添加线索失败");
				}
			}, "json");
		})

		//打开修改窗口
		/**
		 * 需要数据：所有用户列表，选中的线索对象
		 * 后端需要数据：选中的活动id
		 */
		$("#edit-openModal").click(function () {
			var checkes = $(":input[name=xz]:checked");

			if(checkes.length == 0) {
				alert("请选中要修改的线索");
			} else if(checkes.length > 1){
				alert("一次只能修改一个线索");
			} else if(checkes.length == 1) {
				var id = checkes.val();
				$.get("clueServlet", {
					"action":"openEditModal",
					"id":id
				},function (data) {

					//铺用户
					var html = "";
					$.each(data.userList, function (i, n) {
						html += '<option value="'+n.id+'">'+n.name+'</option>';
					})
					$("#edit-clueOwner").html(html);
					$("#edit-clueOwner").val("${sessionScope.user.id}");


					//铺活动
					$("#edit-company").val(data.clue.company);
					$("#edit-fullname").val(data.clue.fullname);
					// $("#edit-appellation").val(data.clue.appellation);
					// $("#edit-status").val(data.clue.status);
					// $("#edit-source").val(data.clue.source);
					$("#edit-job").val(data.clue.job);
					$("#edit-email").val(data.clue.email);
					$("#edit-phone").val(data.clue.phone);
					$("#edit-website").val(data.clue.website);
					$("#edit-mphone").val(data.clue.mphone);
					$("#edit-description").val(data.clue.description);
					$("#edit-contactSummary").val(data.clue.contactSummary);
					$("#edit-nextContactTime").val(data.clue.nextContactTime);
					$("#edit-address").val(data.clue.address);

					//打开模态窗口
					$("#editClueModal").modal("show");
				}, "json")
			}
		})

		//点击更新修改活动
		/**
		 * 前端需要什么数据：是否修改成功的标志
		 * 后端需要什么数据：用户填写的新的线索数据,线索的id
		 */
		$("#edit-updateBtn").click(function() {
			$.get("clueServlet", {
				"action":"editClue",

				"id" : $.trim($(":input[name=xz]:checked").val()),
				"owner" : $.trim($("#edit-clueOwner").val()),
				"company" : $.trim($("#edit-company").val()),
				"fullname" : $.trim($("#edit-fullname").val()),
				"appellation" : $.trim($("#edit-appellation").val()),
				"state" : $.trim($("#edit-state").val()),
				"source" : $.trim($("#edit-source").val()),
				"job" : $.trim($("#edit-job").val()),
				"email" : $.trim($("#edit-email").val()),
				"phone" : $.trim($("#edit-phone").val()),
				"website" : $.trim($("#edit-website").val()),
				"mphone" : $.trim($("#edit-mphone").val()),
				"description" : $.trim($("#edit-description").val()),
				"contactSummary" : $.trim($("#edit-contactSummary").val()),
				"nextContactTime" : $.trim($("#edit-nextContactTime").val()),
				"address" : $.trim($("#edit-address").val()),

			}, function (data) {
				if(data.success) {
					$("#editActivityModal").modal("hide");
					pageList(1,2);
				} else {
					alert("修改失败");
				}
			},"json")
		})

		$("#searchBtn").click(function () {
			$("#hidden-fullname").val($("#search-fullname").val())
			$("#hidden-company").val($("#search-company").val())
			$("#hidden-phone").val($("#search-phone").val())
			$("#hidden-source").val($("#search-source").val())
			$("#hidden-ownerName").val($("#search-ownerName").val())
			$("#hidden-mphone").val($("#search-mphone").val())
			$("#hidden-state").val($("#search-state").val())

			pageList(1, 2);
		})
	});

	function pageList(pageNo,pageSize) {
		$.get("clueServlet", {
			"action":"page",
			//发送页码，每页大小
			"pageNo":pageNo,
			"pageSize":pageSize,

			//以下参数来自查询框，可有可无
			"fullname":$("#hidden-fullname").val(),
			"company":$("#hidden-company").val(),
			"phone":$("#hidden-phone").val(),
			"source":$("#hidden-source").val(),
			"owner":$("#hidden-ownerName").val(),
			"mphone":$("#hidden-mphone").val(),
			"state":$("#hidden-state").val()
		},function (data) {
			//来自服务器：data:{totalCount:总记录数 ,totalPages：总页数， list:[{clue1}{clue2}{clue3}]}
			//将数据展示在页面上
			var html = "";
			$.each(data.list, function (i,n) {
				//n是clue对象
				html += '<tr class="active">';
				html += '<td> <input type="checkbox" name="xz" value="'+n.id+'"/> </td>';
				html += '<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href=\'clueServlet?action=showDetail&id=' +n.id+ ' \';\">' +n.fullname+ '</a></td>';
				html += '<td>'+n.company+'</td>';
				html += '<td>'+n.phone+'</td>';
				html += '<td>'+n.mphone+'</td>';
				html += '<td>'+n.source+'</td>';
				html += '<td>'+n.owner+'</td>';
				html += '<td>'+n.state+'</td>';
				html += '</tr>';
			});
			$("#clueBody").html(html);

			//前端分页插件
			$("#activityPage").bs_pagination({
				currentPage: pageNo, // 页码
				rowsPerPage: pageSize, // 每页显示的记录条数
				maxRowsPerPage: 20, // 每页最多显示的记录条数
				totalPages: data.totalPages, // 总页数
				totalRows: data.totalCount, // 总记录条数

				visiblePageLinks: 3, // 显示几个卡片

				showGoToPage: true,
				showRowsPerPage: true,
				showRowsInfo: true,
				showRowsDefaultInfo: true,

				//选择分页的时候会触发该函数
				onChangePage : function(event, data){
					pageList(data.currentPage , data.rowsPerPage);
				}
			});
		}, "json")

	}


	//展示线索列表
	function showClueList() {

		$.get("clueServlet", {
			"action":"showClueList",

			//以下参数来自查询框，可有可无
			"fullname":$("#search-fullname").val(),
			"company":$("#search-company").val(),
			"phone":$("#search-phone").val(),
			"source":$("#search-source").val(),
			"ownerName":$("#search-ownerName").val(),
			"mphone":$("#search-mphone").val(),
			"state":$("#search-state").val()
		},function (data) {
			//data[{clue1}{clue1}{clue1}]

			var html = "";
			$.each(data, function (i,n) {
				//n是clue对象
				html += '<tr class="active">';
				html += '<td> <input type="checkbox" name="xz" value="'+n.id+'"/> </td>';
				html += '<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href=\'clueServlet?action=showDetail&id=' +n.id+ ' \';\">' +n.fullname+ '</a></td>';
				html += '<td>'+n.company+'</td>';
				html += '<td>'+n.phone+'</td>';
				html += '<td>'+n.mphone+'</td>';
				html += '<td>'+n.source+'</td>';
				html += '<td>'+n.owner+'</td>';
				html += '<td>'+n.state+'</td>';
				html += '</tr>';
			});
			$("#clueBody").html(html);


		}, "json")
	}
	
</script>
</head>
<body>

<%--解决查询bug--%>
<input type="hidden" id="hidden-fullname">
<input type="hidden" id="hidden-company">
<input type="hidden" id="hidden-phone">
<input type="hidden" id="hidden-source">
<input type="hidden" id="hidden-ownerName">
<input type="hidden" id="hidden-mphone">
<input type="hidden" id="hidden-state">

	<!-- 创建线索的模态窗口 -->
	<div class="modal fade" id="createClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">创建线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-clueOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								</select>
							</div>
							<label for="create-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
<%--									直接从服务器缓存中获取数据字典中的值--%>
<%--									appellation代表缓存中的一个字典类型对应的字典值的list--%>
								  <c:forEach items="${applicationScope.appellation}" var="a">
									  <option value="${a.value}">${a.text}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="create-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
							<label for="create-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
							<label for="create-status" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-state">
								  <option></option>
									<c:forEach items="${applicationScope.clueState}" var="c">
										<option value="${c.value}">${c.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
								  <option></option>
									<c:forEach items="${applicationScope.source}" var="s">
										<option value="${s.value}">${s.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						

						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">线索描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time" id="create-nextContactTime">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>
						
						<div style="position: relative;top: 20px;">
							<div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
							</div>
						</div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="create-save">保存</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">

						<div class="form-group">
							<label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-clueOwner">
									<%--								  <option>zhangsan</option>--%>
									<%--								  <option>lisi</option>--%>
									<%--								  <option>wangwu</option>--%>
								</select>
							</div>
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company" value="动力节点">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
									<option></option>
									<c:forEach items="${applicationScope.appellation}" var="appellation">
										<option value="${appellation.value}">${appellation.text}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname" value="李四">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" value="CTO">
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" value="010-84846003">
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" value="12345678901">
							</div>
							<label for="edit-status" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-state">
									<option></option>
									<c:forEach items="${applicationScope.stage}" var="stage">
										<option value="${stage.value}">${stage.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>

						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
									<option></option>
									<c:forEach items="${applicationScope.source}" var="source">
										<option value="${source.value}">${source.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>

						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>

						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary">这个线索即将被转换</textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control" id="edit-nextContactTime" value="2017-05-01">
								</div>
							</div>
						</div>

						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

						<div style="position: relative;top: 20px;">
							<div class="form-group">
								<label for="edit-address" class="col-sm-2 control-label">详细地址</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="1" id="edit-address">北京大兴区大族企业湾</textarea>
								</div>
							</div>
						</div>
					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal" id="edit-updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>线索列表</h3>
			</div>
		</div>
	</div>


<%--查询线索--%>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

					<div class="form-group">
						<div class="input-group">
							<div class="input-group-addon">名称</div>
							<input class="form-control" type="text" id="search-fullname">
						</div>
					</div>

					<div class="form-group">
						<div class="input-group">
							<div class="input-group-addon">公司</div>
							<input class="form-control" type="text" id="search-company">
						</div>
					</div>

					<div class="form-group">
						<div class="input-group">
							<div class="input-group-addon" id="search-phone">公司座机</div>
							<input class="form-control" type="text" >
						</div>
					</div>

					<div class="form-group">
						<div class="input-group">
							<div class="input-group-addon">线索来源</div>
							<select class="form-control" id="search-source">
								<option></option>
								<c:forEach items="${applicationScope.source}" var="source">
									<option value="${source.value}">${source.text}</option>
								</c:forEach>
							</select>
						</div>
					</div>

					<br>

					<div class="form-group">
						<div class="input-group">
							<div class="input-group-addon">所有者</div>
							<input class="form-control" type="text" id="search-ownerName">
						</div>
					</div>



					<div class="form-group">
						<div class="input-group">
							<div class="input-group-addon">手机</div>
							<input class="form-control" type="text" id="search-mphone">
						</div>
					</div>

					<div class="form-group">
						<div class="input-group">
							<div class="input-group-addon">线索状态</div>
							<select class="form-control" id="search-state">
								<option></option>
								<c:forEach items="${applicationScope.stage}" var="stage">
									<option value="${stage.value}">${stage.text}</option>
								</c:forEach>
							</select>
						</div>
					</div>

					<button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" data-toggle="modal" id="create-addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" data-toggle="modal" id="edit-openModal"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="remove-delBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>


			</div>
			<div style="position: relative;top: 50px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" /></td>
							<td>名称</td>
							<td>公司</td>
							<td>公司座机</td>
							<td>手机</td>
							<td>线索来源</td>
							<td>所有者</td>
							<td>线索状态</td>
						</tr>
					</thead>
					<tbody id="clueBody">
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 60px;">
				<div id="activityPage"></div>
			</div>
		</div>
		
	</div>
</body>
</html>