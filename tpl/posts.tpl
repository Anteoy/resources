{{template "header"}}
<div class="top-nav">
			<ul>
			    <li><a href="/" >Index</li>
				<li><a href="/blog_1.html" >Blog</a></li>
				<li><a href="/archive.html">Date</a></li>
				<li><a href="/classify.html">Classify</a></li>
				<li><a href="/pages/about.html">About</a></li>
				<li><a href="/pnotelogin.html" >Pnote</a></li>
				{{range .Nav}}
				<li><a href="{{.Href}}" target="{{.Target}}">{{.Name}}</a></li>
				{{end}}
			</ul>
</div>
<div style="clear:both;height:50px" id="interval"></div><!-- 中间间隔 -->
<div class="main">
	<div class="main-inner">
		 <div id="article-title">
		 	<a href="/{{.fi.Link}}">{{.fi.Title}}</a>
		 </div>
		 <div id="article-meta">Author {{.fi.Author}}  | Posted {{.fi.Date}} </div>

		  <div id="article-tags">
		  {{range .Tags}}
		  <a class="tag" href="/tag.html#{{.Name}}">
		  {{.Name}}</a> 
		  {{end}}
		  </div>
		 <div id="article-content"> {{.fi.Content|unescaped}} </div>
		<hr/>
		<div id="container"></div>
        <link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
        <script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
        <script>
        var gitment = new Gitment({
          owner: 'Anteoy',
          repo: 'gitment-store',
          oauth: {
            client_id: 'ef421f31d2f578120bb5',
            client_secret: '5ab49416ee33dca55485d006f5300f1e7dbfe7d9',
          },
        })
        gitment.render('container')
        </script>
	</div>
</div>

</div>

<script type="text/javascript" src="/js/jquery.js"></script>

{{template "footer"}}