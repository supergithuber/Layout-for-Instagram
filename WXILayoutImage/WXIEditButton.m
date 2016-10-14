//
//  WXIEditButton.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/10.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "WXIEditButton.h"

@interface WXIEditButton ()

@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation WXIEditButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self addSubview:self.button];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.textColor = [UIColor whiteColor];
        
        self.button.layer.cornerRadius = 10.f;
        self.button.clipsToBounds = YES;
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.button.frame = CGRectMake(0, 0, width, height*2/3.f);
    self.titleLabel.frame = CGRectMake(0, height*2/3.f, width, height/3.f);
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}
- (void)setButtonImage:(UIImage *)buttonImage
{
    [self.button setImage:[buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
}
- (NSString *)title
{
    return self.titleLabel.text;
}
- (void)disableClick
{
    [self.button setUserInteractionEnabled:NO];
    self.button.alpha = 0.5;
    self.titleLabel.alpha = 0.5;
}
- (void)enableClick
{
    [self.button setUserInteractionEnabled:YES];
    self.button.alpha = 1;
    self.titleLabel.alpha = 1;
}
@end
