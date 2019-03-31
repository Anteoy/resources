{{template "header"}}
<title>{{get "meta.view"}}的博客-{{get "meta.site"}}</title>
</head>
<!-- <link href="/css/bootstrap.min.css" rel="stylesheet"> -->
<div class="top-nav">
			<ul>
                <li><a href="/" >Index</li>
                <li><a href="/blog_1.html" >Blog</a></li>
                <li><a href="/archive.html">Date</a></li>
				<li><a href="/classify.html" >Classify</a></li>
                <li><a href="/pages/about.html" >About</a></li>
                <li><a href="/pnotelogin.html" class="on-sel">Pnote</a></li>
                {{range .nav}}
                <li><a href="{{.Href}}" target="{{.Target}}">{{.Name}}</a></li>
                {{end}}
                <li class="search" style="margin-top: 7.5;line-height: 2.8">
                    <form target="_blank" method=get action="http://www.allocmem.com/search">
                    <input type=text value="kubernetes" name=search style="color: #ffffff;background-color: #404142;border-style: none;">
                    <input type=submit name=btnG value="Search" style="background-color: #1d1f21;color: #999999;border-style: none;">
                    <input type=hidden name=ie value=GB2312>
                    <input type=hidden name=oe value=GB2312>
                    <input type=hidden name=hl value=zh-CN>
                    <input type=hidden name=domains value="www.allocmem.com">
                    <input type=hidden name=sitesearch value="www.allocmem.com">
                    </form>
                </li>
                <div><a href="javascript:void(0);" style="float: right;font-size: 16px;">{{get "meta.view"}}的博客</a></div>
            </ul>
</div>
<div style="clear:both;height:50px" id="interval"></div><!-- 中间间隔 -->
<div class="main" style="color: white;text-align:center">
	<div class="main-container loginBox" style="position: absolute;z-index: 999;width: 100%;height: 100%;">
    		<div class="loginContent">
    			<span class="firstLogin">admin or guest 账户登录</span>
    			<div style="margin-top: 30px">
    				 <input type="text" placeholder="用户名" id="username" class="loginUser loginUserbg1">
    			</div>
    			<div style="margin-top: 30px;">
    				<input type="password" placeholder="密码" id="password" class="loginUser loginUserbg2">
    			</div>
    			<div style="margin-top: 30px;">
    				<input type="checkbox"  class="loginRember" style="vertical-align: top"> <span class="loginRemberWord">记住密码</span>
    			</div>
    			<div style="margin-top: 30px;" class="loginBtn fl" id="commit"  onclick="checkLogin()">
    				登&nbsp录
    			</div>
    		</div>
    </div>
</div>
<script type="text/javascript">
	var c = document.getElementById("c");
	var ctx = c.getContext("2d");
	c.width = window.innerWidth;
	c.height = window.innerHeight;
	//	c.width=window.screen.availWidth;
	//	c.height=window.screen.availHeight;
	console.log(c.height)
	//				ctx.fillRect(0,0,100,100);
	//				a,b,c,d分别代表x方向偏移,y方向偏移,宽，高
	var string1 = "1203456gzg987";
	string1.split("");
	var fontsize = 20;
	columns = c.width / fontsize;
	var drop = [];
	for (var x = 0; x < columns; x++) {
		drop[x] = 0;
	}
	function drap() {
		ctx.fillStyle = "rgba(0,0,0,0.07)";
		//			ctx.fillStyle="rgba(236, 97, 16,0.67)";
		ctx.fillRect(0, 0, c.width, c.height);
		ctx.fillStyle = "#0F0";
		//		ctx.fillStyle="#EC6110";
		ctx.font = fontsize + "px arial";
		for (var i = 0; i < drop.length; i++) {
			var text1 = string1[Math.floor(Math.random() * string1.length)];
			ctx.fillText(text1, i * fontsize, drop[i] * fontsize);
			drop[i]++;
			if (drop[i] * fontsize > c.height && Math.random() > 0.9) {//90%的几率掉落
				drop[i] = 0;
			}
		}
	}
	setInterval(drap, 20);
	$(document).ready(function() {
		if ($.cookie("rmbUser") == "true") {
			$("#ck_rmbUser").prop("checked", true);
			$("#username").val($.cookie("username"));
			//$("#password").remove();
			//$("#pass").append("<input id='password' type='password' class='txt2'/>");
			$("#password").val($.cookie("password"));
			//checkLogin();
		}
		$("input").keydown(function() {
			if (event.keyCode == 13) {
				checkLogin();
			}
		})
	});
	function check() {
		var username = $("#username").val();
		var password = $("#password").val();
		if (username == "" || username == "请输入用户名") {
			alert("请输入用户名!");
			$("#username").focus();
			return false;
		}
		if (password == "" || password == "请输入密码") {
			alert("请输入密码!");
			$("#password").focus();
			return false;
		}
		$("#tip").text("");
		return true;
	}
	function checkLogin() {
		//if(check())
		var username = $("#username").val();
		var password = $("#password").val();
		window.location="login?id="+username+"&passwd="+password;
		/*$.ajax({
			url : 'login',
			data : {
				id : username,
				passwd : password
			},
			dataType : 'json',
			method : 'POST',
			success : function(data) {
				var json = eval(data);
				var result = json.info;
				if (result == '0') {
					//window.location="charts.html?userLoginName="+username;
					if(typeof (json.url) != "undefined") {
						window.location = json.url;
					} else {
						alert("用户没有分配权限，请联系管理员！！！");
					}
				} else {
					alert(result);
				}
			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
				//alert('查询数据错误,详细信息：[' + errorThrown + ']');
			}
		});*/
	}
	function reset(){
	$("#username").val("");
	$("#password").val("");
	}
</script>
<script type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/js/common.js"></script>
{{template "footer"}}