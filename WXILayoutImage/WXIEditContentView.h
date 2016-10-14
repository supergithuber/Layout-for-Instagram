//
//  WXIEditContentView.h
//  WXILayoutImage
//
//  Created by wuxi on 16/8/12.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXISmallEditView;

@protocol WXIEditContentViewDelegate;

@interface WXIEditContentView : UIView
{
    BOOL _contain;
    CGPoint _startPoint;
    CGPoint _originPoint;
}

@property (nonatomic, strong)WXISmallEditView *firstView;
@property (nonatomic, strong)WXISmallEditView *secondView;
@property (nonatomic, strong)WXISmallEditView *thirdView;
@property (nonatomic, strong)WXISmallEditView *fourthView;
@property (nonatomic, strong)WXISmallEditView *fifthView;
@property (nonatomic, strong)WXISmallEditView *sixthView;

//传PHAsset过来
@property (nonatomic, strong)NSMutableArray   *photoAsset;

@property (nonatomic, strong)NSString         *styleFileName;
//某个数量下的小style对应的tag
@property (nonatomic, assign)NSInteger         styleTag;
@property (nonatomic, strong)NSDictionary     *styleDict;
//被选中的WXISmallEditView的index
@property (nonatomic, assign)NSInteger smallViewIndex;
//存放view的array
@property (nonatomic, strong)NSMutableArray *contentViewArray;

@property (nonatomic, weak)id<WXIEditContentViewDelegate> moveDelegate;


+ (CGRect)rectScaleWithRect:(CGRect)rect scale:(CGFloat)scale;
+ (CGPoint)pointScaleWithPoint:(CGPoint)point scale:(CGFloat)scale;
+ (CGSize)sizeScaleWithSize:(CGSize)size scale:(CGFloat)scale;
- (void)resetStyle;
- (instancetype)initWithFrame:(CGRect)frame tag:(NSInteger)tag;

- (void)drawBoarderMiddleView:(WXISmallEditView *)smallEditView;
- (void)removeBoarderMiddleView:(WXISmallEditView *)smallEditView;
@end

@protocol  WXIEditContentViewDelegate <NSObject>

- (void)movedEditView;

@end
