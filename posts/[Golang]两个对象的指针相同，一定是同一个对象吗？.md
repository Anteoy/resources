---
id: 106
date: 2020-01-11 8:33:20
title: [Golang]两个对象的指针相同，一定是同一个对象吗？
categories:
    - golang
tags: 
    - golang,slice,append,%p,指针
---

### 开门见山  
今天发现一个十分有趣的case，如下：

```
package main

import "fmt"

func main() {
	n1 := make ([] int, 0,5)
	n2 := n1[:2]
	fmt.Println(n1)
	fmt.Println(n2)
	// 思考 n1和n2打印出的指针地址是否相同?
	fmt.Printf("address of n1:%p\n",n1)
	fmt.Printf("address of n2:%p\n",n2)
}
```

n1不是指针类型，是make的一个[]int slice的引用类型，可能多数人会有这样的思考： **两个对象的指针地址相同，那么这两个对象存储的内容是相同的**，即使slice的底层数组结构SliceHeader的Data字段域（数组），在未超出n1的容量5之前,和n2用的是一个Data字段域，但是因为sliceHeader里第二个字段域是Len,第三个是Cap，n1和n2的SliceHeader肯定不是同一个，那么用%p打印出的指针地址肯定是不同的指针地址，我开始也是这样的想法，然后结果让我大吃一惊, 如下：

```
[]
[0 0]
address of n1:0xc00007e030
address of n2:0xc00007e030
```

什么? 打印出的指针地址相同。我瞬间就不淡定了 这似乎颠覆了我的一个固定观念--**两个对象的指针地址相同，那么这两个对象存储的内容是相同的**

### 猜想  
带着自己的疑惑 我首先想到的是利用反射，把slice转成SliceHeader来一探究竟 看看Data,Len,Cap三个字段域是否相同:   
```
package main

import (
	"fmt"
	"reflect"
	"unsafe"
)

func main() {
	n1 := make ([] int, 0,5)
	n2 := n1[:2]
	fmt.Println(n1)
	fmt.Println(n2)
	// 思考 n1和n2打印出的指针地址是否相同?
	fmt.Printf("address of n1:%p\n",n1)
	fmt.Printf("address of n2:%p\n",n2)
	sh:=(*reflect.SliceHeader)(unsafe.Pointer(&n1))
	fmt.Printf("n1 Data:%p,Len:%d,Cap:%d\n",sh.Data,sh.Len,sh.Cap)
	sh1:=(*reflect.SliceHeader)(unsafe.Pointer(&n2))
	fmt.Printf("n2 Data:%p,Len:%d,Cap:%d\n",sh1.Data,sh1.Len,sh1.Cap)
}
```   
输出:   
```
[]
[0 0]
address of n1:0xc00007e030
address of n2:0xc00007e030
n1 Data:%!p(uintptr=824634236976),Len:0,Cap:5
n2 Data:%!p(uintptr=824634236976),Len:2,Cap:5
```

### 验证
开始看到上面的结果，仍然是十分疑惑，因为 n1和n2的指针是相同的，且uintptr的Data域的指针也是相同的，但是还是违背了上面提到的规则 **两个对象的指针地址相同，那么这两个对象存储的内容是相同的**。 
好吧，到了这里，只能一个点一个点的理了。首先想到的是%p打印的是否真的是对象的指针地址呢?是不是针对slice的时候不是打印的sliceHeader的存储地址? 于是翻了翻golang的官方文档.
[https://golang.org/pkg/fmt/](https://golang.org/pkg/fmt/)  
>> Slice:
>> %p	address of 0th element in base 16 notation, with leading 0x

重点关注上面提到的slice的%p的解释，打印的是第0个元素的指针地址，这里给自己的感觉是一种恍然大悟又觉得突然懵逼的感觉。恍然大悟是因为这里%p打印的是第0个元素，也就是Data域中的第一个元素的地址，那么相同也是理所当然的。突然懵逼是因为那如此来看，应该和我打印的uintptr的Data指针相同啊?

### 最后的问题
后面拍了拍脑袋，突然想到%p打印的是with leading 0x,也就是是16进制的,而SliceHeader的Data域是一个uintptr的指针

```
type SliceHeader struct {
	Data uintptr
	Len  int
	Cap  int
}
```
那么也就是说， 一个打印的是16禁止，一个打印的是10禁止。转换一下进制呢:

```
package main

import (
	"fmt"
	"reflect"
	"unsafe"
)

func main() {
	n1 := make ([] int, 0,5)
	n2 := n1[:2]
	fmt.Println(n1)
	fmt.Println(n2)
	// 思考 n1和n2打印出的指针地址是否相同?
	fmt.Printf("address of n1:%p\n",n1)
	fmt.Printf("address of n2:%p\n",n2)
	sh:=(*reflect.SliceHeader)(unsafe.Pointer(&n1))
	fmt.Printf("n1 Data:Ox%x,Len:%d,Cap:%d\n",sh.Data,sh.Len,sh.Cap)
	sh1:=(*reflect.SliceHeader)(unsafe.Pointer(&n2))
	fmt.Printf("n2 Data:Ox%x,Len:%d,Cap:%d\n",sh1.Data,sh1.Len,sh1.Cap)
}
```   
输出:    
```  
[]
[0 0]
address of n1:0xc00007e030
address of n2:0xc00007e030
n1 Data:Oxc00007e030,Len:0,Cap:5
n2 Data:Oxc00007e030,Len:2,Cap:5
```   
确实是相同的，slice的%p打印的是Data域的指针地址，指向的是Data域的数组的第一个元素也即起始地址.上面的问题都迎刃而解了，slice打印的%p指针地址相同，是因为底层的Data域公用的同一个数组。而如果使用append超过cap进行扩容了的话，那么就会使用不同的Data域数组，打印出来的%p自然也就不同了
