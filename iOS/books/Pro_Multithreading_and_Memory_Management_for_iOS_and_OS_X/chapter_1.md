#Chapter 1:Life Before Automatic Reference Counting

MRC

## 序言
对于OC来说，内存管理就等于引用计数的管理，这点和C/CPP不太一样，可以认为是管理职能指针。

George E. Collins于1960年提出了Reference ounting（引用计数）的概念。

四大使用引用计数的原则：
1. 对于自己创建的对象有所有权 （create）
2. 使用retain获得拥有权 (take ownershipe)
3. 当不需要使用时，需要释放对象 (relinqush ownershipe)
4. 不能释放自己所不拥有的对象 (dispose)

Action for Objective-C Object |  Objective-C Method
---|---Create and have ownership of it Take ownership of it | alloc/new/copy/mutableCopy group retainRelinquish it | releaseDispose of it | dealloc

有点颠覆的认知，这些方法都不是OC本身的，而是Cocoa赋予的，是NSObject携带的方法。

通过创建的方法获得：

	alloc
	new
	copy
	mutableCopy
以及以这些单词开始的方法。	

非创建的方法获得：

	retain
	
进行释放：

	release	

###
Foundation.framework是不开源的，CoreFoundation.framework是开源的，不幸的是NSObject在Foundation.framework中。所以可以借鉴GNU的实现[GNUstep](http://www.gnustep.org/)。

NSObject的结构就是一个head+一个body的数据。而头就是个count，NSObject指针指向body的位置。

###
代码实现参考GNUStep和CoreFoundation
	