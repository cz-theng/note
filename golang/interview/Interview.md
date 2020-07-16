# Interview

## 代码片段

### 1. panic
#### 1.1 panic和defer的关系

    package main

    import (
        "fmt"
    )

    func main() {
        defer_call()
    }

    func defer_call() {
        defer func() { fmt.Println("打印前") }()
        defer func() { fmt.Println("打印中") }()
        defer func() { fmt.Println("打印后") }()

        panic("触发异常")
    }

逆序打印defer然后最后打印panic。因为panic是在所有defer没有处理后触发panic.

#### 1.2 defer执行顺序

    func calc(index string, a, b int) int {
        ret := a + b
        fmt.Println(index, a, b, ret)
        return ret
    }
    func main() {
        a := 1                                             
        b := 2                                             
        defer calc("1", a, calc("10", a, b))  
        a = 0                                             
        defer calc("2", a, calc("20", a, b))  
        b = 1                                              
    }

首先执行第一个defer的10.因为defer的参数是立即计算出来的。然后是第二个defer的参数，
急着是第二个defer，此时a=0, "b"为calc的计算结果，而不是b。 最后第一个derfer
这里a=1,“b"=calc的计算结果。

* defer的参数是立马计算的
* defer的参数取代码时（执行标记）的镜像。

### 2. range

#### range的本质

    package main
    import (
        "fmt"
    )
    type student struct {
        Name string
        Age  int
    }
    func pase_student() map[string]*student {
        m := make(map[string]*student)
        stus := []student{
            {Name: "zhou", Age: 24},
            {Name: "li", Age: 23},
            {Name: "wang", Age: 22},
        }
        for _, stu := range stus {
            m[stu.Name] = &stu
        }
        return m
    }
    func main() {
        students := pase_student()
        for k, v := range students {
            fmt.Printf("key=%s,value=%v \n", k, v)
        }
    }

结果都是Value为 wang。因为range是一个copy的过程，并且用后就释放，复用了同一块内存

> Range
> The range form of the for loop iterates over a slice or map.
>
> When ranging over a slice, two values are returned for each iteration. 
> The first is the index, and the second is a copy of the element at that index.

### 3. 闭包
#### GOMAXPROC的影响

    func main() {
        runtime.GOMAXPROCS(1)
        wg := sync.WaitGroup{}
        wg.Add(20)
        for i := 0; i < 10; i++ {
            go func() {
                fmt.Println("i: ", i)
                wg.Done()
            }()
        }
        for i := 0; i < 10; i++ {
            go func(i int) {
                fmt.Println("i: ", i)
                wg.Done()
            }(i)
        }
        wg.Wait()
    }

对于前者从某次开始后，i一直未10，后者可以正常打印出0-9。原因是前面使用的是闭包匿名函数。
i取自外界的i的指针，不是一个copy。而后面参数传递的是一个copy。

### 4. sizeof
#### 空struct有多大

	type S struct{}

	s := S{}
	fmt.Printf("S size is %d \n", unsafe.Sizeof(s))

大小为0.

#### slice有多大？空struct的slice呢？

	type S struct{}

	s := S{}
	fmt.Printf("S size is %d \n", unsafe.Sizeof(s))

	ss := make([]S, 1000)
	fmt.Printf("S slice size is %d \n", unsafe.Sizeof(ss))

	int32Slice := make([]int32, 100)
	fmt.Printf("int32 slice size is %d \n", unsafe.Sizeof(int32Slice))

	int64Slice := make([]int64, 100)
	fmt.Printf("int32 slice size is %d \n", unsafe.Sizeof(int64Slice))	type S struct{}

	s := S{}
	fmt.Printf("S size is %d \n", unsafe.Sizeof(s))

	ss := make([]S, 1000)
	fmt.Printf("S slice size is %d \n", unsafe.Sizeof(ss))

后面这几个slice都是24

### 5. 作用域
#### 变量scope

    func main() {  
        x := 1
        fmt.Println(x)     //prints 1
        {
            fmt.Println(x) //prints 1
            x := 2
            fmt.Println(x) //prints 2
        }
        fmt.Println(x)     //prints 1 (bad if you need 2)
    }

### 6. struce
#### struct为空

一个 `s := TypeOfStruct{}` 如何判断为空， 一种是增加一个empty的方法。或者让其
与 `TypeOfStruct{}`做比较，前提条件是每个成员都是可比较的。 

## 语法陷阱

### 1. nil

#### nil和slice
本质上，空slice就是nil。也就是没有初始化的slice就是nil

    var nilSlice []int32

此时nilSlice不用特别进行make的初始化即可正常使用。

因此也可以用nil和slice做比较，甚至在传参的时候直接使用nil,所以可以对其进行len、cap操作。

但是有两个个特殊情况需要规避，一个是标准库的JSON处理：

    type Res struct {
        Data []string
    }
    var nilSlice []string
    emptySlice := make([]string, 5)
    res, _ := json.Marshal(Res{Data: nilSlice})
    res2, _ := json.Marshal(Res{Data: emptySlice})
    fmt.Println(string(res)) // Output: {"Data":null}
    fmt.Println(string(res2)) // Output: {"Data":[]}

这里的JSON序列化的时候，nil变成了null， 而len=0的slice为"[]"。

另外一个是reflect.DeepEqual比较

    var nilSlice []string
    emptySlice := make([]string, 5)
    fmt.Println(reflect.DeepEqual(nilSlice, emptySlice)) // Output: false
    fmt.Printf("Got: %+v, Want: %+v\n", nilSlice, emptySlice) //Output: Got: [], Want: []

需要注意的是这里用%v打印的时候，又都是"[]",烦躁。。。

#### nil和map
map和slice一样，都是引用类型，因此其初始化的零值就都是nil，所以也可以对nil求len。
可以用map和nil做相等比较。甚至可以对nil做map的成员读操作：

    var m map[int32]bool
    fmt.Println("m[1]:", m[1])

得到的结果是false，也就是零值。

但是特殊的是，不可以对nil做map的存储操作：

    var m map[int32]bool
    m[1] = true

这样会引起panic，所以map声明后，最快速的进行定义，用make分配空间。

#### nil和channel
channel也是一个引用类型，所以其初始零值也是nil。然后"<-"和"->" 操作一个nil
都是会导致直接卡死。


#### nil和类型断言
如果类型断言失败，其得到一个零值：

    var data interface{} = "great"
    if res, ok := data.(int); ok {
        fmt.Println("[is an int] value =>",res)
    } else {
        fmt.Println("[not an int] value =>",data) 
        //prints: [not an int] value => great (as expected)
    }

这里在断言失败的时候，如果继续是用res，那么其值为0。
    


#### nil和interface
interface的本质是一个二元组（T=int, V=3）

>  a type T and a value V. V is a concrete value such as an int, struct or 
> pointer, never an interface itself, and has type T. For instance, 
> if we store the int value 3 in an interface, 
> the resulting interface value has, schematically, (T=int, V=3).

而nil的interface应该是(T=nil, V=nil)
empty的interface是(T=*int32, V=nil)

#### nil 和error
看到题目：

    func returnsError() error {
        var p *MyError = nil
        if bad() {
            p = ErrBad
        }
        return p // Will always return a non-nil error.
    }

    func main() {
        if err := returnsError(); err != nil {
            fmt.Fatal("error:", err);
        }
    }

这里，returnsError永远不会返回nil，因为nil是(T=nil, V=nil)， 而这个函数返回的p是
(T=*MyError, V=xxx)。


### 2. 传参类型

#### array是值类型
和C/C++ 不一样，array是传值传值，所以函数里面的是一份copy，若想进行修改外面的参数，需要
用slice进行传递。

#### for...range 临时变量
for...range中的那个可以使用的变量，实际上是一个copy，而且起始地址都是同一个。所以对
他的修改，不会影响原来的array/slice/map等。也就有了上面代码片段里面的一个问题。以及
问题：

    func main() {  
        data := []string{"one","two","three"}

        for _,v := range data {
            go func() {
                fmt.Println(v)
            }()
        }

        time.Sleep(3 * time.Second)
        //goroutines print: three, three, three
    }

可以这么修改：

    for _,v := range data {
        vcopy := v //
        go func() {
            fmt.Println(vcopy)
        }()
    }

### 3. 字符串

#### utf8字符串
1. len 求出来的utf8字符串是utf8字符rune的数目
2. len求出来的普通字符串是所占空间的大小，也就是和c里面一样的char 数组大小
3. 可以用utf8.RuneCountInString来计算buffer里面的utf8字符数目
4. for range 是对rune来的，如果是utf8的话，则是utf8的rune大小，而不是char，
所以要注意用[]byte先强转一次。

    data := "é"
    fmt.Println(len(data))                    //prints: 3
    fmt.Println(utf8.RuneCountInString(data)) //prints: 2

    data := "A\xfe\x02\xff\x04"
    for _,v := range data {
        fmt.Printf("%#x ",v)
    }
    //prints: 0x41 0xfffd 0x2 0xfffd 0x4 (not ok)

    fmt.Println()
    for _,v := range []byte(data) {
        fmt.Printf("%#x ",v)
    }
    //prints: 0x41 0xfe 0x2 0xff 0x4 (good)

其中0xfffd 表示未知字符的意思。

#### map和struct

不可以修改值类型为struct的map中的成员

    type data struct {  
        name string
    }

    func main() {  
        m := map[string]data {"x":{"one"}}
        m["x"].name = "two" //error
    }

原因是map类型是不可以进行索引的，而slice则可以。修改方式是给m["x"]重新赋值。


### 4.struct
#### 何时使用空struct{},举例说明
当只需要方法，而不需要成员存储空间的时候，可以空struct来节约空间，因为其大小为0。
使用场景，比如通过map来实现一个set：

    set := make(map[string]struct{})
    for _, value := range []string{"apple", "orange", "apple"} {
        set[value] = struct{}{}
    }

又比如是否置位：

    seen := make(map[string]struct{})
    for _, ok := seen[v]; !ok {
        // First time visiting a vertex.
        seen[v] = struct{}{}
    }

这里的value也不占空间，如果用bool起码占一个字节，同理可推，一些开关channel：

    ch := make(chan struct{})
    go worker(ch)
    
    // Send a message to a worker.
    ch <- struct{}{}
    
    // Receive a message from the worker.
    <-c

#### struct比较
当struct成员含有 map/slice/fun 时，不可以进行相等性比较，同时struct不可进行大小比较。
    

#### zero width 地址一致
zero width指其占用内存大小为0：

    type data struct {
    }

    func main() {
        a := &data{}
        b := &data{}
    
        if a == b {
            fmt.Printf("same address - a=%p b=%p\n",a,b)
            //prints: same address - a=0x1953e4 b=0x1953e4
        }
    }


#### 空struct有多大

	type S struct{}

	s := S{}
	fmt.Printf("S size is %d \n", unsafe.Sizeof(s))

大小为0

#### struct为空

一个 `s := TypeOfStruct{}` 如何判断为空， 一种是增加一个empty的方法。或者让其
与 `TypeOfStruct{}`做比较，前提条件是每个成员都是可比较的。

## Hack 101
### 1. method and interface

#### fmt.Println实际上调用了对象的`String() string` 方法

    package main

    import (
        "fmt"
    )

    type Orange struct {
        Quantity int
    }

    func (o *Orange) Increase(n int) {
        o.Quantity += n
    }

    func (o *Orange) Decrease(n int) {
        o.Quantity -= n
    }

    func (o *Orange) String() string {
        return fmt.Sprintf("it is %v", o.Quantity)
    }

    func main() {
        var orange Orange
        orange.Increase(12)
        orange.Decrease(5)
        fmt.Println(orange)
    }

这里输出的是"{7}"。如果将"String() string"方法改为：


    func (o Orange) String() string {
        return fmt.Sprintf("it is %v", o.Quantity)
    }

结果就变成了：

    it is 7

因为这里origin是个struct 而不是指针。同时指针的方法是可以给struct用的。
