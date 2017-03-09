#Chapter 2:ARC Rules

无需再手动调用retain、release。

## 修饰词

* __strong : 
* __weak :
* __unsafe_unretained :
* __autoreleasing : 

默认初始化的时候都是nil 除了__unsafe_unretained

### __strong

`id` 类型变量的默认属性。

可以认为是一个块作用域的变量，当逃离块作用域之后，就会自动进行释放。strong 不仅意味强引用，同时还意味着块作用域。这样即使是从非create类型函数得到的返回值，赋值给strong，也会是strong的。


当不需要一个strong值的时候，必须付nil才能触发其rc减一.

### __weak
主要就是用来解决循环引用的问题

###__unsafe_unretained
和__weak一样，不持有对象.但是更像c的pointer，需要手动赋nil

### __autoreleasing
替代了MRC的NSAutoreleasePool以及对象的autorelease方法。取而代之的是:

    @autoreleasepool {
	    和__autoreleaseing 
    }

一般很少用到显式的__autoreleasing，OC编译器会对

* __strong 返回值
* __weak 变量

自动注册到AutoReleasePool
