{{template "header"}}
<title>{{get "meta.view"}}的博客-{{get "meta.site"}}</title>
</head>
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
<div style="clear:both;" id="interval"></div>
<div class="main">
	<div class="main-inner">
	    <button onclick="commitPnote()">newPNote</button>
        <div id="tag-index">
        {{range .archives}}
        	<h1>{{.Year}}</h1>
			{{range .Months}}
				<h2>{{.Month}}</h2>
				{{range .NotesBase}}
           			<p><a href="javascript:void(0)" onclick=goNote({{.Link}})>{{.Title}}</a></p>
           		{{end}}
            {{end}}
       	{{end}}
        </div>
		</div>
</div>
<script>
	function goNote(link){
		window.open("/notes?link="+link)
	}
	function commitPnote(){
	    window.open("/protohtml/commit.html")
	}
</script>
{{template "footer"}}