{{template "header"}}
<title>{{get "meta.view"}}的博客-{{get "meta.site"}}</title>
</head>
<div class="top-nav">
	<ul>
	    <li><a href="/" >Index</li>
		<li><a href="/blog_1.html">Blog</a></li>
		<li><a href="/archive.html">Date</a></li>
		<li><a href="/classify.html">Classify</a></li>
		<li><a href="/pages/about.html" class="on-sel">About</a></li>
		<li><a href="/pnotelogin.html" >Pnote</a></li>
		{{range .nav}}
		    <li><a href="{{.Href}}" target="{{.Target}}" >{{.Name}}</a></li>
		{{end}}
		<li class="search" style="margin-top: 7.5;">
            <form target="_blank" method=get action="http://www.google.com/search">
            <input type=text value="kubernetes" name=q style="color: #ffffff;background-color: #404142;border-style: none;">
            <input type=submit name=btnG value="Search" style="background-color: #1d1f21;color: #999999;border-style: none;">
            <input type=hidden name=ie value=GB2312>
            <input type=hidden name=oe value=GB2312>
            <input type=hidden name=hl value=zh-CN>
            <input type=hidden name=domains value="anteoy.site">
            <input type=hidden name=sitesearch value="anteoy.site">
            </form>
        </li>
		<div><a href="javascript:void(0);" style="float: right;font-size: 16px;">{{get "meta.view"}}的博客</a></div>
	</ul>
</div>
<div style="clear:both;"></div>
<div class="main">
	<div class="main-inner">
		 <h1>{{.p.Title}}</h1>
		 <div id="page-content">{{.p.Content|unescaped}}</div>
	</div>
</div>
{{template "footer"}}