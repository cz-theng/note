# Uber的Style

## 实现interface的时候，做编译器check
Golang的接口实现实际上是一种Ducky接口，没有显示的设置说谁来实现什么接口，
如果某个类型要实现什么接口，那么只有自己去保障，如果接口变了，而实现没有修改，则
只会在使用的位置做接口类型转换的时候才会暴露出来。所以在书写阶段，我们通过显示
将结构类型的空值转换成目标接口，来提前做编译判断：

    type Handler struct {
    // ...
    }

    var _ http.Handler = (*Handler)(nil)

    func (h *Handler) ServeHTTP(
    w http.ResponseWriter,
    r *http.Request,
    ) {
    // ...
    }

这样，在涉嫌Handler的文件中，就可以在编译阶段知道其是否完整实现了接口。