---
id: 70
date: 2018-05-23 22:29:00
title: 浅谈c++面向对象的封装，继承和多态
categories:
    - c++
tags:
    - c++ 封装 继承 多态
---

### 封装

c++的封装体现在class关键字上，一个类的定义将数据与操作数据的源代码进行有机的结合，形成一个“类”，封装一些具体实现，按需对外暴露部分属性和方法。   
```
class BaseClass{
public:
    int a;
    void test1();
    virtual void printFunc(){
    cout<<"This is BaseClass."<<endl;
    }
protected:
    int b;
    void test2();
private:
    int c;
};
```

### 继承

使用:符号表示类之间的继承关系。分几种继承方式，public继承是public到子类public,protectd到子类的protectd;protectd继承是基类所有public,protectd都到子类的protectd;private继承同理是到自己的private里面.另外这里提一下stuct和class的继承关系，c++的struct是对c中struct的一种增强，支持继承，支持多态，核心的不同点在于struct的默认继承关系是public继承，而class默认是private继承。
```
class BaseClass{
public:
    int a;
    void test1();
    virtual void printFunc(){
    cout<<"This is BaseClass."<<endl;
    }
protected:
    int b;
    void test2();
private:
    int c;
};
class SubClassA : public BaseClass{
public:
    void printFunc(){
    cout<<"This is SubClassA"<<endl;
    }
    void testA(){
       cout<<a<<endl;
       cout<<b<<endl;
     //cout<<c<<endl; c私有成员无法继承
    }
private:
    int d;
};
```

### 多态

c\+\+中多态使用虚函数来实现，关键字virtual,其意义在于允许基类指针调用子类具体实现来达到多态的目地。纯虚函数是在基类中声明的虚函数，它在基类中没有定义，但要求任何派生类都要定义自己的实现方法。在基类中实现纯虚函数的方法是在函数原型后加“=0”，如：
　virtual void funtion1()=0;类似java中的接口和抽象类的约束。另外，c++多态中的动态绑定，函数调用默认不使用动态绑定。要触发动态绑定，满足两个条件：第一，只有指定为虚函数的成员函数才能进行动态绑定，成员函数默认为非虚函数，非虚函数不进行动态绑定；
第二，必须通过基类类型的引用或指针进行函数调用,同时支持重载的多态和重写的多态。

```
#include <iostream>
using namespace std;

class BaseClass{
public:
    int a;
    void test1();
    virtual void printFunc(){
    cout<<"This is BaseClass."<<endl;
    }
protected:
    int b;
    void test2();
private:
    int c;
};
class SubClassA : public BaseClass{
public:
    void printFunc(){
    cout<<"This is SubClassA"<<endl;
    }
    void testA(){
       cout<<a<<endl;
       cout<<b<<endl;
     //cout<<c<<endl; c私有成员无法继承
    }
private:
    int d;
};

class SubClassB : public BaseClass{
public:
    void printFunc(){
        cout<<"This is SubClassB."<<endl;
    }
    void printFunc(int a){
        cout<<"a is:" << a << endl;
    }
};

// private成员只能由基类的成员和友元访问。
// public继承是public到子类public,protectd到子类的protectd
// protectd继承是基类所有public,protectd都到子类的protectd
// private继承同理是到自己的private里面

// 多态
// C++ 中的函数调用默认不使用动态绑定。要触发动态绑定，满足两个条件：
// 第一，只有指定为虚函数的成员函数才能进行动态绑定，成员函数默认为非虚函数，非虚函数不进行动态绑定；
// 第二，必须通过基类类型的引用或指针进行函数调用
int main(){
    SubClassA* d = new SubClassA();
    d->printFunc();
    delete d;
    d = 0;

    cout << "---------------" << endl;
    BaseClass *b1,*b2,*b3;
    BaseClass bc;
    SubClassA dcA;
    SubClassB dcB;
    b1 = &bc;
    b2 = &dcA;
    b3 = &dcB;
    b1->printFunc(); //调用基类的方法
    b2->printFunc();  //调用派生类A的方法
    b3->printFunc();  //调用派生类B的方法
    dcB.printFunc(6);
    return 0;
}
```

### 参考
1. [http://blog.51cto.com/6924918/1279707](http://blog.51cto.com/6924918/1279707)
2. [https://blog.csdn.net/xdrt81y/article/details/17143801](https://blog.csdn.net/xdrt81y/article/details/17143801)