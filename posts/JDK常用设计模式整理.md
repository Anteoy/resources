---
id: 103
date: 2019-04-11 14:53:20
title: JDK常用设计模式整理
categories:
    - java
tags: 
    - java,设计模式
---

1. 观察者模式 
    jdk中有提供接口Observer 和用于定义subject的类Observable

      ```
       subject.addObserver(new ObserveTest());
       subject.set(3);
       subject.setChanged();
       subject.notifyObservers(3);
      ```

      subject持有一个Vector(线程安全的list),用于存储addObserver方法里面添加的观察者Observer,通知通过Observer的update方法进行更新 
2. 桥接模式 
    主要关注桥 先有桥  然后桥两边可以独立变化扩展  
    比如jdk里面的

    ```
    Set<String> names = Collections.newSetFromMap(
                new ConcurrentHashMap<String, Boolean>()
        );
    ```

    把set和map桥接起来，同时map和set都可以独立扩展和变化
3. 装饰者模式Decorator  
    每个Decorator均有一个指向Subject对象的引用，附加的功能被添加在这个Subject对象上，不改变原始的指向类。而Decorator对象本身也是一个Subject对象，因而它也能够被其他的Decorator所修饰，提供组合的功能。

    ```
    BufferedReader br = new BufferedReader(new InputStreamReader(System.in))
    while(true){
        System.out.println(br.readLine())
    }
    ```

    BufferedReader InputStreamReader 都继承了抽象类Reader，然后BufferedReader类里持有InputStreamReader对象的引用 两个都是独立的装饰者 各自增强了被装饰类的功能 
4. prototype 原型模式
    意图：用原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。
    主要解决：在运行期建立和删除原型。
    应用实例： 1、细胞分裂。 2、JAVA 中的 Object clone() 方法。
    原型模式很少单独出现，一般是和工厂方法模式一起出现，通过 clone 的方法创建一个对象，然后由工厂方法提供给调用者。原型模式已经与 Java 融为浑然一体，大家可以随手拿来使用。
    浅拷贝实现 Cloneable，重写，深拷贝是通过实现 Serializable 读取二进制流。
5. builder建造者模式
    和工厂方法区别，两者都是组装对象，而建造者模式更关心零件的装配顺序。
    如jdk中的StringBuilder StringBuffer的append方法
6. 工厂方法模式
    Calendar calendar = java.util.Calendar.getInstance();
    另外： 简单工厂是指不用接口只有一个工厂，所有产品都在这个工厂类里面进行创建，添加需要生产的商品就需要改动这个类; 工厂方法也就是工厂模式主要使用工厂接口和产品接口，具体工厂实现这个接口，需要添加的时候只需要增加一个实现工厂接口的具体工厂实现类，然后就可以了，抽象工厂主要是解决工厂方法模式一个工厂只能生产一类产品的缺陷，抽象工厂一个工厂可以生产一系列的产品，也就是产品族，比如手机工厂可以生产不同的手机。据此，spring的bean factory应该划分属于抽象工厂的设计模式
7. 适配器模式
    泛型必须写在返回值或者void前面

    ```
    <T> void test2(T a){
        System.out.println();
    }
    List<Integer> arrayList = java.util.Arrays.asList(new Integer[]{1,2,3});
    List<Integer> arrayList = java.util.Arrays.asList(1,2,3);
    ```
    可以看作把数组适配为链表list
8. 享元模式 Flyweight
    java.lang.Integer#valueOf(int) (also on Boolean, Byte, Character, Short, Long and BigDecimal)
    主要为了减少创建对象的数量,减少内存占用和提高内存
    享元模式尝试重用现有的同类对象，如果未找到匹配的对象，则创建新对象。(可能和各种连接池和线程池相关)
9. 策略模式
    封装行为或者算法，能在运行时动态改变类的行为或算法。
    在有多种算法类似的情况下，使用if...elase会复杂和难以维护
    关键代码：实现同一接口
    jdk中compare() java.util.Comparator#compare()
10. 适配器模式
    一个适配允许通常因为接口不兼容而不能在一起工作的类工作在一起，做法是将类自己的接口包裹在一个已存在的类中。
    装饰器模式，原有的不能满足现有的需求，对原有的进行增强。
    代理模式，同一个类而去调用另一个类的方法，不对这个方法进行直接操作。
    外观模式，我们通过外观的包装，使应用程序只能看到外观对象，而不会看到具体的细节对象，这样无疑会降低应用程序的复杂度，并且提高了程序的可维护性。

### ref
1. [https://www.ibm.com/developerworks/cn/java/l-jdkdp/part1/index.html](https://www.ibm.com/developerworks/cn/java/l-jdkdp/part1/index.html)
2. [https://www.ibm.com/developerworks/cn/java/l-jdkdp/part3/index.html](https://www.ibm.com/developerworks/cn/java/l-jdkdp/part3/index.html)
3. [https://stackoverflow.com/questions/1673841/examples-of-gof-design-patterns-in-javas-core-libraries](https://stackoverflow.com/questions/1673841/examples-of-gof-design-patterns-in-javas-core-libraries)
4. [https://blog.csdn.net/zhang31jian/article/details/50538000 ](https://blog.csdn.net/zhang31jian/article/details/50538000 )