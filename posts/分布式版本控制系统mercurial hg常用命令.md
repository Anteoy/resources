---
id: 90
date: 2018-07-11 17:33:00
title: 分布式版本控制系统mercurial hg常用命令
categories:
    - ops
tags:
    - hg mercurial
---

### mercurial
mercurial是一种轻量级分布式版本控制系统，采用 Python 语言实现，易于学习和使用，扩展性强。其是基于 GNU General Public License (GPL) 授权的开源项目。由于目前工作需要使用mercurial，这里记录下自己使用到的常用命令，作为参照，不定时更新。

### 常用命令
1. 配置好类似git的ssh，使用hg clone ssh://code@xx.com/yy 克隆xx.com的yy项目
2. hg status => git status
3. hg branch => git branch
4. hg commit -m 'xxx' => git add . & git commit -m 'xxx'
5. hg pull => git pull
6. hg update => git fetch --all
7. hg merge another_branch => git merge another_branch   
8. 解决冲突可以利用IDE的mercurial，merge的时候遇到冲突直接在vim模式下使用:cq直接退出，然后点击IDE中version control => local changes => 右键红色冲突的文件选择解决冲突即可进行处理
9. hg update -C => git reset --head =>丢弃当前对文件做的所有修改
10. hg push -b dev-r2 => 推送本地dev-r2分支到远程版本仓库
11. hg diff => git diff

### 附录
1. [http://www.worldhello.net/gotgit/90-app/040-hg-git-face2face.html](http://www.worldhello.net/gotgit/90-app/040-hg-git-face2face.html)
2. [http://www.worldhello.net/gotgit/90-app/040-hg-git-face2face.html](http://www.worldhello.net/gotgit/90-app/040-hg-git-face2face.html)