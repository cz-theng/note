Chapter 2: Springs

说白了就是能够像弹簧一样，移动到头的时候，来回震动几次。

## 方法
	
	// Swift
	class func animate(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIViewAnimationOptions = [], animations: @escaping () -> Swift.Void, completion: (@escaping (Bool) -> Swift.Void)? = nil)
	
	// OC
	+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(7_0);

主要通过这个方法来实现View的弹性动画。

* usingSpringWithDamping： 弹性，或者叫硬度，1的话就不弹了
* initialSpringVelocity：初始的速度的倍数，0-1.0之间

