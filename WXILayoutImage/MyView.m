//
//  MyView.m
//  WXILayoutImage
//
//  Created by wuxi on 16/9/6.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "MyView.h"
#import "UIView+AutoLayout.h"

//typedef enum {
//    kNone = 0,
//    kTop = 1,
//    kLeft = 2,
//    kBottom = 3 ,
//    kRight = 4
//}Direction;


@interface DirectionX : NSObject

@property (nonatomic, assign)int tag;
//@property (nonatomic, assign)Direction direction;

@end

@interface VInfo : NSObject
{
    
}

@property (nonatomic, assign) CGPoint point1;
@property (nonatomic, assign) CGPoint point2;
@property (nonatomic, assign) CGPoint point3;
@property (nonatomic, assign) CGPoint point4;

@property (nonatomic, assign) NSMutableArray *leftArray;
@property (nonatomic, assign) NSMutableArray *rightArray;
@property (nonatomic, assign) NSMutableArray *topArray;
@property (nonatomic, assign) NSMutableArray *bottomtArray;

@end

@implementation MyView

- (instancetype)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

//- (void)func {
//    NSArray *array;
//    for (VInfo *item in array) {
//        UIView *view = [UIView newAutoLayoutView];
//        [self addSubview:view];
//        view.tag = item.tag;
//    }
//    for (VInfo *item in array) {
//        UIView *view = [self viewWithTag:item.tag];
//        if (!view) {
//            return;
//        }
//        if (item.alignLeft == 0) {
//            [view autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
//        } else {
//            UIView *preView = nil;
//            for (UIView *sub in self.subviews) {
//                if (sub.tag == item.alignLeft) {
//                    preView = sub;
//                    break;
//                }
//            }
//            if (preView) {
//                [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:preView];
//            }
//            
//        }
//        
//        
//        if (item.alignTop == 0) {
//            [view autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
//        } else {
//            UIView *preView = nil;
//            for (UIView *sub in self.subviews) {
//                if (sub.tag == item.alignTop) {
//                    preView = sub;
//                    break;
//                }
//            }
//            if (preView) {
//                [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:preView];
//            }
//            
//        }
//        if (item.width == 0) {
//            [view autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
//        } else {
//            [view autoSetDimension:ALDimensionWidth toSize:item.width];
//        }
//      NSLayoutConstraint *lay =   [view autoSetDimension:ALDimensionHeight toSize:item.height];
//
//        
//    }
//}

@end
