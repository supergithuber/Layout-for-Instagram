//
//  WXICollectionReusableView.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/8.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "WXICollectionReusableView.h"

@implementation WXICollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.button.titleLabel.font = [UIFont systemFontOfSize:15];
        self.button.titleLabel.textColor = [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00];
        self.backgroundColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.19 alpha:1.00];
        [self addSubview:self.button];
    }
    return self;
}
@end
