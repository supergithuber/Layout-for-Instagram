//
//  WXIEditButton.h
//  WXILayoutImage
//
//  Created by wuxi on 16/8/10.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXIEditButton : UIView

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)UIImage *buttonImage;
@property (nonatomic, strong)UIButton *button;

- (void)disableClick;
- (void)enableClick;
@end
