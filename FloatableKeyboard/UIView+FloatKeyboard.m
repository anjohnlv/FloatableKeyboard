//
//  UIView+FloatKeyboard.m
//  keyboardDemo
//
//  Created by anjohnlv on 2017/8/11.
//  Copyright © 2017年 anjohnlv. All rights reserved.
//

#import "UIView+FloatKeyboard.h"
#import <objc/runtime.h>

static const BOOL kDefalutFloatable = YES;
static const void *kFloatableKey    = @"floatableKey";

@implementation UIView (FloatKeyboard)

//category不能直接重写init方法，这里使用了方法替换
+(void)load {
    [self swizzlingInClass:self originalSelector:@selector(init) swizzledSelector:@selector(initSwizzling)];
    [self swizzlingInClass:self originalSelector:@selector(initWithFrame:) swizzledSelector:@selector(initSwizzlingWithFrame:)];
}

+(void)swizzlingInClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Class class = cls;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

-(instancetype)initSwizzling {
    self = [self initSwizzling];
    if (self) {
        [self setFloatable:kDefalutFloatable];
    }
    return self;
}

-(instancetype)initSwizzlingWithFrame:(CGRect)frame {
    self = [self initSwizzlingWithFrame:frame];
    if (self) {
        [self setFloatable:kDefalutFloatable];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setFloatable:kDefalutFloatable];
}

- (BOOL)floatable {
    return [objc_getAssociatedObject(self, kFloatableKey) boolValue];
}

- (void)setFloatable:(BOOL)floatable {
    objc_setAssociatedObject(self, kFloatableKey, [NSNumber numberWithBool:floatable], OBJC_ASSOCIATION_ASSIGN);
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat screenHeight = [[[UIApplication sharedApplication]keyWindow]bounds].size.height;
    CGFloat selfBottom = [self.superview convertRect:self.frame toView:[self viewController].view].origin.y + self.frame.size.height;
    CGFloat offset = selfBottom+keyboardHeight-screenHeight;
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            [self viewController].view.frame = CGRectMake(0.0f, -offset, [self viewController].view.frame.size.width, [self viewController].view.frame.size.height);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self viewController].view.frame = CGRectMake(0, 0, [self viewController].view.frame.size.width, [self viewController].view.frame.size.height);
    }];
}

- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

-(BOOL)becomeFirstResponder {
    if (self.floatable) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder {
    BOOL b = [super resignFirstResponder];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    return b;
}

@end

