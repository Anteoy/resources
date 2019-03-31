<!DOCTYPE html>
<html>
	<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<meta name="description" content="{{"meta.description"|get}}"/>
	<meta name="keywords" content="{{"meta.keywords"|get}}"/>
	<meta name="author" content="{{"meta.author"|get}}"/>
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>
	<link rel="stylesheet" href="/prettify/normalize.css"/>
	<link rel="stylesheet" href="/prettify/prettify_{{"codetheme"|get}}.css"/>
	<link rel="stylesheet" href="/css/main.css"/>
	<link rel="shortcut icon" href="/favicon.ico"/>
	<script type="text/javascript" src="/prettify/prettify.js"></script>
	<title>{{get "meta.view"}}的博客-{{get "meta.site"}}</title>
	</head>
	<body onload="prettyPrint()">

        <div class="top-nav">
            <ul>
                <li><a href="/" >Index</li>
                <li><a href="/blog_1.html" >Blog</a></li>
                <li><a href="/archive.html">Date</a></li>
                <li><a href="/classify.html">Classify</a></li>
                <li><a href="/pages/about.html">About</a></li>
                <li><a href="/pnotelogin.html" >Pnote</a></li>
         15       {{range .nav}}
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
        <div style="clear:both;"></div>
        <div class="main">
        	<div class="main-inner">
        		 <div id="article-content"> {{.fi.Content|unescaped}} </div>
        		<hr/>
        	</div>
        </div>
        </div>
        <script type="text/javascript" src="/js/jquery.js"></script>

        <div id="footer">
            <div id="footer-inner" style="bottom: 0;position: fixed;right: 0;left: 0;">
                <p id="copyright">Copyright (c) {{"copyright.beginYear" | get}} - {{"copyright.endYear" | get}} {{"copyright.owner"|get}} &nbsp;
                Powered by <a href="https://github.com/Anteoy/liongo">liongo</a>
                </p>
            </div>
        </div>
    </body>
</html>
