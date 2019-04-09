---
id: 101
date: 2019-04-09 17:31:20
title: Java String源码笔记
categories:
    - java
tags: 
    - java,string,源码
---

### 源码  
实现了3个接口 Serializable Comparable CharSequence  

关于CharSequence   

Java从String类和StringBuffer类开始。但是这两个类是无关的，没有通过继承和接口相互联系。后来，Java团队意识到字符串相关实现之间应该存在统一的联系，以使它们可以互换。在Java4中，团队添加了CharSequence接口并在String和String Buffer上追溯实现了该接口，并添加了另一个实现CharBuffer。后来在Java5中他们添加了一个不保证线程安全的，速度较快的实现:StringBuilder。

final class String是一个不可被继承的类

主要字段:

private final char value[]; final 数组 数组指针不可变 值可变 用来存储实际的字符串值

private int hash;

private static final long serialVersionUID = -6849794470754667710L; 序列化标识码

主要方法:
String(String original) 构造函数 会复制传入的original，如果不需要复制orginal,则直接使用String s = "abc"就可以了，而不是用new String()

无参构造函数 会用"".value来复制this.value，所以可以直接使用 String s = ""; 否则会在堆上像如上构造函数new出一个String对象

String(char value[]) {this.value = Arrays.copyOf(value,value.length)} 从char数组复制一个新的char数组赋予String的成员变量value

String(char value[], int offset, int count) 主要是边界判断以及this.value = Arrays.copyOfRange(value, offset, offset+count);

String(int[] codePoints, int offset, int count) 主要是新建一个char数组，然后int c = codePoints[i];v[j] = (char)c;this.value = v;通过类型强制转换int为char

String(byte bytes[], int offset, int length, String charsetName)把字节数组，即（二进制）字节流按照charsetName转为char[],然后新建一个String对象,this.value = StringCoding.decode(charsetName, bytes, offset, length);调用decode，类似的构造器还有String(byte bytes[],String charsetName)   

String(StringBuffer buffer) 通过synchronized(buffer)保证this.value = Arrays.copyOf(buffer.getValue(), buffer.length())的线程安全。
String(StringBuilder builder) 无synchronized关键字 不保证线程安全

length() 返回value.length

isEmpty() 返回 value.length == 0

char charAt(int index) 判断index边界 返回value[index]

int codePointAt(int index) 返回index处的unicode编码值 可以使用Integer.toHexString(返回值)来输出16进制的unicode值

byte[] getBytes(String charsetName) return StringCoding.encode(charsetName, value, 0, value.length);调用encode，不同的编码方式，如utf-8,utf-32可能返回的byte数组长度不相同，对应的decode方式是前面讲到的带charset入参的构造方法

boolean equals(Object anObject)先用==判断是否是同一个引用，如果是则返回true，否则对比char[]中的char是否完全相同

boolean contentEquals(StringBuffer sb)类似equals，比较对象为StringBuffer，内容比较

boolean nonSyncContentEquals(AbstractStringBuilder sb) 上面的实现中有synchronized关键字 这个方法没有 不保证线程安全

int compareTo(String anotherString) based on the Unicode value of each character 先while循环比较每个位置的char值(unicode值)，while边界是Math.min(len1,len2),如果不等则返回char1 - char2的值，循环完成再返回return len1 == len2

int compareToIgnoreCase(String str) 忽略大小写的比较

int hashCode() 
```
h = 0;
for (int i = 0; i < value.length; i++) {
    h = 31 * h + val[i];
}
```

用unicode结合31*h，关于31一方面是性能，第二可以避免溢出，具体可以看这里[https://stackoverflow.com/questions/299304/why-does-javas-hashcode-in-string-use-31-as-a-multiplier](https://stackoverflow.com/questions/299304/why-does-javas-hashcode-in-string-use-31-as-a-multiplier)

String substring(int beginIndex)  直接使用new String: return (beginIndex == 0) ? this : new String(value, beginIndex, subLen);

String concat(String str)
```
char buf[] = Arrays.copyOf(value, len + otherLen);
str.getChars(buf, len);
return new String(buf, true);
```

String.join("|","???","...","啥") join方法1.8新增方法 输出???|...|啥

String.format("\\u%H",'棒'); 格式化输出String 这里的%H表示为16进制

static String valueOf(Object obj) 返回return (obj == null) ? "null" : obj.toString();

static String valueOf(char data[]) 返回return new String(data);
另外，入参为int，float,double，分别调用其包装类的包装类.toString(xx)

public native String intern(); intern是一个native方法，如果在常量池中有这个String，则直接返回，否则在常量吃新建一个String然后返回这个String的引用，native方法是通过java中的JNI实现的。JNI是Java Native Interface的 缩写。从Java 1.1开始，Java Native Interface (JNI)标准成为java平台的一部分，它允许Java代码和其他语言写的代码进行交互。它的大体实现结构就是:JAVA使用jni调用c++实现的StringTable的intern方法, StringTable的intern方法跟Java中的HashMap的实现是差不多的, 只是不能自动扩容。默认大小是1009。要注意的是，String的String Pool是一个固定大小的Hashtable，默认值大小长度是1009，如果放进String Pool的String非常多，就会造成Hash冲突严重，从而导致链表会很长，而链表长了后直接会造成的影响就是当调用String.intern时性能会大幅下降（因为要一个一个找）

部分测试参考代码
```
import java.io.UnsupportedEncodingException;

/**
 * @auther zhoudazhuang
 * @date 19-4-9 13:43
 * @description
 */
public class StringTest {
  public static void main(String[] args) throws UnsupportedEncodingException {
      char c1 = '我';
      Character c2 = 'w';
      String s1 = new String();
      System.out.println(s1);
      String s2 = "厉害";
      int[] i = new int[2];
      i[0] = '棒';
      i[1] = '啊';
      for (int i1: i){
        System.out.println("\\u"+Integer.toHexString(i1));
      }
      String us = new String(i,0,2);
      System.out.println(us);
      System.out.println("\\u"+Integer.toHexString(us.codePointAt(0)));
      byte[] ba = us.getBytes("UTF-8");
      System.out.println(ba.length);
      System.out.println(new String(ba,"UTF-32"));
      System.out.println(String.join("|","???","...","啥"));
      String hexStr = String.format("\\u%H",'棒');
      System.out.println(hexStr);
  }
}
```

### unicode
Unicode 是一种字符集，Unicode 的学名是 "Universal Multiple-Octet Coded Character Set"，简称为UCS。UCS 可以看作是 "Unicode Character Set" 的缩写。

这一标准的 2 字节形式通常称作 UCS-2(即UTF-16,但UTF-16还可以用4个字节表示一个字符)。然而，受制于 2 字节数量的限制，UCS-2 只能表示最多2^16=65536 个字符。Unicode 的 4 字节形式被称为 UCS-4 或 UTF-32，能够定义 Unicode 的全部扩展，最多可定义 100 万个以上唯一字符。

Basic Multilingual Plane，简写 BMP 表示是Unicode中的一个编码区段。编码从U+0000至U+FFFF。即2字节的UTF-16,JVM规范中明确说明了java的char类型使用的编码方案是UTF-16。

对于一个字符串对象，其内容是通过一个char数组存储的。char类型由2个字节存储，这2个字节实际上存储的就是UTF-16编码下的码元。

对于 String s = "你好哦!";如果源码文件是GBK编码,操作系统（windows）默认的环境编码为GBK，那么编译时（此时字符串是二进制）,JVM将按照GBK编码将字节数组解析成字符，然后将字符转换为unicode格式的字节数组，作为内部存储。当打印这个字符串时，JVM 根据操作系统本地的语言环境，将unicode转换为GBK，然后操作系统将GBK格式的内容显示出来。

UTF-8最大的一个特点，就是它是一种变长的编码方式。它可以使用1~4个字节表示一个符号，根据不同的符号而变化字节长度。其他实现方式还包括 UTF-16（字符用两个字节或四个字节表示）和 UTF-32（字符用四个字节表示）,所以utf-8自然可以表示中文

### Ref
1. [https://segmentfault.com/q/1010000009652523](https://segmentfault.com/q/1010000009652523)
2. [https://tech.meituan.com/2014/03/06/in-depth-understanding-string-intern.html](https://tech.meituan.com/2014/03/06/in-depth-understanding-string-intern.html)
3. [http://www.ruanyifeng.com/blog/2007/10/ascii_unicode_and_utf-8.html](http://www.ruanyifeng.com/blog/2007/10/ascii_unicode_and_utf-8.html)