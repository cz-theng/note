#Chapter 1: Getting Started with View Animations

## UIView动画的基本方法

函数原型：

​	

​	animateWithDuration(_:animations:)

通过这几个方法可以对View对象进行动画设置。



## 动画可以设置的View的属性

* bounds
* frame
* center
* backgroundColor
* alpha
* transforma

## 动画可以设置一些选项

### 动画重复设置

* Repeat : 重复播放动画
* Autoreverse :  和上面的配合使用，当播放完一次后反方向回到原来位置后再次重复

### 启停速度设置

* Linear : 线性匀速
* CurveEaseIn ： 在开始的时候从0逐渐加速到v
* CurveEaseOut ： 在结束的时候从v逐渐减速到0
* CurveEaseInOut ： 先慢慢加速到v然后快停止的时候从v减速到0



