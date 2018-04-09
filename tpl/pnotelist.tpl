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