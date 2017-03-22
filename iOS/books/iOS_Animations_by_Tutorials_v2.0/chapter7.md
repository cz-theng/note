Chapter 7: Animating Constraints
修改了view的contraints之后，要在 `UIView.animate`系列函数中调用`view.layoutIfNeeded()`方法来更新UI。


## constraints
view都有constraints属性为NSLayoutConstraint的数组。用来表示AutoLayout的限制。

![](./images/autolayout_formula.png)