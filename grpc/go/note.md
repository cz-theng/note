# gRPC

## 客户端

### 
客户端配置选项:

    type funcDialOption struct {
	    f func(*dialOptions)
    }

每个选项就是这么个结构，但是他有个apply函数，在这个apply里面才会真正执行上面的f，其实类似
一个懒加载，因此封装了"newFuncDialOption"传入一个f来构建上面这样的option。从而可以实现
对dialOptions的多次设置。

### 截断 hook服务器接口功能
在Client的Invoke中，有：

    	if cc.dopts.unaryInt != nil {
		    return cc.dopts.unaryInt(ctx, method, args, reply, cc, invoke, opts...)
        }
通选项来传入一个invoke的hook，直接截断对服务器的访问。	

### name resolution
name resolution 提供了一个"Register(b Builder)" 用于注册用户自己的name resolution。


#### builder

    // Builder creates a resolver that will be used to watch name resolution updates.
    type Builder interface {
        // Build creates a new resolver for the given target.
        //
        // gRPC dial calls Build synchronously, and fails if the returned error is
        // not nil.
        Build(target Target, cc ClientConn, opts BuildOptions) (Resolver, error)
        // Scheme returns the scheme supported by this resolver.
        // Scheme is defined at https://github.com/grpc/grpc/blob/master/doc/naming.md.
        Scheme() string
    }


一个全局的map保持了name-builder的对应关系。

    m = make(map[string]Builder)
注册的时候，就存在了这里。

#### resolver

    // Resolver watches for the updates on the specified target.
    // Updates include address updates and service config updates.
    type Resolver interface {
        // ResolveNow will be called by gRPC to try to resolve the target name
        // again. It's just a hint, resolver can ignore this if it's not necessary.
        //
        // It could be called multiple times concurrently.
        ResolveNow(ResolveNowOptions)
        // Close closes the resolver.
        Close()
    }


#### Address

    type Address struct {
        Addr string
        ServerName string
        Attributes *attributes.Attributes
    }

用于表示服务器的地址，相关信息通过属性来设置。

### log
通过SetLoggerV2可以对日志进行截断，截断器需要实现：

    // LoggerV2 does underlying logging work for grpclog.
    // This is a copy of the LoggerV2 defined in the external grpclog package. It
    // is defined here to avoid a circular dependency.
    type LoggerV2 interface {
        // Info logs to INFO log. Arguments are handled in the manner of fmt.Print.
        Info(args ...interface{})
        // Infoln logs to INFO log. Arguments are handled in the manner of fmt.Println.
        Infoln(args ...interface{})
        // Infof logs to INFO log. Arguments are handled in the manner of fmt.Printf.
        Infof(format string, args ...interface{})
        // Warning logs to WARNING log. Arguments are handled in the manner of fmt.Print.
        Warning(args ...interface{})
        // Warningln logs to WARNING log. Arguments are handled in the manner of fmt.Println.
        Warningln(args ...interface{})
        // Warningf logs to WARNING log. Arguments are handled in the manner of fmt.Printf.
        Warningf(format string, args ...interface{})
        // Error logs to ERROR log. Arguments are handled in the manner of fmt.Print.
        Error(args ...interface{})
        // Errorln logs to ERROR log. Arguments are handled in the manner of fmt.Println.
        Errorln(args ...interface{})
        // Errorf logs to ERROR log. Arguments are handled in the manner of fmt.Printf.
        Errorf(format string, args ...interface{})
        // Fatal logs to ERROR log. Arguments are handled in the manner of fmt.Print.
        // gRPC ensures that all Fatal logs will exit with os.Exit(1).
        // Implementations may also call os.Exit() with a non-zero exit code.
        Fatal(args ...interface{})
        // Fatalln logs to ERROR log. Arguments are handled in the manner of fmt.Println.
        // gRPC ensures that all Fatal logs will exit with os.Exit(1).
        // Implementations may also call os.Exit() with a non-zero exit code.
        Fatalln(args ...interface{})
        // Fatalf logs to ERROR log. Arguments are handled in the manner of fmt.Printf.
        // gRPC ensures that all Fatal logs will exit with os.Exit(1).
        // Implementations may also call os.Exit() with a non-zero exit code.
        Fatalf(format string, args ...interface{})
        // V reports whether verbosity level l is at least the requested verbose level.
        V(l int) bool
    }

而默认的日志，在提供glog可选的情况下，还通过golang/log来打印到stderr，同时golang/log
可以很好的支持DepthLogger，指定函数strace深度。

比较创新的地方是，用componentData封装了一个带有Tag的日志，然后在需要用的地方，用：

    var logger = grpclog.Component("core")

来引用这个带tag的日志模块。使用上直接用这个变量：

    logger.Warning("Adjusting keepalive ping interval to minimum period of 1s") 

也是一种思路，比直接import也不差。

### error
对于一些我们需要忽略的error可以通过这样的filter来过滤掉：

    var filterError = func(err error) error {
        if dnsErr, ok := err.(*net.DNSError); ok && !dnsErr.IsTimeout && !dnsErr.IsTemporary {
            // Timeouts and temporary errors should be communicated to gRPC to
            // attempt another DNS query (with backoff).  Other errors should be
            // suppressed (they may represent the absence of a TXT record).
            return nil
        }
        return err
    }

首先转换，然后对结果进行判断，如果是要过滤的错误，就直接return nil。

### grpcsync.Event

一个只会被执行一次的事件封装：

    type Event struct {
        fired int32
        c     chan struct{}
        o     sync.Once
    }

    func (e *Event) Fire() bool {
        ret := false
        e.o.Do(func() {
            atomic.StoreInt32(&e.fired, 1)
            close(e.c)
            ret = true
        })
        return ret
    }

    func NewEvent() *Event {
	    return &Event{c: make(chan struct{})}
    }


通过sync.Once.Do来保证 fired这个flag只被设置一次,后续就可以用他来做状态判断了，这里主要是
通过channel来做了通知，注意，这种情况，channel用 `c: make(chan struct{})`。
    
### 链接state管理
首先satat分为：

    const (
        Idle State = iota
        Connecting
        Ready
        TransientFailure
        Shutdown
    )

通过这个来做管理：

    type connectivityStateManager struct {
        mu         sync.Mutex
        state      connectivity.State
        notifyChan chan struct{}
        channelzID int64
    }

这里创新点再有`notifyChan chan struct{}` 可以用来做一个观察者模式，如果state更新了，
可以通知wait在这个channel上的观察者出select并重新获取state。

### encoder

encoder 作为编码器，其里面还包含了compresser压缩器

## 模式

### 1. Builder 

类比于工厂方法，通过Option来进行定制，通过Builder来Build出具体的对象
