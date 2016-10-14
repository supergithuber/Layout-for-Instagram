//
//  WXISelectLayoutView.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/9.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "WXISelectLayoutView.h"

const NSInteger kSelectLabelHeight = 55;
const NSInteger kScrollViewHeight = 150;

@interface WXISelectLayoutView ()

@property (nonatomic, strong)UILabel *label;

@end

@implementation WXISelectLayoutView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.label = [[UILabel alloc] init];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.17 alpha:1.00];
        self.label.alpha = 0.97;
        [self addSubview:self.label];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.backgroundColor = [UIColor whiteColor];
        self.cancelButton.layer.cornerRadius = 20;
        [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        self.cancelButton.alpha = 0.97;
        [self addSubview:self.cancelButton];
        
        self.scroller = [[UIScrollView alloc] init];
        self.scroller.showsHorizontalScrollIndicator = NO;
        self.scroller.alpha = 0.97;
        [self addSubview:self.scroller];
    }
    return self;
}

- (void)didMoveToSuperview
{
    // 当数据已经发生改变的时候，你要执行reload方法。当增加HorizontalScroller到另外一个视图的时候，你也需要调用reload方法。
    [self reload];
    
}
- (void)reload
{
    if (self.dataSource == nil) return;
    CGFloat sWidth = [[UIScreen mainScreen] bounds].size.width;
    self.scroller.frame = CGRectMake(0, kSelectLabelHeight, sWidth, 155);
    self.scroller.backgroundColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.17 alpha:1.00];
    [self.scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [obj removeFromSuperview];
        
    }];
    //间隔20
    CGFloat offset = 20;
    CGFloat xPosition = offset;
    for (int i = 0; i < [_dataSource numberOfViewsForSelectLayoutView:self]; i++) {
        UIView *view = [self.dataSource selectLayoutView:self viewAtIndex:i];
        view.frame = CGRectMake(xPosition, 0, kScrollViewHeight, kScrollViewHeight);
        [self.scroller addSubview:view];
        xPosition += (kScrollViewHeight + offset);
    }
    self.scroller.scrollEnabled = YES;
    [self.scroller setContentSize:CGSizeMake(xPosition + 70, kScrollViewHeight)];
    
    self.label.frame = CGRectMake(0, 0, sWidth, kSelectLabelHeight);
    
    self.cancelButton.frame = CGRectMake(10, 10, 35, 35);
    
}
#pragma mark setter and getter
- (void)setTitle:(NSString *)title
{
    self.label.text = title;
}
- (NSString *)title
{
    return self.label.text;
}
@end
