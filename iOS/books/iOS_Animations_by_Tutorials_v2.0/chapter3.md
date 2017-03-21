Chapter 3: Transitions
专场动画，主要用在View的展现和消失的过程中。只是专场动画都是预先定义好的，我们只能去选择效果使用。 
## 方法

	// Swift3.0+
	class func transition(with view: UIView, duration: TimeInterval, options: UIViewAnimationOptions = [], animations: (@escaping () -> Swift.Void)?, completion: (@escaping (Bool) -> Swift.Void)? = nil)
	class func transition(from fromView: UIView, to toView: UIView, duration: TimeInterval, options: UIViewAnimationOptions = [], completion: (@escaping (Bool) -> Swift.Void)? = nil) 
	
	//OC
	+ (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(4_0); 
	+ (void)transitionWithView:(UIView *)view duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^ __nullable)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(4_0);

在Swift3之后有个API的改动，而3之前因为命名方式按照OC原来的接口，所以用了`transitionFromView `这里需要改变。

## 适用场景
* View出现的时候

比如addSubview

又比如View.hidden = true 

* View消失的时候

比如removeFromSuperview

又比如View.hidden =  false

## 预定义动画：options

* UIViewAnimationOptionLayoutSubviews            = 1 <<  0,
* UIViewAnimationOptionAllowUserInteraction      = 1 <<  1, // turn on user interaction while animating
* UIViewAnimationOptionBeginFromCurrentState     = 1 <<  2, // start all views from current value, not initial value
* UIViewAnimationOptionRepeat                    = 1 <<  3, // repeat animation indefinitely
* UIViewAnimationOptionAutoreverse               = 1 <<  4, // if repeat, run animation back and forth
* UIViewAnimationOptionOverrideInheritedDuration = 1 <<  5, // ignore nested duration
* UIViewAnimationOptionOverrideInheritedCurve    = 1 <<  6, // ignore nested curve
* UIViewAnimationOptionAllowAnimatedContent      = 1 <<  7, // animate contents (applies to transitions only)
* UIViewAnimationOptionShowHideTransitionViews   = 1 <<  8, // flip to/from hidden state instead of adding/removing
* UIViewAnimationOptionOverrideInheritedOptions  = 1 <<  9, // do not inherit any options or animation type
* UIViewAnimationOptionCurveEaseInOut            = 0 << 16, // default
* UIViewAnimationOptionCurveEaseIn               = 1 << 16,
* UIViewAnimationOptionCurveEaseOut              = 2 << 16,
* UIViewAnimationOptionCurveLinear               = 3 << 16,
* UIViewAnimationOptionTransitionNone            = 0 << 20, // default
* UIViewAnimationOptionTransitionFlipFromLeft    = 1 << 20,
* UIViewAnimationOptionTransitionFlipFromRight   = 2 << 20,
* UIViewAnimationOptionTransitionCurlUp          = 3 << 20,
* UIViewAnimationOptionTransitionCurlDown        = 4 << 20,
* UIViewAnimationOptionTransitionCrossDissolve   = 5 << 20,
* UIViewAnimationOptionTransitionFlipFromTop     = 6 << 20,
* UIViewAnimationOptionTransitionFlipFromBottom  = 7 << 20,

