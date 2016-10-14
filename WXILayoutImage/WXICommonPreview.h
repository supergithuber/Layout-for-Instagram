//
//  WXICommonPreview.h
//  WXILayoutImage
//
//  Created by wuxi on 16/8/23.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXICommonPreview : UIView

@property (nonatomic, strong)UIImageView *firstView;
@property (nonatomic, strong)UIImageView *secondView;
@property (nonatomic, strong)UIImageView *thirdView;
@property (nonatomic, strong)UIImageView *fourthView;
@property (nonatomic, strong)UIImageView *fifthView;
@property (nonatomic, strong)UIImageView *sixthView;

//传AssetItem过来
@property (nonatomic, strong)NSMutableArray   *photoAsset;
@property (nonatomic, strong)NSString         *styleFileName;
//某个数量下的小style对应的tag
@property (nonatomic, assign)NSInteger         styleTag;
@property (nonatomic, strong)NSDictionary     *styleDict;
//存放view的array
@property (nonatomic, strong)NSMutableArray *contentViewArray;

+ (CGRect)rectScaleWithRect:(CGRect)rect scale:(CGFloat)scale;
+ (CGPoint)pointScaleWithPoint:(CGPoint)point scale:(CGFloat)scale;
+ (CGSize)sizeScaleWithSize:(CGSize)size scale:(CGFloat)scale;
- (void)resetStyle;
- (instancetype)initWithFrame:(CGRect)frame tag:(NSInteger)tag;


@end
