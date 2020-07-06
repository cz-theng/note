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
> When ranging over a slice, two values are returned for each iteration. The first is the index, and the second is a copy of the element at that index.

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

