{{template "header"}}
<title>{{get "meta.view"}}的博客-{{get "meta.site"}}</title>
</head>
<div class="top-nav">
			<ul>
                <li><a href="/" >Index</li>
                <li><a href="/blog_1.html" >Blog</a></li>
                <li><a href="/archive.html">Date</a></li>
				<li><a href="/classify.html" class="on-sel" class="on-sel">Classify</a></li>
                <li><a href="/pages/about.html" >About</a></li>
                <li><a href="/pnotelogin.html" >Pnote</a></li>
                {{range .nav}}
                <li><a href="{{.Href}}" target="{{.Target}}">{{.Name}}</a></li>
                {{end}}
                <div><a href="javascript:void(0);" style="float: right;font-size: 16px;">{{get "meta.view"}}的博客</a></div>
            </ul>
</div>
<div style="clear:both;height:50px" id="interval"></div><!-- 中间间隔 -->
<div class="main">
	<div class="main-inner" style="margin-left: 15%;margin-right: 15%;">
		<div id="tags-main">
			{{range $k,$v := .cats}}
        	<a href="/classify.html#{{$k}}">{{$k}}</a>
       		{{end}}
		 	<div style="clear:both;"></div>
		 </div>
        <div id="tag-index">
            {{range $k,$v := .cats}}
                <h1><a name="{{$k}}">{{$k}}</a></h1>
                {{range $v.Articles}}
                <p><a href="/articles/{{.Link}}">{{.Title}}</a></p>
                {{end}}
            {{end}}
        </div>
    </div>
</div>
{{template "footer"}}