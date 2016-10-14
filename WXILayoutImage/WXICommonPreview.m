//
//  WXICommonPreview.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/23.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <Photos/Photos.h>
#import "WXICommonPreview.h"
#import "UIImageView+FaceAwareFill.h"
#import "AssetItem.h"
@interface WXICommonPreview ()

@end

@implementation WXICommonPreview

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame tag:0];
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame tag:(NSInteger)tag
{
    if (self = [super initWithFrame:frame])
    {
        self.styleTag = tag;
        self.backgroundColor = [UIColor clearColor];
        self.firstView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.secondView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.thirdView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.fourthView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.fifthView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.sixthView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self resetAllView];
        
        if (self.contentViewArray == nil)
        {
            self.contentViewArray = [NSMutableArray array];
        }
        
        [_contentViewArray addObject:_firstView];
        [_contentViewArray addObject:_secondView];
        [_contentViewArray addObject:_thirdView];
        [_contentViewArray addObject:_fourthView];
        [_contentViewArray addObject:_fifthView];
        [_contentViewArray addObject:_sixthView];
        
        [self addSubview:_firstView];
        [self addSubview:_secondView];
        [self addSubview:_thirdView];
        [self addSubview:_fourthView];
        [self addSubview:_fifthView];
        [self addSubview:_sixthView];
        
        
    }
    return self;
}
- (void)resetAllView
{
    [self styleSettingWithView:_firstView];
    [self styleSettingWithView:_secondView];
    [self styleSettingWithView:_thirdView];
    [self styleSettingWithView:_fourthView];
    [self styleSettingWithView:_fifthView];
    [self styleSettingWithView:_sixthView];
}
- (void)styleSettingWithView:(UIImageView *)imageView
{
    imageView.frame = CGRectZero;
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = nil;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.userInteractionEnabled = YES;
}
//设置styleTag，要设置photoAsset
- (void)setStyleTag:(NSInteger)styleTag
{
    _styleTag = styleTag;
    _styleFileName = nil;
    NSString *picCountFlag = @"";
    switch (_photoAsset.count) {
        case 1:
            picCountFlag = @"one";
            break;
        case 2:
            picCountFlag = @"two";
            break;
        case 3:
            picCountFlag = @"three";
            break;
        case 4:
            picCountFlag = @"four";
            break;
        case 5:
            picCountFlag = @"five";
            break;
        case 6:
            picCountFlag = @"six";
            break;
        default:
            break;
    }
    if (![picCountFlag isEqualToString:@""]) {
        _styleFileName = [NSString stringWithFormat:@"%@_style_%li",picCountFlag,_styleTag];
        _styleDict = nil;
        _styleDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_styleFileName ofType:@"plist"]];
        if (_styleDict) {
            [self resetAllView];
            [self resetStyle];
            
        }
    }
}
- (void)resetStyle
{
    if(_styleDict)
    {
        PHImageRequestOptions * requestOption = [[PHImageRequestOptions alloc] init];
        requestOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        CGSize superSize = CGSizeFromString([[_styleDict objectForKey:@"SuperViewInfo"] objectForKey:@"size"]);
        superSize = [WXICommonPreview sizeScaleWithSize:superSize scale:2.0f];
        NSArray *subViewArray = [_styleDict objectForKey:@"SubViewArray"];
        if (self.photoAsset.count < subViewArray.count)
        {
            NSInteger difference = subViewArray.count - self.photoAsset.count;
            for (NSInteger i = 0; i < difference; i++) {
                AssetItem *item = self.photoAsset.lastObject;
                [self.photoAsset addObject:item];
            }
        }
        for(NSInteger j = 0; j < subViewArray.count; j++)
        {
            CGRect rect = CGRectZero;
            UIBezierPath *path = nil;
            AssetItem *item = [self.photoAsset objectAtIndex:j];
            NSDictionary *subDict = [subViewArray objectAtIndex:j];
            rect = [self rectWithArray:[subDict objectForKey:@"pointArray"] andSuperSize:superSize];
            if ([subDict objectForKey:@"pointArray"])
            {
                NSArray *pointArray = [subDict objectForKey:@"pointArray"];
                path = [UIBezierPath bezierPath];
                if (pointArray.count > 2) {//当点的数量大于2个的时候
                    //生成点的坐标
                    for(int i = 0; i < [pointArray count]; i++)
                    {
                        NSString *pointString = [pointArray objectAtIndex:i];
                        if (pointString) {
                            CGPoint point = CGPointFromString(pointString);
                            point = [WXICommonPreview pointScaleWithPoint:point scale:2.0f];
                            point.x = (point.x)*self.frame.size.width/superSize.width -rect.origin.x;
                            point.y = (point.y)*self.frame.size.height/superSize.height -rect.origin.y;
                            if (i == 0) {
                                [path moveToPoint:point];
                            }else{
                                [path addLineToPoint:point];
                            }
                        }
                        
                    }
                }else{
                    //当点的左边不能形成一个面的时候  至少三个点的时候 就是一个正规的矩形
                    //点的坐标就是rect的四个角
                    [path moveToPoint:CGPointMake(0, 0)];
                    [path addLineToPoint:CGPointMake(rect.size.width, 0)];
                    [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
                    [path addLineToPoint:CGPointMake(0, rect.size.height)];
                }
                [path closePath];
            }
            if (j < [_contentViewArray count]) {
                UIImageView *imageView = (UIImageView *)[_contentViewArray objectAtIndex:j];
                imageView.frame = rect;
                imageView.backgroundColor = [UIColor clearColor];
                [[PHImageManager defaultManager] requestImageForAsset:item.asset targetSize:CGSizeMake(150, 150) contentMode:PHImageContentModeAspectFill options:requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    imageView.image = result;
                    if (item.isFaced)
                    {
                        //让人脸居中
                        [imageView faceAwareFillWithRect:item.facesRect];
                    }
                }];
                
            }
        }
    }
}
+ (CGSize)sizeScaleWithSize:(CGSize)size scale:(CGFloat)scale
{
    if (scale<=0) {
        scale = 1.0f;
    }
    CGSize retSize = CGSizeZero;
    retSize.width = size.width/scale;
    retSize.height = size.height/scale;
    return  retSize;
}
+ (CGPoint)pointScaleWithPoint:(CGPoint)point scale:(CGFloat)scale
{
    if (scale<=0) {
        scale = 1.0f;
    }
    CGPoint retPointt = CGPointZero;
    retPointt.x = point.x/scale;
    retPointt.y = point.y/scale;
    return  retPointt;
}
+ (CGRect)rectScaleWithRect:(CGRect)rect scale:(CGFloat)scale
{
    if (scale<=0) {
        scale = 1.0f;
    }
    CGRect retRect = CGRectZero;
    retRect.origin.x = rect.origin.x/scale;
    retRect.origin.y = rect.origin.y/scale;
    retRect.size.width = rect.size.width/scale;
    retRect.size.height = rect.size.height/scale;
    return  retRect;
}
/**
 *  计算frame 超出范围的等比缩小成相应大小
 *
 */
- (CGRect)rectWithArray:(NSArray *)array andSuperSize:(CGSize)superSize
{
    CGRect rect = CGRectZero;
    CGFloat minX = INT_MAX;
    CGFloat maxX = 0;
    CGFloat minY = INT_MAX;
    CGFloat maxY = 0;
    for (int i = 0; i < [array count]; i++) {
        NSString *pointString = [array objectAtIndex:i];
        CGPoint point = CGPointFromString(pointString);
        if (point.x <= minX) {
            minX = point.x;
        }
        if (point.x >= maxX) {
            maxX = point.x;
        }
        if (point.y <= minY) {
            minY = point.y;
        }
        if (point.y >= maxY) {
            maxY = point.y;
        }
        rect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    }
    rect = [WXICommonPreview rectScaleWithRect:rect scale:2.0f];
    rect.origin.x = rect.origin.x * self.frame.size.width/superSize.width;
    rect.origin.y = rect.origin.y * self.frame.size.height/superSize.height;
    rect.size.width = rect.size.width * self.frame.size.width/superSize.width;
    rect.size.height = rect.size.height * self.frame.size.height/superSize.height;
    return rect;
    
}

@end
