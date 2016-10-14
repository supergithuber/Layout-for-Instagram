//
//  WXISmallEditView.h
//  WXILayoutImage
//
//  Created by wuxi on 16/8/11.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <UIKit/UIKit.h>

//用于调整大小的锚点
typedef enum {
    kNone = 0,
    kTop = 1,
    kLeft = 2,
    kBottom = 3 ,
    kRight = 4
}Direction;

@interface Neighbor : NSObject

@property (nonatomic, assign)NSInteger tag;
@property (nonatomic, assign)Direction direction;

@end

//调整大小的delegate
@protocol WXISmallEditViewResizableDelegate;


@interface WXISmallEditView : UIView<UIScrollViewDelegate>

@property (nonatomic, retain)UIScrollView *contentView;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, assign)CGRect oldRect;

//四个相邻信息
@property (nonatomic, retain)NSMutableArray *topArray;
@property (nonatomic, retain)NSMutableArray *leftArray;
@property (nonatomic, retain)NSMutableArray *bottomArray;
@property (nonatomic, retain)NSMutableArray *rightArray;

//调整frame的属性
@property (nonatomic, strong)UIView *topBoarderView;//最上部用于检测手势
@property (nonatomic, strong)UIView *rightBoarderView;
@property (nonatomic, strong)UIView *bottomBoarderView;
@property (nonatomic, strong)UIView *leftBoarderView;

//最后加上内部边框时用的layer
@property (nonatomic, strong)UIView *topBoarderLayer;
@property (nonatomic, strong)UIView *rightBoarderLayer;
@property (nonatomic, strong)UIView *bottomBoarderLayer;
@property (nonatomic, strong)UIView *leftBoarderLayer;
//中间的粗边框，在外层判断
@property (nonatomic, strong)UIView *topMiddleView;
@property (nonatomic, strong)UIView *rightMiddleView;
@property (nonatomic, strong)UIView *bottomMiddleView;
@property (nonatomic, strong)UIView *leftMiddleView;

@property (nonatomic, assign)CGFloat minWidth;
@property (nonatomic, assign)CGFloat minHeight;
@property (nonatomic, weak)id<WXISmallEditViewResizableDelegate> resizeDelegate;

- (void)setImageViewData:(UIImage *)imageData;
- (void)setImageViewData:(UIImage *)imageData rect:(CGRect)rect;
- (void)setNotReloadFrame:(CGRect)frame;
//添加和删除内部选中边框方法
- (void)drawInnerBoarder;
- (void)clearInnerBoarder;

@end

@protocol WXISmallEditViewDelegate <NSObject>

- (void)tapWithEditView:(WXISmallEditView *)sender;

@end

@protocol WXISmallEditViewResizableDelegate <NSObject>
//触摸起始时调用
- (void)smallEditViewDidBeginEditing:(WXISmallEditView *)smallEditView;
//触摸结束时调用
- (void)smallEditViewDidEndEditing:(WXISmallEditView *)smallEditView;

//- (void)smallEditViewWillChangeWidth:(CGFloat)width;

@end
