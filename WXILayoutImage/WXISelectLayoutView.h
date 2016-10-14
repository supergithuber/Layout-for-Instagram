//
//  WXISelectLayoutView.h
//  WXILayoutImage
//
//  Created by wuxi on 16/8/9.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WXISelectLayoutViewDataSource;

@interface WXISelectLayoutView : UIView

@property (nonatomic, copy)NSString *title;
@property (nonatomic, strong)UIScrollView *scroller;
@property (nonatomic, strong)UIButton *cancelButton;

@property (nonatomic, weak)id<WXISelectLayoutViewDataSource> dataSource;

- (void)reload;

@end

@protocol WXISelectLayoutViewDataSource <NSObject>

//返回需要多少个内部view
- (NSInteger)numberOfViewsForSelectLayoutView:(WXISelectLayoutView *)selectLayoutView;
// 指定索引位置的视图
- (UIView *)selectLayoutView:(WXISelectLayoutView *)selectLayoutView viewAtIndex:(int)index;

@end
