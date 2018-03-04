---
id: 78
date: 2016-10-25 21:21:37
title: [转]maven pom.xml 主要标签说明
categories:
    - 转载
tags:
    - maven
---
Maven 构件工程的属性文件

本文转载自：https://my.oschina.net/u/1187481/blog/204865 

自己再增加了一些东西，以供学习查阅之用，不对之处，欢迎大家不吝赐教

pom.xml文件（实践用）：

<project xmlns="http://maven.apache.org/POM/4.0.0"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
   <modelVersion>4.0.0</modelVersion>
   <!-- groupId: groupId:项目或者组织的唯一标志，并且配置时生成的路径也是由此生成，
       如com.mycompany.app生成的相对路径为：/com/mycompany/app -->
   <groupId>asia.banseon</groupId>
   <!-- artifactId: 项目的通用名称 -->
   <artifactId>banseon-maven2</artifactId>
   <!-- packaging: 打包的机制，如pom, jar, maven-plugin, ejb, war, ear, rar, par   -->
   <packaging>jar</packaging>
   <!-- version:项目的版本 -->
   <version>1.0-SNAPSHOT</version>
   <!-- 项目的名称， Maven 产生的文档用 -->
   <name>banseon-maven</name>
   <!-- 哪个网站可以找到这个项目,提示如果 Maven 资源列表没有，可以直接上该网站寻找, Maven 产生的文档用 -->
   <url>http://www.baidu.com/banseon</url>
   <!-- 项目的描述, Maven 产生的文档用 -->
   <description>A maven project to study maven.</description>
   <!-- 开发者信息 -->
   <developers>
       <developer>
           <id>HELLO WORLD</id>
           <name>banseon</name>
           <email>banseon@126.com</email>
           <roles>
               <role>Project Manager</role>
               <role>Architect</role>
           </roles>
           <organization>demo</organization>
           <organizationUrl>http://hi.baidu.com/banseon</organizationUrl>
           <properties>
               <dept>No</dept>
           </properties>
           <timezone>-5</timezone>
       </developer>
   </developers>
   <!-- 类似 developers -->
   <contributors></contributors>
   <!-- 本项目相关 mail list, 用于订阅等信息 -->
   <mailingLists>
       <mailingList>
           <name>Demo</name>
           <!-- Link mail -->
           <post>banseon@126.com</post>
           <!-- mail for subscribe the project -->
           <subscribe>banseon@126.com</subscribe>
           <!-- mail for unsubscribe the project -->
           <unsubscribe>banseon@126.com</unsubscribe>
           <archive>
           http:/hi.baidu.com/banseon/demo/dev/
           </archive>
       </mailingList>
   </mailingLists>
   <!-- 项目的问题管理系统(Bugzilla, Jira, Scarab,或任何你喜欢的问题管理系统)的名称和URL，本例为 jira -->
   <issueManagement>
       <system>jira</system>
       <url>http://jira.baidu.com/banseon</url>
   </issueManagement>
   <!-- organization information -->
   <organization>
       <name>demo</name>
       <url>http://www.baidu.com/banseon</url>
   </organization>
   <!-- License -->
   <licenses>
       <license>
           <name>Apache 2</name>
           <url>http://www.baidu.com/banseon/LICENSE-2.0.txt</url>
           <distribution>repo</distribution>
           <comments>A business-friendly OSS license</comments>
       </license>
   </licenses>
   <!-- 
       - scm(software configuration management)标签允许你配置你的代码库，为Maven web站点和其它插件使用。
       - 如果你正在使用CVS或Subversion，source repository页面同样能给如何使用代码库的详细的、工具相关的指令。
       - 下面是一个典型SCM的配置例子
   -->
   <scm>
       <!-- 项目在 svn 上对应的资源 -->
       <connection>
           scm:svn:http://svn.baidu.com/banseon/maven/banseon/banseon-maven2-trunk(dao-trunk)
       </connection>
       <developerConnection>
           scm:svn:http://svn.baidu.com/banseon/maven/banseon/dao-trunk
       </developerConnection>
       <url>http://svn.baidu.com/banseon</url>
   </scm>
   <!-- 用于配置分发管理，配置相应的产品发布信息,主要用于发布，在执行mvn deploy后表示要发布的位置 -->
   <distributionManagement>
       <!-- 配置到文件系统 -->
       <repository>
           <id>banseon-maven2</id>
           <name>banseon maven2</name>
           <url>file://${basedir}/target/deploy</url>
       </repository>
       <!-- 使用ssh2配置 -->
       <snapshotRepository>
           <id>banseon-maven2</id>
           <name>Banseon-maven2 Snapshot Repository</name>
           <url>scp://svn.baidu.com/banseon:/usr/local/maven-snapshot</url>
       </snapshotRepository>
       <!-- 使用ssh2配置 -->
       <site>
           <id>banseon-site</id>
           <name>business api website</name>
           <url>
               scp://svn.baidu.com/banseon:/var/www/localhost/banseon-web
           </url>
       </site>
   </distributionManagement>
   <!-- 依赖关系 -->
   <dependencies>
       <dependency>
           <groupId>junit</groupId>
           <artifactId>junit</artifactId>
           <version>3.8.1</version>
           <!-- scope 说明
               - compile ：默认范围，用于编译 
               - provided：类似于编译，但支持你期待jdk或者容器提供，类似于classpath 
               - runtime: 在执行时，需要使用 
               - test:    用于test任务时使用 
               - system: 需要外在提供相应得元素。通过systemPath来取得 
               - systemPath: 仅用于范围为system。提供相应的路径 
               - optional:   标注可选，当项目自身也是依赖时。用于连续依赖时使用
           -->
           <scope>test</scope>
           <!-- 
               - systemPath: 仅用于范围为system。提供相应的路径 
               - optional: 标注可选，当项目自身也是依赖时。用于连续依赖时使用 
           -->
           <!-- 
               <type>jar</type>
               <optional>true</optional>
           -->
       </dependency>

       <!-- 
           - 外在告诉maven你只包括指定的项目，不包括相关的依赖。此因素主要用于解决版本冲突问题
           - 如下依赖表示 项目acegi-security依赖 org.springframework.XXX 项目，但我们不需要引用这些项目
       -->
       <dependency>
           <groupId>org.acegisecurity</groupId>
           <artifactId>acegi-security</artifactId>
           <version>1.0.5</version>
           <scope>runtime</scope>
           <exclusions>
               <exclusion>
                   <artifactId>spring-core</artifactId>
                   <groupId>org.springframework</groupId>
               </exclusion>
               <exclusion>
                   <artifactId>spring-support</artifactId>
                   <groupId>org.springframework</groupId>
               </exclusion>
               <exclusion>
                   <artifactId>commons-logging</artifactId>
                   <groupId>commons-logging</groupId>
               </exclusion>
               <exclusion>
                   <artifactId>spring-jdbc</artifactId>
                   <groupId>org.springframework</groupId>
               </exclusion>
               <exclusion>
                   <artifactId>spring-remoting</artifactId>
                   <groupId>org.springframework</groupId>
               </exclusion>
           </exclusions>
       </dependency>
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring</artifactId>
           <version>2.5.1</version>
           <scope>runtime</scope>
       </dependency>
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring-web</artifactId>
           <version>2.5.1</version>
           <scope>runtime</scope>
       </dependency>
       <dependency>
           <groupId>postgresql</groupId>
           <artifactId>postgresql</artifactId>
           <version>8.2-504.jdbc4</version>
           <scope>runtime</scope>
       </dependency>
       <dependency>
           <groupId>com.oracle</groupId>
           <artifactId>ojdbc6</artifactId>
           <version>11.1.0.6</version>
           <scope>runtime</scope>
       </dependency>
   </dependencies>
   <!-- 
       - maven proxy, 本地仓库，替代 maven.apache.org 网站 jar 列表，用户下载时，首先寻找该站点
       - 如资源找到，则下载。否则才去 jar 列表网站。对多人团队，可节省下载速度和个人存储空间。
   -->
   <repositories>
       <repository>
           <id>banseon-repository-proxy</id>
           <name>banseon-repository-proxy</name>
           <url>http://192.168.1.169:9999/repository/</url>
           <layout>default</layout>
       </repository>
   </repositories>



（）


什么是pom?
   pom作为项目对象模型。通过xml表示maven项目，使用pom.xml来实现。主要描述了项目：包括配置文件；开发者需要遵循的规则，缺陷管理系统，组织和licenses，项目的url，项目的依赖性，以及其他所有的项目相关因素。
快速察看：

xml 代码

<project>
< modelVersion>4.0.0modelVersion>

< groupId>...<groupId>
< artifactId>...<artifactId>
< version>...<version>
< packaging>...<packaging>
< dependencies>...<dependencies>
< parent>...<parent>
< dependencyManagement>...<dependencyManagement>
< modules>...<modules>
< properties>...<properties>

< build>...<build>
< reporting>...<reporting>

< name>...<name>
< description>...<description>
< url>...<url>
< inceptionYear>...<inceptionYear>
< licenses>...<licenses>
< organization>...<organization>
< developers>...<developers>
< contributors>...<contributors>

< issueManagement>...<issueManagement>
< ciManagement>...<ciManagement>
< mailingLists>...<mailingLists>
< scm>...<scm>
< prerequisites>...<prerequisites>
< repositories>...<repositories>
< pluginRepositories>...<pluginRepositories>
< distributionManagement>...<distributionManagement>
< profiles>...<profiles>
< project>

基本内容：
POM包括了所有的项目信息。
maven 相关：
pom定义了最小的maven2元素，允许groupId,artifactId,version。所有需要的元素

groupId:项目或者组织的唯一标志，并且配置时生成的路径也是由此生成，如org.codehaus.mojo生成的相对路径为：/org/codehaus/mojo
artifactId: 项目的通用名称
version:项目的版本
packaging: 打包的机制，如pom, jar, maven-plugin, ejb, war, ear, rar, par
classifier: 分类


POM关系：
主要为依赖，继承，合成

依赖关系：
xml 代码
<dependencies>
   <dependency>
     <groupId>junit<groupId>
     <artifactId>junit<artifactId>
     <version>4.0<version>
     <type>ja<rtype>
     <scope>test<scope>
     <optional>true<optional>
   <dependency>
   ...
< dependencies>


groupId, artifactId, version:描述了依赖的项目唯一标志
可以通过以下方式进行安装：

使用以下的命令安装：
mvn install:install-file –Dfile=non-maven-proj.jar –DgroupId=some.group –DartifactId=non-maven-proj –Dversion=1
创建自己的库,并配置，使用deploy:deploy-file
设置此依赖范围为system，定义一个系统路径。不提倡。
type:相应的依赖产品包形式，如jar，war
scope:用于限制相应的依赖范围，包括以下的几种变量：
compile ：默认范围，用于编译
provided：类似于编译，但支持你期待jdk或者容器提供，类似于classpath
runtime:在执行时，需要使用
test:用于test任务时使用
system:需要外在提供相应得元素。通过systemPath来取得
systemPath: 仅用于范围为system。提供相应的路径
optional: 标注可选，当项目自身也是依赖时。用于连续依赖时使用

独占性
外在告诉maven你只包括指定的项目，不包括相关的依赖。此因素主要用于解决版本冲突问题

xml 代码

<dependencies>
   <dependency>
     <groupId>org.apache.maven<groupId>
     <artifactId>maven-embedder<artifactId>
     <version>2.0<version>
     <exclusions>
       <exclusion>
         <groupId>org.apache.maven<groupId>
         <artifactId>maven-core<artifactId>
       <exclusion>
     <exclusions>
   <dependency>
< dependencies>

表示项目maven-embedder需要项目maven-core，但我们不想引用maven-core

继承关系
另一个强大的变化,maven带来的是项目继承。主要的设置：
定义父项目

xml 代码

<project>
< modelVersion>4.0.0<modelVersion>
< groupId>org.codehaus.mojo<groupId>
< artifactId>my-parent<artifactId>
< version>2.0version>
< packaging>pom<packaging>
< project>

packaging 类型，需要pom用于parent和合成多个项目。我们需要增加相应的值给父pom，用于子项目继承。主要的元素如下：

依赖型
开发者和合作者
插件列表
报表列表
插件执行使用相应的匹配ids
插件配置
子项目配置
xml 代码

<project>
< modelVersion>4.0.0<modelVersion>
< parent>
   <groupId>org.codehaus.mojo<groupId>
   <artifactId>my-parent<artifactId>
   <version>2.0<version>
   <relativePath>../my-parent<relativePath>
< parent>
< artifactId>my-project<artifactId>
< project>

relativePath可以不需要，但是用于指明parent的目录，用于快速查询。

dependencyManagement：
用于父项目配置共同的依赖关系，主要配置依赖包相同因素，如版本，scope。

合成（或者多个模块）
   一个项目有多个模块，也叫做多重模块，或者合成项目。
如下的定义：

xml 代码

<project>
< modelVersion>4.0.0<modelVersion>
< groupId>org.codehaus.mojo<groupId>
< artifactId>my-parent<artifactId>
< version>2.0<version>
< modules>
   <module>my-project1<module>
   <module>my-project2<module>
< modules>
< project>


build 设置
   主要用于编译设置，包括两个主要的元素，build和report
build
   主要分为两部分，基本元素和扩展元素集合
注意：包括项目build和profile build

xml 代码

<project>

<build>...<build>
< profiles>
   <profile>

     <build>...<build>
   <profile>
< profiles>
< project>


基本元素

xml 代码

<build>
< defaultGoal>install<defaultGoal>
< directory>${basedir}/targetdirectory>
< finalName>${artifactId}-${version}finalName>
< filters>
   <filter>filters/filter1.properties<filter>
< filters>
...
< build>


defaultGoal: 定义默认的目标或者阶段。如install
directory: 编译输出的目录
finalName: 生成最后的文件的样式
filter: 定义过滤，用于替换相应的属性文件，使用maven定义的属性。设置所有placehold的值

资源(resources)
   你项目中需要指定的资源。如spring配置文件,log4j.properties

xml 代码

<project>
< build>
   ...
   <resources>
     <resource>
       <targetPath>META-INF/plexus<targetPath>
       <filtering>falsefiltering>
       <directory>${basedir}/src/main/plexus<directory>
       <includes>
         <include>configuration.xml<include>
       <includes>
       <excludes>
         <exclude>**/*.properties<exclude>
       <excludes>
     <resource>
   <resources>
   <testResources>
     ...
   <testResources>
   ...
< build>
< project>


resources: resource的列表，用于包括所有的资源
targetPath: 指定目标路径，用于放置资源，用于build
filtering: 是否替换资源中的属性placehold
directory: 资源所在的位置
includes: 样式，包括那些资源
excludes: 排除的资源
testResources: 测试资源列表

插件
在build时，执行的插件，比较有用的部分，如使用jdk 5.0编译等等

xml 代码

<project>
< build>
   ...
   <plugins>
     <plugin>
       <groupId>org.apache.maven.plugins<groupId>
       <artifactId>maven-jar-plugin<artifactId>
       <version>2.0<version>
       <extensions>false<extensions>
       <inherited>true<inherited>
       <configuration>
         <classifier>test<classifier>
       <configuration>
       <dependencies>...<dependencies>
       <executions>...<executions>
     <plugin>
   <plugins>
< build>
< project>


extensions: true or false，是否装载插件扩展。默认false
inherited: true or false，是否此插件配置将会应用于poms，那些继承于此的项目
configuration: 指定插件配置
dependencies: 插件需要依赖的包
executions: 用于配置execution目标，一个插件可以有多个目标。
如下：

xml 代码

<plugin>
       <artifactId>maven-antrun-plugin<artifactId>

       <executions>
         <execution>
           <id>echodirid>
           <goals>
             <goal>run<goal>
           <phase>verify<phase>
           <inherited>false<inherited>
           <configuration>
             <tasks>
               <echo>Build Dir: ${project.build.directory}<echo>
             <tasks>
           <configuration>
         <execution>
       <executions>
    <plugin>

说明：

id:规定execution 的唯一标志
goals: 表示目标
phase: 表示阶段，目标将会在什么阶段执行
inherited: 和上面的元素一样，设置false maven将会拒绝执行继承给子插件
configuration: 表示此执行的配置属性

插件管理
   pluginManagement：插件管理以同样的方式包括插件元素，用于在特定的项目中配置。所有继承于此项目的子项目都能使用。主要定义插件的共同元素

扩展元素集合
主要包括以下的元素：
Directories
用于设置各种目录结构，如下：

xml 代码

<build>
   <sourceDirectory>${basedir}/src/main/java<sourceDirectory>
   <scriptSourceDirectory>${basedir}/src/main/scripts<scriptSourceDirectory>
   <testSourceDirectory>${basedir}/src/test/java<testSourceDirectory>
   <outputDirectory>${basedir}/target/classes<outputDirectory>
   <testOutputDirectory>${basedir}/target/test-classes<testOutputDirectory>
   ...
< build>


Extensions

表示需要扩展的插件，必须包括进相应的build路径。


xml 代码

<project>
< build>
   ...
   <extensions>
     <extension>
       <groupId>org.apache.maven.wagon<groupId>
       <artifactId>wagon-ftp<artifactId>
       <version>1.0-alpha-3<version>
     <extension>
   <extensions>
   ...
< build>
< project>


Reporting
   用于在site阶段输出报表。特定的maven 插件能输出相应的定制和配置报表。

xml 代码

<reporting>
   <plugins>
     <plugin>
       <outputDirectory>${basedir}/target/siteoutputDirectory>
       <artifactId>maven-project-info-reports-pluginartifactId>
       <reportSets>
         <reportSet>reportSet>
       reportSets>
     plugin>
   plugins>
reporting>


Report Sets
   用于配置不同的目标，应用于不同的报表

xml 代码

<reporting>
   <plugins>
     <plugin>
       ...
       <reportSets>
         <reportSet>
           <id>sunlinkid>
           <reports>
             <report>javadoc<report>
           <inherited>truei<nherited>
           <configuration>
             <links>
               <link>http://java.sun.com/j2se/1.5.0/docs/api/<link>
           <configuration>
         <reportSet>
       <reportSets>
     <plugin>
   <plugins>
< reporting>

name:项目除了artifactId外，可以定义多个名称
description: 项目描述
url: 项目url
inceptionYear:创始年份
Licenses

xml 代码

<licenses>
< license>
   <name>Apache 2name>
   <url>http://www.apache.org/licenses/LICENSE-2.0.txt<url>
   <distribution>repodistribution>
   <comments>A business-friendly OSS license<comments>
< license>
< licenses>


Organization
配置组织信息

xml 代码

<organization>
   <name>Codehaus Mojoname>
   <url>http://mojo.codehaus.org<url>
organization>

Developers
配置开发者信息

xml 代码

<developers>
   <developer>
     <id>eric<id>
     <name>Eric<name>
     <email>eredmond@codehaus.org<email>
     <url>http://eric.propellors.net<url>
     <organization>Codehausorganization>
     <organizationUrl>http://mojo.codehaus.orgorganization<Url>
     <roles>
       <role>architect<role>
       <role>developer<role>
     <roles>
     <timezone>-6timezone>
     <properties>
       <picUrl>http://tinyurl.com/prv4tpic<Url>
     <properties>
   <developer>
< developers>

Contributors

xml 代码

<contributors>
  <contributor>
    <name>Noelle<name>
    <email>some.name@gmail.com<email>
    <url>http://noellemarie.com<url>
    <organization>Noelle Marie<organization>
    <organizationUrl>http://noellemarie.com<organizationUrl>
    <roles>
      <role>tester<role>
    <roles>
    <timezone>-5<timezone>
    <properties>
      <gtalk>some.name@gmail.com<gtalk>
    <properties>
  <contributor>
< contributors>

环境设置

Issue Management
   定义相关的bug跟踪系统，如bugzilla,testtrack,clearQuest等

xml 代码

<issueManagement>
   <system>Bugzilla<system>
   <url>http://127.0.0.1/bugzillau<rl>
< issueManagement>

Continuous Integration Management
连续整合管理，基于triggers或者timings

xml 代码

<ciManagement>
  <system>continuum<system>
  <url>http://127.0.0.1:8080/continuum<url>
  <notifiers>
    <notifier>
      <type>mail<type>
      <sendOnError>true<sendOnError>
      <sendOnFailure>true<sendOnFailure>
      <sendOnSuccess>false<sendOnSuccess>
      <sendOnWarning>false<sendOnWarning>
      <configuration><address>continuum@127.0.0.1<address><configuration>
    <notifier>
  <notifiers>
< ciManagement>

Mailing Lists

xml 代码

<mailingLists>
  <mailingList>
    <name>User List<name>
    <subscribe>user-subscribe@127.0.0.1<subscribe>
    <unsubscribe>user-unsubscribe@127.0.0.1un<subscribe>
    <post>user@127.0.0.1<post>
    <archive>http://127.0.0.1/user/<archive>
    <otherArchives>
      <otherArchive>http://base.google.com/base/1/127.0.0.1<otherArchive>
    <otherArchives>
  <mailingList>
< mailingLists>


SCM
软件配置管理，如cvs 和svn

xml 代码

<scm>
   <connection>scm:svn:http://127.0.0.1/svn/my-project<connection>
   <developerConnection>scm:svn:https://127.0.0.1/svn/my-project<developerConnection>
   <tag>HEAD<tag>
   <url>http://127.0.0.1/websvn/my-project<url>
< scm>

Repositories

配置同setting.xml中的开发库

Plugin Repositories
配置同 repositories

Distribution Management
用于配置分发管理，配置相应的产品发布信息,主要用于发布，在执行mvn deploy后表示要发布的位置
1 配置到文件系统

xml 代码

<distributionManagement>
< repository>
< id>proficio-repository<id>
< name>Proficio Repository<name>
< url>file://${basedir}/target/deploy<url>
< repository>
< distributionManagement>

2 使用ssh2配置

xml 代码

<distributionManagement>
< repository>
< id>proficio-repository<id>
< name>Proficio Repository<name>
< url>scp://sshserver.yourcompany.com/deploy<url>
< repository>
< distributionManagement>

3 使用sftp配置

xml 代码

<distributionManagement>
< repository>
< id>proficio-repositoryi<d>
< name>Proficio Repository<name>
< url>sftp://ftpserver.yourcompany.com/deploy<url>
< repository>
< distributionManagement>

4 使用外在的ssh配置
   编译扩展用于指定使用wagon外在ssh提供，用于提供你的文件到相应的远程服务器。

xml 代码

<distributionManagement>
< repository>
< id>proficio-repository<id>
< name>Proficio Repository<name>
< url>scpexe://sshserver.yourcompany.com/deploy<url>
< repository>
< distributionManagement>
< build>
< extensions>
< extension>
< groupId>org.apache.maven.wagon<groupId>
< artifactId>wagon-ssh-external<artifactId>
< version>1.0-alpha-6<version>
< extension>
< extensions>
< build>


5 使用ftp配置

xml 代码

<distributionManagement>
< repository>
< id>proficio-repository<id>
< name>Proficio Repository<name>
< url>ftp://ftpserver.yourcompany.com/deploy<url>
< repository>
< distributionManagement>
< build>
< extensions>
< extension>
< groupId>org.apache.maven.wagongroupId>
< artifactId>wagon-ftpartifactId>
< version>1.0-alpha-6version>
< extension>
< extensions>
< build>


repository 对应于你的开发库，用户信息通过settings.xml中的server取得

Profiles
类似于settings.xml中的profiles，增加了几个元素，如下的样式：

xml 代码

<profiles>
   <profile>
     <id>test<id>
     <activation>...<activation>
     <build>...<build>
     <modules>...<modules>
     <repositories>...<repositories>
     <pluginRepositories>...<pluginRepositories>
     <dependencies>...<dependencies>
     <reporting>...r<eporting>
     <dependencyManagement>...<dependencyManagement>
     <distributionManagement>...<distributionManagement>
   <profile>
< profiles>

<properties>  
        <!-- 文件拷贝时的编码 固定编码 防止在不同编译环境 比如不同的IDE或者shell环境下编译产生未知的问题-->  
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>  
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>  
        <!-- 编译时的编码 -->  
        <maven.compiler.encoding>UTF-8</maven.compiler.encoding>  
    </properties>
<!-- jar包编译-->
<build>
<plugins>
<plugin>
<artifactId>maven-assembly-plugin</artifactId>
<configuration>
<archive>
<manifest>
<mainClass></mainClass>
</manifest>
</archive>
<descriptorRefs>
<descriptorRef>jar-with-dependencies</descriptorRef>
</descriptorRefs>
</configuration>
</plugin>
</plugins>
</build>

