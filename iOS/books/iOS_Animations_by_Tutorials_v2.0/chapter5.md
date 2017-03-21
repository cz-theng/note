Chapter 5: Keyframe Animations

## 方法

	// Swift
	class func animateKeyframes(withDuration duration: TimeInterval, delay: TimeInterval, options: UIViewKeyframeAnimationOptions = [], animations: @escaping () -> Swift.Void, completion: (@escaping (Bool) -> Swift.Void)? = nil)
	class func addKeyframe(withRelativeStartTime frameStartTime: Double, relativeDuration frameDuration: Double, animations: @escaping () -> Swift.Void)
	
	// OC
	+ (void)animateKeyframesWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewKeyframeAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(7_0);
	+ (void)addKeyframeWithRelativeStartTime:(double)frameStartTime relativeDuration:(double)frameDuration animations:(void (^)(void))animations NS_AVAILABLE_IOS(7_0);

先调用	animateKeyframes创建一个帧动画，然后在里面通过addKeyframe设定每一帧。

`frameStartTime `和`relativeDuration`参数表示是总共时间duration的百分比，不是具体的时间单位。

## 选项

* UIViewKeyframeAnimationOptionLayoutSubviews            = UIViewAnimationOptionLayoutSubviews,
* UIViewKeyframeAnimationOptionAllowUserInteraction      = UIViewAnimationOptionAllowUserInteraction, // turn on user interaction while animating
* UIViewKeyframeAnimationOptionBeginFromCurrentState     = UIViewAnimationOptionBeginFromCurrentState, // start all views from current value, not initial value
* UIViewKeyframeAnimationOptionRepeat                    = UIViewAnimationOptionRepeat, // repeat animation indefinitely
* UIViewKeyframeAnimationOptionAutoreverse               = UIViewAnimationOptionAutoreverse, // if repeat, run animation back and forth
* UIViewKeyframeAnimationOptionOverrideInheritedDuration = UIViewAnimationOptionOverrideInheritedDuration, // ignore nested duration
* UIViewKeyframeAnimationOptionOverrideInheritedOptions  = UIViewAnimationOptionOverrideInheritedOptions, // do not inherit any options or animation type
* UIViewKeyframeAnimationOptionCalculationModeLinear     = 0 << 10, // default
* UIViewKeyframeAnimationOptionCalculationModeDiscrete   = 1 << 10,
* UIViewKeyframeAnimationOptionCalculationModePaced      = 2 << 10,
* UIViewKeyframeAnimationOptionCalculationModeCubic      = 3 << 10,
* UIViewKeyframeAnimationOptionCalculationModeCubicPaced = 4 << 10