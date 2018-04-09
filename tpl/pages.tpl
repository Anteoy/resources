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