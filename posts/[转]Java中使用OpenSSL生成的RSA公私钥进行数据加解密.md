---
id: 72
date: 2017-02-16 16:37:42
title: [转]Java中使用OpenSSL生成的RSA公私钥进行数据加解密
categories:
    - 转载
tags:
    - Java OpenSSL RSA
---
本文出处：http://blog.csdn.net/chaijunkun/article/details/7275632，转载请注明。由于本人不定期会整理相关博文，会对相应内容作出完善。因此强烈建议在原始出处查看此文。

RSA是什么：RSA公钥加密算法是1977年由Ron Rivest、Adi Shamirh和LenAdleman在（美国麻省理工学院）开发的。RSA取名来自开发他们三者的名字。RSA是目前最有影响力的公钥加密算法，它能够抵抗到目前为止已知的所有密码攻击，已被ISO推荐为公钥数据加密标准。目前该加密方式广泛用于网上银行、数字签名等场合。RSA算法基于一个十分简单的数论事实：将两个大素数相乘十分容易，但那时想要对其乘积进行因式分解却极其困难，因此可以将乘积公开作为加密密钥。
OpenSSL是什么：众多的密码算法、公钥基础设施标准以及SSL协议，或许这些有趣的功能会让你产生实现所有这些算法和标准的想法。果真如此，在对你表示敬佩的同时，还是忍不住提醒你：这是一个令人望而生畏的过程。这个工作不再是简单的读懂几本密码学专著和协议文档那么简单，而是要理解所有这些算法、标准和协议文档的每一个细节，并用你可能很熟悉的C语言字符一个一个去实现这些定义和过程。我们不知道你将需要多少时间来完成这项有趣而可怕的工作，但肯定不是一年两年的问题。OpenSSL就是由Eric A. Young和Tim J. Hudson两位绝世大好人自1995年就开始编写的集合众多安全算法的算法集合。通过命令或者开发库，我们可以轻松实现标准的公开算法应用。

我的一个假设应用背景：
随着移动互联网的普及，为移动设备开发的应用也层出不穷。这些应用往往伴随着用户注册与密码验证的功能。”网络传输“、”应用程序日志访问“中的安全性都存在着隐患。密码作为用户的敏感数据，特别需要开发者在应用上线之前做好安全防范。处理不当，可能会造成诸如商业竞争对手的恶意攻击、第三方合作商的诉讼等问题。

RSA算法虽然有这么多好处，但是在网上找不到一个完整的例子来说明如何操作。下面我就来介绍一下：
一、使用OpenSSL来生成私钥和公钥
我使用的是Linux系统，已经安装了OpenSSL软件包，此时请验证你的机器上已经安装了OpenSSL，运行命令应当出现如下信息：
[plain] view plain copy 在CODE上查看代码片派生到我的代码片
[root@chaijunkun ~]# openssl version -a  
OpenSSL 1.0.0-fips 29 Mar 2010  
built on: Wed Jan 25 02:17:15 GMT 2012  
platform: linux-x86_64  
options:  bn(64,64) md2(int) rc4(16x,int) des(idx,cisc,16,int) blowfish(idx)   
compiler: gcc -fPIC -DOPENSSL_PIC -DZLIB -DOPENSSL_THREADS -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -DKRB5_MIT -m64 -DL_ENDIAN -DTERMIO -Wall -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic -Wa,--noexecstack -DMD32_REG_T=int -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DMD5_ASM -DAES_ASM -DWHIRLPOOL_ASM  
OPENSSLDIR: "/etc/pki/tls"  
engines:  aesni dynamic   
先来生成私钥：
[plain] view plain copy 在CODE上查看代码片派生到我的代码片
[root@chaijunkun ~]# openssl genrsa -out rsa_private_key.pem 1024  
Generating RSA private key, 1024 bit long modulus  
.......................++++++  
..++++++  
e is 65537 (0x10001)  
这条命令让openssl随机生成了一份私钥，加密长度是1024位。加密长度是指理论上最大允许”被加密的信息“长度的限制，也就是明文的长度限制。随着这个参数的增大（比方说2048），允许的明文长度也会增加，但同时也会造成计算复杂度的极速增长。一般推荐的长度就是1024位（128字节）。
我们来看一下私钥的内容：
[plain] view plain copy 在CODE上查看代码片派生到我的代码片
[root@chaijunkun ~]# cat rsa_private_key.pem   
-----BEGIN RSA PRIVATE KEY-----  
MIICWwIBAAKBgQChDzcjw/rWgFwnxunbKp7/4e8w/UmXx2jk6qEEn69t6N2R1i/L  
mcyDT1xr/T2AHGOiXNQ5V8W4iCaaeNawi7aJaRhtVx1uOH/2U378fscEESEG8XDq  
ll0GCfB1/TjKI2aitVSzXOtRs8kYgGU78f7VmDNgXIlk3gdhnzh+uoEQywIDAQAB  
AoGAaeKk76CSsp7k90mwyWP18GhLZru+vEhfT9BpV67cGLg1owFbntFYQSPVsTFm  
U2lWn5HD/IcV+EGaj4fOLXdM43Kt4wyznoABSZCKKxs6uRciu8nQaFNUy4xVeOfX  
PHU2TE7vi4LDkw9df1fya+DScSLnaDAUN3OHB5jqGL+Ls5ECQQDUfuxXN3uqGYKk  
znrKj0j6pY27HRfROMeHgxbjnnApCQ71SzjqAM77R3wIlKfh935OIV0aQC4jQRB4  
iHYSLl9lAkEAwgh4jxxXeIAufMsgjOi3qpJqGvumKX0W96McpCwV3Fsew7W1/msi  
suTkJp5BBvjFvFwfMAHYlJdP7W+nEBWkbwJAYbz/eB5NAzA4pxVR5VmCd8cuKaJ4  
EgPLwsjI/mkhrb484xZ2VyuICIwYwNmfXpA3yDgQWsKqdgy3Rrl9lV8/AQJAcjLi  
IfigUr++nJxA8C4Xy0CZSoBJ76k710wdE1MPGr5WgQF1t+P+bCPjVAdYZm4Mkyv0  
/yBXBD16QVixjvnt6QJABli6Zx9GYRWnu6AKpDAHd8QjWOnnNfNLQHue4WepEvkm  
CysG+IBs2GgsXNtrzLWJLFx7VHmpqNTTC8yNmX1KFw==  
-----END RSA PRIVATE KEY-----  
内容都是标准的ASCII字符，开头一行和结尾一行有明显的标记，真正的私钥数据是中间的不规则字符。
2015年3月24日补充：密钥文件最终将数据通过Base64编码进行存储。可以看到上述密钥文件内容每一行的长度都很规律。这是由于RFC2045中规定：The encoded output stream must be represented in lines of no more than 76 characters each。也就是说Base64编码的数据每行最多不超过76字符，对于超长数据需要按行分割。
接下来根据私钥生成公钥：
[plain] view plain copy 在CODE上查看代码片派生到我的代码片
[root@chaijunkun ~]# openssl rsa -in rsa_private_key.pem -out rsa_public_key.pem -pubout  
writing RSA key  
再来看一下公钥的内容：
[plain] view plain copy 在CODE上查看代码片派生到我的代码片
[root@chaijunkun ~]# cat rsa_public_ley.pem   
-----BEGIN PUBLIC KEY-----  
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQChDzcjw/rWgFwnxunbKp7/4e8w  
/UmXx2jk6qEEn69t6N2R1i/LmcyDT1xr/T2AHGOiXNQ5V8W4iCaaeNawi7aJaRht  
Vx1uOH/2U378fscEESEG8XDqll0GCfB1/TjKI2aitVSzXOtRs8kYgGU78f7VmDNg  
XIlk3gdhnzh+uoEQywIDAQAB  
-----END PUBLIC KEY-----  
这时候的私钥还不能直接被使用，需要进行PKCS#8编码：
[plain] view plain copy 在CODE上查看代码片派生到我的代码片
[root@chaijunkun ~]# openssl pkcs8 -topk8 -in rsa_private_key.pem -out pkcs8_rsa_private_key.pem -nocrypt  
命令中指明了输入私钥文件为rsa_private_key.pem，输出私钥文件为pkcs8_rsa_private_key.pem，不采用任何二次加密（-nocrypt）
再来看一下，编码后的私钥文件是不是和之前的私钥文件不同了：
[plain] view plain copy 在CODE上查看代码片派生到我的代码片
[root@chaijunkun ~]# cat pkcs8_rsa_private_key.pem   
-----BEGIN PRIVATE KEY-----  
MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKEPNyPD+taAXCfG  
6dsqnv/h7zD9SZfHaOTqoQSfr23o3ZHWL8uZzINPXGv9PYAcY6Jc1DlXxbiIJpp4  
1rCLtolpGG1XHW44f/ZTfvx+xwQRIQbxcOqWXQYJ8HX9OMojZqK1VLNc61GzyRiA  
ZTvx/tWYM2BciWTeB2GfOH66gRDLAgMBAAECgYBp4qTvoJKynuT3SbDJY/XwaEtm  
u768SF9P0GlXrtwYuDWjAVue0VhBI9WxMWZTaVafkcP8hxX4QZqPh84td0zjcq3j  
DLOegAFJkIorGzq5FyK7ydBoU1TLjFV459c8dTZMTu+LgsOTD11/V/Jr4NJxIudo  
MBQ3c4cHmOoYv4uzkQJBANR+7Fc3e6oZgqTOesqPSPqljbsdF9E4x4eDFuOecCkJ  
DvVLOOoAzvtHfAiUp+H3fk4hXRpALiNBEHiIdhIuX2UCQQDCCHiPHFd4gC58yyCM  
6Leqkmoa+6YpfRb3oxykLBXcWx7DtbX+ayKy5OQmnkEG+MW8XB8wAdiUl0/tb6cQ  
FaRvAkBhvP94Hk0DMDinFVHlWYJ3xy4pongSA8vCyMj+aSGtvjzjFnZXK4gIjBjA  
2Z9ekDfIOBBawqp2DLdGuX2VXz8BAkByMuIh+KBSv76cnEDwLhfLQJlKgEnvqTvX  
TB0TUw8avlaBAXW34/5sI+NUB1hmbgyTK/T/IFcEPXpBWLGO+e3pAkAGWLpnH0Zh  
Fae7oAqkMAd3xCNY6ec180tAe57hZ6kS+SYLKwb4gGzYaCxc22vMtYksXHtUeamo  
1NMLzI2ZfUoX  
-----END PRIVATE KEY-----  
至此，可用的密钥对已经生成好了，私钥使用pkcs8_rsa_private_key.pem，公钥采用rsa_public_key.pem。
2014年5月20日补充：最近又遇到RSA加密的需求了，而且对方要求只能使用第一步生成的未经过PKCS#8编码的私钥文件。后来查看相关文献得知第一步生成的私钥文件编码是PKCS#1格式，这种格式Java其实是支持的，只不过多写两行代码而已：
[java] view plain copy 在CODE上查看代码片派生到我的代码片
RSAPrivateKeyStructure asn1PrivKey = new RSAPrivateKeyStructure((ASN1Sequence) ASN1Sequence.fromByteArray(priKeyData));  
RSAPrivateKeySpec rsaPrivKeySpec = new RSAPrivateKeySpec(asn1PrivKey.getModulus(), asn1PrivKey.getPrivateExponent());  
KeyFactory keyFactory= KeyFactory.getInstance("RSA");  
PrivateKey priKey= keyFactory.generatePrivate(rsaPrivKeySpec);  
首先将PKCS#1的私钥文件读取出来（注意去掉减号开头的注释内容），然后使用Base64解码读出的字符串，便得到priKeyData，也就是第一行代码中的参数。最后一行得到了私钥。接下来的用法就没什么区别了。
参考文献：https://community.Oracle.com/thread/1529240?start=0&tstart=0

二、编写Java代码实际测试
2012年2月23日补充：在标准JDK中只是规定了JCE(JCE (Java Cryptography Extension) 是一组包，它们提供用于加密、密钥生成和协商以及 Message Authentication Code(MAC)算法的框架和实现。它提供对对称、不对称、块和流密码的加密支持，它还支持安全流和密封的对象。)接口，但是内部实现需要自己或者第三方提供。因此我们这里使用bouncycastle的开源的JCE实现包，下载地址：http://bouncycastle.org/latest_releases.html，我使用的是bcprov-jdk16-146.jar，这是在JDK1.6环境下使用的。如果需要其他JDK版本下的实现，可以在之前的下载页面中找到对应版本。
下面来看一下我实现的代码：
[java] view plain copy 在CODE上查看代码片派生到我的代码片
package net.csdn.blog.chaijunkun;  
  
import java.io.BufferedReader;  
import java.io.IOException;  
import java.io.InputStream;  
import java.io.InputStreamReader;  
import java.security.InvalidKeyException;  
import java.security.KeyFactory;  
import java.security.KeyPair;  
import java.security.KeyPairGenerator;  
import java.security.NoSuchAlgorithmException;  
import java.security.SecureRandom;  
import java.security.interfaces.RSAPrivateKey;  
import java.security.interfaces.RSAPublicKey;  
import java.security.spec.InvalidKeySpecException;  
import java.security.spec.PKCS8EncodedKeySpec;  
import java.security.spec.X509EncodedKeySpec;  
  
import javax.crypto.BadPaddingException;  
import javax.crypto.Cipher;  
import javax.crypto.IllegalBlockSizeException;  
import javax.crypto.NoSuchPaddingException;  
  
import org.bouncycastle.jce.provider.BouncyCastleProvider;  
  
import sun.misc.BASE64Decoder;  
  
public class RSAEncrypt {  
      
    private static final String DEFAULT_PUBLIC_KEY=   
        "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQChDzcjw/rWgFwnxunbKp7/4e8w" + "\r" +  
        "/UmXx2jk6qEEn69t6N2R1i/LmcyDT1xr/T2AHGOiXNQ5V8W4iCaaeNawi7aJaRht" + "\r" +  
        "Vx1uOH/2U378fscEESEG8XDqll0GCfB1/TjKI2aitVSzXOtRs8kYgGU78f7VmDNg" + "\r" +  
        "XIlk3gdhnzh+uoEQywIDAQAB" + "\r";  
      
    private static final String DEFAULT_PRIVATE_KEY=  
        "MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKEPNyPD+taAXCfG" + "\r" +  
        "6dsqnv/h7zD9SZfHaOTqoQSfr23o3ZHWL8uZzINPXGv9PYAcY6Jc1DlXxbiIJpp4" + "\r" +  
        "1rCLtolpGG1XHW44f/ZTfvx+xwQRIQbxcOqWXQYJ8HX9OMojZqK1VLNc61GzyRiA" + "\r" +  
        "ZTvx/tWYM2BciWTeB2GfOH66gRDLAgMBAAECgYBp4qTvoJKynuT3SbDJY/XwaEtm" + "\r" +  
        "u768SF9P0GlXrtwYuDWjAVue0VhBI9WxMWZTaVafkcP8hxX4QZqPh84td0zjcq3j" + "\r" +  
        "DLOegAFJkIorGzq5FyK7ydBoU1TLjFV459c8dTZMTu+LgsOTD11/V/Jr4NJxIudo" + "\r" +  
        "MBQ3c4cHmOoYv4uzkQJBANR+7Fc3e6oZgqTOesqPSPqljbsdF9E4x4eDFuOecCkJ" + "\r" +  
        "DvVLOOoAzvtHfAiUp+H3fk4hXRpALiNBEHiIdhIuX2UCQQDCCHiPHFd4gC58yyCM" + "\r" +  
        "6Leqkmoa+6YpfRb3oxykLBXcWx7DtbX+ayKy5OQmnkEG+MW8XB8wAdiUl0/tb6cQ" + "\r" +  
        "FaRvAkBhvP94Hk0DMDinFVHlWYJ3xy4pongSA8vCyMj+aSGtvjzjFnZXK4gIjBjA" + "\r" +  
        "2Z9ekDfIOBBawqp2DLdGuX2VXz8BAkByMuIh+KBSv76cnEDwLhfLQJlKgEnvqTvX" + "\r" +  
        "TB0TUw8avlaBAXW34/5sI+NUB1hmbgyTK/T/IFcEPXpBWLGO+e3pAkAGWLpnH0Zh" + "\r" +  
        "Fae7oAqkMAd3xCNY6ec180tAe57hZ6kS+SYLKwb4gGzYaCxc22vMtYksXHtUeamo" + "\r" +  
        "1NMLzI2ZfUoX" + "\r";  
  
    /** 
     * 私钥 
     */  
    private RSAPrivateKey privateKey;  
  
    /** 
     * 公钥 
     */  
    private RSAPublicKey publicKey;  
      
    /** 
     * 字节数据转字符串专用集合 
     */  
    private static final char[] HEX_CHAR= {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};  
      
  
    /** 
     * 获取私钥 
     * @return 当前的私钥对象 
     */  
    public RSAPrivateKey getPrivateKey() {  
        return privateKey;  
    }  
  
    /** 
     * 获取公钥 
     * @return 当前的公钥对象 
     */  
    public RSAPublicKey getPublicKey() {  
        return publicKey;  
    }  
  
    /** 
     * 随机生成密钥对 
     */  
    public void genKeyPair(){  
        KeyPairGenerator keyPairGen= null;  
        try {  
            keyPairGen= KeyPairGenerator.getInstance("RSA");  
        } catch (NoSuchAlgorithmException e) {  
            e.printStackTrace();  
        }  
        keyPairGen.initialize(1024, new SecureRandom());  
        KeyPair keyPair= keyPairGen.generateKeyPair();  
        this.privateKey= (RSAPrivateKey) keyPair.getPrivate();  
        this.publicKey= (RSAPublicKey) keyPair.getPublic();  
    }  
  
    /** 
     * 从文件中输入流中加载公钥 
     * @param in 公钥输入流 
     * @throws Exception 加载公钥时产生的异常 
     */  
    public void loadPublicKey(InputStream in) throws Exception{  
        try {  
            BufferedReader br= new BufferedReader(new InputStreamReader(in));  
            String readLine= null;  
            StringBuilder sb= new StringBuilder();  
            while((readLine= br.readLine())!=null){  
                if(readLine.charAt(0)=='-'){  
                    continue;  
                }else{  
                    sb.append(readLine);  
                    sb.append('\r');  
                }  
            }  
            loadPublicKey(sb.toString());  
        } catch (IOException e) {  
            throw new Exception("公钥数据流读取错误");  
        } catch (NullPointerException e) {  
            throw new Exception("公钥输入流为空");  
        }  
    }  
  
  
    /** 
     * 从字符串中加载公钥 
     * @param publicKeyStr 公钥数据字符串 
     * @throws Exception 加载公钥时产生的异常 
     */  
    public void loadPublicKey(String publicKeyStr) throws Exception{  
        try {  
            BASE64Decoder base64Decoder= new BASE64Decoder();  
            byte[] buffer= base64Decoder.decodeBuffer(publicKeyStr);  
            KeyFactory keyFactory= KeyFactory.getInstance("RSA");  
            X509EncodedKeySpec keySpec= new X509EncodedKeySpec(buffer);  
            this.publicKey= (RSAPublicKey) keyFactory.generatePublic(keySpec);  
        } catch (NoSuchAlgorithmException e) {  
            throw new Exception("无此算法");  
        } catch (InvalidKeySpecException e) {  
            throw new Exception("公钥非法");  
        } catch (IOException e) {  
            throw new Exception("公钥数据内容读取错误");  
        } catch (NullPointerException e) {  
            throw new Exception("公钥数据为空");  
        }  
    }  
  
    /** 
     * 从文件中加载私钥 
     * @param keyFileName 私钥文件名 
     * @return 是否成功 
     * @throws Exception  
     */  
    public void loadPrivateKey(InputStream in) throws Exception{  
        try {  
            BufferedReader br= new BufferedReader(new InputStreamReader(in));  
            String readLine= null;  
            StringBuilder sb= new StringBuilder();  
            while((readLine= br.readLine())!=null){  
                if(readLine.charAt(0)=='-'){  
                    continue;  
                }else{  
                    sb.append(readLine);  
                    sb.append('\r');  
                }  
            }  
            loadPrivateKey(sb.toString());  
        } catch (IOException e) {  
            throw new Exception("私钥数据读取错误");  
        } catch (NullPointerException e) {  
            throw new Exception("私钥输入流为空");  
        }  
    }  
  
    public void loadPrivateKey(String privateKeyStr) throws Exception{  
        try {  
            BASE64Decoder base64Decoder= new BASE64Decoder();  
            byte[] buffer= base64Decoder.decodeBuffer(privateKeyStr);  
            PKCS8EncodedKeySpec keySpec= new PKCS8EncodedKeySpec(buffer);  
            KeyFactory keyFactory= KeyFactory.getInstance("RSA");  
            this.privateKey= (RSAPrivateKey) keyFactory.generatePrivate(keySpec);  
        } catch (NoSuchAlgorithmException e) {  
            throw new Exception("无此算法");  
        } catch (InvalidKeySpecException e) {  
            throw new Exception("私钥非法");  
        } catch (IOException e) {  
            throw new Exception("私钥数据内容读取错误");  
        } catch (NullPointerException e) {  
            throw new Exception("私钥数据为空");  
        }  
    }  
  
    /** 
     * 加密过程 
     * @param publicKey 公钥 
     * @param plainTextData 明文数据 
     * @return 
     * @throws Exception 加密过程中的异常信息 
     */  
    public byte[] encrypt(RSAPublicKey publicKey, byte[] plainTextData) throws Exception{  
        if(publicKey== null){  
            throw new Exception("加密公钥为空, 请设置");  
        }  
        Cipher cipher= null;  
        try {  
            cipher= Cipher.getInstance("RSA", new BouncyCastleProvider());  
            cipher.init(Cipher.ENCRYPT_MODE, publicKey);  
            byte[] output= cipher.doFinal(plainTextData);  
            return output;  
        } catch (NoSuchAlgorithmException e) {  
            throw new Exception("无此加密算法");  
        } catch (NoSuchPaddingException e) {  
            e.printStackTrace();  
            return null;  
        }catch (InvalidKeyException e) {  
            throw new Exception("加密公钥非法,请检查");  
        } catch (IllegalBlockSizeException e) {  
            throw new Exception("明文长度非法");  
        } catch (BadPaddingException e) {  
            throw new Exception("明文数据已损坏");  
        }  
    }  
  
    /** 
     * 解密过程 
     * @param privateKey 私钥 
     * @param cipherData 密文数据 
     * @return 明文 
     * @throws Exception 解密过程中的异常信息 
     */  
    public byte[] decrypt(RSAPrivateKey privateKey, byte[] cipherData) throws Exception{  
        if (privateKey== null){  
            throw new Exception("解密私钥为空, 请设置");  
        }  
        Cipher cipher= null;  
        try {  
            cipher= Cipher.getInstance("RSA", new BouncyCastleProvider());  
            cipher.init(Cipher.DECRYPT_MODE, privateKey);  
            byte[] output= cipher.doFinal(cipherData);  
            return output;  
        } catch (NoSuchAlgorithmException e) {  
            throw new Exception("无此解密算法");  
        } catch (NoSuchPaddingException e) {  
            e.printStackTrace();  
            return null;  
        }catch (InvalidKeyException e) {  
            throw new Exception("解密私钥非法,请检查");  
        } catch (IllegalBlockSizeException e) {  
            throw new Exception("密文长度非法");  
        } catch (BadPaddingException e) {  
            throw new Exception("密文数据已损坏");  
        }         
    }  
  
      
    /** 
     * 字节数据转十六进制字符串 
     * @param data 输入数据 
     * @return 十六进制内容 
     */  
    public static String byteArrayToString(byte[] data){  
        StringBuilder stringBuilder= new StringBuilder();  
        for (int i=0; i<data.length; i++){  
            //取出字节的高四位 作为索引得到相应的十六进制标识符 注意无符号右移  
            stringBuilder.append(HEX_CHAR[(data[i] & 0xf0)>>> 4]);  
            //取出字节的低四位 作为索引得到相应的十六进制标识符  
            stringBuilder.append(HEX_CHAR[(data[i] & 0x0f)]);  
            if (i<data.length-1){  
                stringBuilder.append(' ');  
            }  
        }  
        return stringBuilder.toString();  
    }  
  
  
    public static void main(String[] args){  
        RSAEncrypt rsaEncrypt= new RSAEncrypt();  
        //rsaEncrypt.genKeyPair();  
  
        //加载公钥  
        try {  
            rsaEncrypt.loadPublicKey(RSAEncrypt.DEFAULT_PUBLIC_KEY);  
            System.out.println("加载公钥成功");  
        } catch (Exception e) {  
            System.err.println(e.getMessage());  
            System.err.println("加载公钥失败");  
        }  
  
        //加载私钥  
        try {  
            rsaEncrypt.loadPrivateKey(RSAEncrypt.DEFAULT_PRIVATE_KEY);  
            System.out.println("加载私钥成功");  
        } catch (Exception e) {  
            System.err.println(e.getMessage());  
            System.err.println("加载私钥失败");  
        }  
  
        //测试字符串  
        String encryptStr= "Test String chaijunkun";  
  
        try {  
            //加密  
            byte[] cipher = rsaEncrypt.encrypt(rsaEncrypt.getPublicKey(), encryptStr.getBytes());  
            //解密  
            byte[] plainText = rsaEncrypt.decrypt(rsaEncrypt.getPrivateKey(), cipher);  
            System.out.println("密文长度:"+ cipher.length);  
            System.out.println(RSAEncrypt.byteArrayToString(cipher));  
            System.out.println("明文长度:"+ plainText.length);  
            System.out.println(RSAEncrypt.byteArrayToString(plainText));  
            System.out.println(new String(plainText));  
        } catch (Exception e) {  
            System.err.println(e.getMessage());  
        }  
    }  
}  

代码中我提供了两种加载公钥和私钥的方式。
按流来读取：适合在Android应用中按ID索引资源得到InputStream的方式；
按字符串来读取：就像代码中展示的那样，将密钥内容按行存储到静态常量中，按String类型导入密钥。

运行上面的代码，会显示如下信息：
[plain] view plain copy 在CODE上查看代码片派生到我的代码片
加载公钥成功  
加载私钥成功  
密文长度:128  
35 b4 6f 49 69 ae a3 85 a2 a5 0d 45 75 00 23 23 e6 70 69 b4 59 ae 72 6f 6d d3 43 e1 d3 44 85 eb 04 57 2c 46 3e 70 09 4d e6 4c 83 50 c7 56 75 80 c7 e1 31 64 57 c8 e3 46 a7 ce 57 31 ac cd 21 89 89 8f c1 24 c1 22 0c cb 70 6a 0d fa c9 38 80 ba 2e e1 29 02 ed 45 9e 88 e9 23 09 87 af ad ab ac cb 61 03 3c a1 81 56 a5 de c4 79 aa 3e 48 ee 30 3d bc 5b 47 50 75 9f fd 22 87 9e de b1 f4 e8 b2  
明文长度:22  
54 65 73 74 20 53 74 72 69 6e 67 20 63 68 61 69 6a 75 6e 6b 75 6e  
Test String chaijunkun  

在main函数中我注释掉了”rsaEncrypt.genKeyPair()“，这个方法是用来随机生成密钥对的（只生成、使用，不存储）。当不使用文件密钥时，可以将载入密钥的代码注释，启用本方法，也可以跑通代码。
加载公钥与加载私钥的不同点在于公钥加载时使用的是X509EncodedKeySpec（X509编码的Key指令），私钥加载时使用的是PKCS8EncodedKeySpec（PKCS#8编码的Key指令）。

2012年2月22日补充：在android软件开发的过程中，发现上述代码不能正常工作，主要原因在于sun.misc.BASE64Decoder类在android开发包中不存在。因此需要特别在网上寻找rt.jar的源代码，至于JDK的src.zip中的源代码，这个只是JDK中的部分源代码，上述的几个类的代码都没有。经过寻找并添加，上述代码在android应用中能够很好地工作。其中就包含这个类的对应代码。另外此类还依赖于CEFormatException、CEStreamExhausted、CharacterDecoder和CharacterEncoder类和异常定义。

2012年2月23日补充：起初，我写这篇文章是想不依赖于任何第三方包来实现RSA的加密与解密，然而后续遇到了问题。由于在加密方法encrypt和解密方法decrypt中都要建立一个Cipher对象，这个对象只能通过getInstance来获取实例。它有两种：第一个是只指定算法，不指定提供者Provider的；第二个是两个都要指定的。起初没有指定，代码依然能够跑通，但是你会发现，每次加密的结果都不一样。后来分析才知道Cipher对象使用的公私钥是内部自己随机生成的，不是代码中指定的公私钥。奇怪的是，这种不指定Provider的代码能够在android应用中跑通，而且每次加密的结果都相同。我想，android的SDK中除了系统的一些开发函数外，自己也实现了JDK的功能，可能在它自己的JDK中已经提供了相应的Provider，才使得每次加密结果相同。当我像网上的示例代码那样加入了bouncycastle的Provider后，果然每次加密的结果都相同了。

参考文献：
RSA介绍：http://baike.baidu.com/view/7520.htm
OpenSSL介绍：http://baike.baidu.com/view/300712.htm
密钥对生成：http://www.howforge.com/how-to-generate-key-pair-using-openssl
私钥编码格式转换：http://shuany.iteye.com/blog/730910
JCE介绍：http://baike.baidu.com/view/1855103.htm