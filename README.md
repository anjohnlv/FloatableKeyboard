# FloatableKeyboard

这份代码能够让你轻松实现可浮动的文本输入框。

使用方法：

1、下载UIView+FloatKeyboard.h与UIView+FloatKeyboard.m，并导入工程。

2、在需要浮动的地方引入头#import "UIView+FloatKeyboard.h"

如果有部分的控件不需要浮动，可以设置该控件view.floatable = NO;
如果大部分都不需要浮动，可以修改category中kDefalutFloatable = NO;，然后单独设置需要浮动的view.floatable = YES;

这个小工具支持UITextField,UITextView,以及其他需要获取焦点进行交互的控件。
支持autolayout，autosizing，支持代码，也支持interface builder。
如果有什么bug欢迎斧正。

![screenshot](https://github.com/anjohnlv/FloatableKeyboard/blob/master/FloatableKeyboard/screenshot.gif?raw=true)
