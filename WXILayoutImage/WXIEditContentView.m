//
//  WXIEditContentView.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/12.
//  Copyright © 2016年 wuxi. All rights reserved.
//

//5个小view的tag分别为51--55

#import <Photos/Photos.h>
#import "WXIEditContentView.h"
#import "WXISmallEditView.h"
typedef NS_ENUM(NSInteger, SmallEditViewBoarder){
    SmallEditViewBoarderNone,
    SmallEditViewBoarderTop,
    SmallEditViewBoarderLeft,
    SmallEditViewBoarderDown,
    SmallEditViewBoarderRight
};

static const NSInteger kSmallViewInitTag = 51;

static CGFloat kMinWidth = 48;
static CGFloat kMinHeight = 48;

@interface WXIEditContentView ()<WXISmallEditViewDelegate>
//移动交换中间变量
@property (nonatomic, strong)WXISmallEditView *tempView;

//@property (nonatomic, retain)NSMutableArray *currentViewArray;

@property (nonatomic, assign)CGFloat leftTopX;
@property (nonatomic, assign)CGFloat leftTopY;
@property (nonatomic, assign)CGFloat rightDownX;
@property (nonatomic, assign)CGFloat rightDownY;

@property (nonatomic, assign)CGRect originalFrame;
//@property (nonatomic, assign)CGFloat scaleRation;
@property (nonatomic, assign)BOOL reachSmallest;

@end

@implementation WXIEditContentView

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
        self.firstView = [[WXISmallEditView alloc] initWithFrame:CGRectZero];
        self.secondView = [[WXISmallEditView alloc] initWithFrame:CGRectZero];
        self.thirdView = [[WXISmallEditView alloc] initWithFrame:CGRectZero];
        self.fourthView = [[WXISmallEditView alloc] initWithFrame:CGRectZero];
        self.fifthView = [[WXISmallEditView alloc] initWithFrame:CGRectZero];
        self.sixthView = [[WXISmallEditView alloc] initWithFrame:CGRectZero];
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
        
        _firstView.tag = kSmallViewInitTag;
        _secondView.tag = kSmallViewInitTag + 1;
        _thirdView.tag = kSmallViewInitTag + 2;
        _fourthView.tag = kSmallViewInitTag + 3;
        _fifthView.tag = kSmallViewInitTag + 4;
        _sixthView.tag = kSmallViewInitTag + 5;
        
        [self addSubview:_firstView];
        [self addSubview:_secondView];
        [self addSubview:_thirdView];
        [self addSubview:_fourthView];
        [self addSubview:_fifthView];
        [self addSubview:_sixthView];
        
        
        [self addTapGesture];
//        self.scaleRation = 1.f;
//        self.currentViewArray = [NSMutableArray array];
        
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
//重置smallEditView样式
- (void)styleSettingWithView:(WXISmallEditView *)view
{
    view.frame = CGRectZero;
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor clearColor];
    [view setImageViewData:nil];
    view.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressView:)];
    [view addGestureRecognizer:longPressGesture];
    
}
//从plist文件读取样式
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
- (void)addTapGesture
{
    UITapGestureRecognizer *tapGesture_one = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture_one.numberOfTapsRequired = 1;
    [self.firstView addGestureRecognizer:tapGesture_one];
    
    UITapGestureRecognizer *tapGesture_two = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture_two.numberOfTapsRequired = 1;
    [self.secondView addGestureRecognizer:tapGesture_two];
    
    UITapGestureRecognizer *tapGesture_three = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture_three.numberOfTapsRequired = 1;
    [self.thirdView addGestureRecognizer:tapGesture_three];
    
    UITapGestureRecognizer *tapGesture_four = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture_four.numberOfTapsRequired = 1;
    [self.fourthView addGestureRecognizer:tapGesture_four];
    
    UITapGestureRecognizer *tapGesture_five = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture_five.numberOfTapsRequired = 1;
    [self.fifthView addGestureRecognizer:tapGesture_five];
    
    UITapGestureRecognizer *tapGesture_six = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture_six.numberOfTapsRequired = 1;
    [self.sixthView addGestureRecognizer:tapGesture_six];
    
}

//点击里面的view
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    [self setValue:[NSNumber numberWithInteger:gesture.view.tag - kSmallViewInitTag] forKey:@"smallViewIndex"];

    [self.firstView clearInnerBoarder];
    [self.secondView clearInnerBoarder];
    [self.thirdView clearInnerBoarder];
    [self.fourthView clearInnerBoarder];
    [self.fifthView clearInnerBoarder];
    [self.sixthView clearInnerBoarder];
    
    WXISmallEditView *smallEditView = (WXISmallEditView *)gesture.view;
    [smallEditView drawInnerBoarder];
    //移除其他的提示拖动边框
    [self removeBoarderMiddleView:self.firstView];
    [self removeBoarderMiddleView:self.secondView];
    [self removeBoarderMiddleView:self.thirdView];
    [self removeBoarderMiddleView:self.fourthView];
    [self removeBoarderMiddleView:self.fifthView];
    [self removeBoarderMiddleView:self.sixthView];
    //加入粗提示拖动边框
    [self drawBoarderMiddleView:smallEditView];
}
- (void)drawBoarderMiddleView:(WXISmallEditView *)smallEditView
{
    self.leftTopX = self.frame.origin.x;
    self.leftTopY = self.frame.origin.y;
    self.rightDownX = CGRectGetMaxX(self.frame);
    self.rightDownY = CGRectGetMaxY(self.frame);
    if (smallEditView.frame.size.width == 0 || smallEditView.frame.size.height == 0)
    {
        return;
    }
    if (smallEditView.frame.origin.x != self.leftTopX)
    {
        smallEditView.leftMiddleView.backgroundColor = [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00];
    }
    if (smallEditView.frame.origin.y != self.leftTopY)
    {
        smallEditView.topMiddleView.backgroundColor = [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00];
    }
    if (CGRectGetMaxX(smallEditView.frame) != self.rightDownX)
    {
        smallEditView.rightMiddleView.backgroundColor = [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00];
    }
    if (CGRectGetMaxY(smallEditView.frame) != self.rightDownY)
    {
        smallEditView.bottomMiddleView.backgroundColor = [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00];
    }
}
- (void)removeBoarderMiddleView:(WXISmallEditView *)smallEditView
{
    smallEditView.leftMiddleView.backgroundColor = [UIColor clearColor];
    smallEditView.rightMiddleView.backgroundColor = [UIColor clearColor];
    smallEditView.topMiddleView.backgroundColor = [UIColor clearColor];
    smallEditView.bottomMiddleView.backgroundColor = [UIColor clearColor];
}
/**
 *  替换图片，修改frame
 */
- (void)resetStyle
{
    if(_styleDict)
    {
        PHImageRequestOptions * requestOption = [[PHImageRequestOptions alloc] init];
        requestOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        CGSize superSize = CGSizeFromString([[_styleDict objectForKey:@"SuperViewInfo"] objectForKey:@"size"]);
        superSize = [WXIEditContentView sizeScaleWithSize:superSize scale:2.0f];
        NSArray *subViewArray = [_styleDict objectForKey:@"SubViewArray"];
        if (self.photoAsset.count < subViewArray.count)
        {
            NSInteger difference = subViewArray.count - self.photoAsset.count;
            for (NSInteger i = 0; i < difference; i++) {
                PHAsset *asset = self.photoAsset.lastObject;
                [self.photoAsset addObject:asset];
            }
        }
        for(NSInteger j = 0; j < subViewArray.count; j++)
        {
            CGRect rect = CGRectZero;
            UIBezierPath *path = nil;
            PHAsset *asset = [self.photoAsset objectAtIndex:j];
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
                            point = [WXIEditContentView pointScaleWithPoint:point scale:2.0f];
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
                WXISmallEditView *smallEditView = (WXISmallEditView *)[_contentViewArray objectAtIndex:j];
                smallEditView.frame = rect;
//                smallEditView.tag = [[subDict objectForKey:@"ViewTag"] integerValue];
                smallEditView.topArray = [[[subDict objectForKey:@"Top"] componentsSeparatedByString:@","] mutableCopy];
                smallEditView.leftArray = [[[subDict objectForKey:@"Left"] componentsSeparatedByString:@","] mutableCopy];
                smallEditView.bottomArray = [[[subDict objectForKey:@"Bottom"] componentsSeparatedByString:@","] mutableCopy];
                smallEditView.rightArray = [[[subDict objectForKey:@"Right"] componentsSeparatedByString:@","] mutableCopy];
                smallEditView.backgroundColor = [UIColor clearColor];
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(350, 350) contentMode:PHImageContentModeAspectFill options:requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    [smallEditView setImageViewData:result rect:rect];
                }];
                smallEditView.oldRect = rect;
            }
        }
    }
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
    rect = [WXIEditContentView rectScaleWithRect:rect scale:2.0f];
    rect.origin.x = rect.origin.x * self.frame.size.width/superSize.width;
    rect.origin.y = rect.origin.y * self.frame.size.height/superSize.height;
    rect.size.width = rect.size.width * self.frame.size.width/superSize.width;
    rect.size.height = rect.size.height * self.frame.size.height/superSize.height;
    return rect;
    
}

- (void)tapWithEditView:(WXISmallEditView *)sender
{
    if (_moveDelegate && [_moveDelegate respondsToSelector:@selector(movedEditView)]) {
        [_moveDelegate movedEditView];
    }
}
#pragma mark gesture
//长按换位
- (void)handleLongPressView:(UILongPressGestureRecognizer *)gesture
{
    WXISmallEditView *btn = (WXISmallEditView *)gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _startPoint = [gesture locationInView:gesture.view];
        _originPoint = btn.center;
        [self bringSubviewToFront:btn];
        [UIView animateWithDuration:0.2f animations:^{
            
            btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
            btn.alpha = 0.7;
        }];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint newPoint = [gesture locationInView:gesture.view];
        CGFloat deltaX = newPoint.x-_startPoint.x;
        CGFloat deltaY = newPoint.y-_startPoint.y;
        btn.center = CGPointMake(btn.center.x+deltaX,btn.center.y+deltaY);
        NSInteger index = [self indexOfPoint:btn.center withButton:btn];
        if (index<0)
        {
            _contain = NO;
            _tempView = nil;
        }
        else
        {
            if (index != -1)
            {
                _tempView = _contentViewArray[index];
                //修改选中为移动位置后的那个
                [self setValue:[NSNumber numberWithInteger:index] forKey:@"smallViewIndex"];
                
            }
        }
    }else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            btn.transform = CGAffineTransformIdentity;
            btn.alpha = 1.0;
            if (!_contain)
            {
                if (_tempView) {
                    [self exchangeFromIndex:btn.tag-kSmallViewInitTag toIndex:_tempView.tag-kSmallViewInitTag];
                    [self changeSelectedBoarder:gesture];
                }else{
                    
                    [btn setNotReloadFrame:btn.oldRect];
                }
            }
            _tempView = nil;
        }];
    }

}
- (void)changeSelectedBoarder:(UILongPressGestureRecognizer *)gesture
{
    [self.firstView clearInnerBoarder];
    [self.secondView clearInnerBoarder];
    [self.thirdView clearInnerBoarder];
    [self.fourthView clearInnerBoarder];
    [self.fifthView clearInnerBoarder];
    [self.sixthView clearInnerBoarder];
    
    WXISmallEditView *smallEditView = (WXISmallEditView *)gesture.view;
    [smallEditView drawInnerBoarder];
    //移除其他的提示拖动边框
    [self removeBoarderMiddleView:self.firstView];
    [self removeBoarderMiddleView:self.secondView];
    [self removeBoarderMiddleView:self.thirdView];
    [self removeBoarderMiddleView:self.fourthView];
    [self removeBoarderMiddleView:self.fifthView];
    [self removeBoarderMiddleView:self.sixthView];
    //加入粗提示拖动边框
    [self drawBoarderMiddleView:smallEditView];
}
- (void)exchangeFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    PHImageRequestOptions * requestOption = [[PHImageRequestOptions alloc] init];
    requestOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    PHAsset *a = [_photoAsset objectAtIndex:fromIndex];
    PHAsset *b = [_photoAsset objectAtIndex:toIndex];
    
    [_photoAsset replaceObjectAtIndex:fromIndex withObject:b];
    [_photoAsset replaceObjectAtIndex:toIndex withObject:a];
    
    WXISmallEditView *fromView = [_contentViewArray objectAtIndex:fromIndex];
    WXISmallEditView *toView = [_contentViewArray objectAtIndex:toIndex];
    
    [_contentViewArray replaceObjectAtIndex:fromIndex withObject:toView];
    [_contentViewArray replaceObjectAtIndex:toIndex withObject:fromView];
    
    WXISmallEditView *ttView = [[WXISmallEditView alloc] init];
    ttView.oldRect = fromView.oldRect;
    ttView.tag = fromView.tag;
    ttView.topArray = fromView.topArray;
    ttView.leftArray = fromView.leftArray;
    ttView.bottomArray = fromView.bottomArray;
    ttView.rightArray = fromView.rightArray;

    
    fromView.frame = toView.oldRect;
    __block UIImage *image;
    [[PHImageManager defaultManager] requestImageForAsset:a targetSize:CGSizeMake(350, 350) contentMode:PHImageContentModeAspectFill options:requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {

        [fromView setImageViewData:result];
        image = result;
    }];
    [fromView setImageViewData:image rect:toView.oldRect];
    fromView.tag = toView.tag;
    fromView.oldRect = toView.oldRect;
    fromView.topArray = toView.topArray;
    fromView.leftArray = toView.leftArray;
    fromView.bottomArray = toView.bottomArray;
    fromView.rightArray = toView.rightArray;

    
    toView.frame = ttView.oldRect;
    __block UIImage *secondImage;
    [[PHImageManager defaultManager] requestImageForAsset:b targetSize:CGSizeMake(350, 350) contentMode:PHImageContentModeAspectFill options:requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {

        [toView setImageViewData:result];
        secondImage = result;
    }];
    //在主线程设置rect，否则会被修改
    [toView setImageViewData:secondImage rect:ttView.oldRect];
    toView.tag = ttView.tag;
    toView.oldRect = ttView.oldRect;
    toView.topArray = ttView.topArray;
    toView.leftArray = ttView.leftArray;
    toView.bottomArray = ttView.bottomArray;
    toView.rightArray = ttView.rightArray;
    ttView = nil;

}
- (NSInteger)indexOfPoint:(CGPoint)point withButton:(WXISmallEditView *)btn
{
    for (NSInteger i = 0;i<_contentViewArray.count;i++)
    {
        WXISmallEditView *button = _contentViewArray[i];
        if (button != btn)
        {
            if (CGRectContainsPoint(button.oldRect, point))
            {
                return i;
            }
        }
    }
    return -1;
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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self.currentViewArray removeAllObjects];
//    for (WXISmallEditView *smallEditView in self.contentViewArray)
//    {
//        if (smallEditView.frame.size.width + smallEditView.frame.size.height != 0)
//        {
//            [self.currentViewArray addObject:smallEditView];
//        }
//    }
    self.reachSmallest = NO;
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint prePoint = [touch previousLocationInView:self];
    CGFloat offset_X = point.x - prePoint.x;
    CGFloat offset_Y = point.y - prePoint.y;
    
    WXISmallEditView *currentView = [self viewAccordingToTag:touch.view.superview.tag];
    
    if (touch.view == currentView.rightBoarderView) {
        if ([currentView.rightArray[0] isEqualToString:@"0"])return;
        CGRect currentOldRect = currentView.frame;
        //太小直接返回禁止拖动
        if ((CGRectGetWidth(currentOldRect) <= kMinWidth) && (offset_X < 0))
        {
            currentOldRect.size.width = kMinWidth;
            currentView.frame = currentOldRect;
            currentView.oldRect = currentOldRect;
            return;
        }
        else
        {
            for (NSString * neighbor in currentView.rightArray)
            {
                if ([neighbor isEqualToString:@"0"]) {
                    break;
                }
                
                NSArray *component = [neighbor componentsSeparatedByString:@"."];
                WXISmallEditView *neighborView = [self viewAccordingToTag:[component[0] integerValue]];
                CGRect neighborRect = neighborView.frame;
                switch ([component[1] integerValue]) {
                    case SmallEditViewBoarderTop:
                        break;
                    case SmallEditViewBoarderLeft:
                        if (CGRectGetWidth(neighborRect) <= kMinWidth && (offset_X > 0))
                        {
                            neighborRect.size.width = kMinWidth;
                            neighborView.frame = neighborRect;
                            neighborView.oldRect = neighborRect;
                            self.reachSmallest = YES;
                            break;
                        }
                        
                        break;
                    case SmallEditViewBoarderDown:
                        break;
                    case SmallEditViewBoarderRight:
                        if (CGRectGetWidth(neighborRect) <= kMinWidth && (offset_X < 0))
                        {
                            neighborRect.size.width = kMinWidth;
                            neighborView.frame = neighborRect;
                            neighborView.oldRect = neighborRect;
                            self.reachSmallest = YES;
                            break;
                        }
                        break;
                    default:
                        break;
                }
                if (self.reachSmallest)
                {
                    break;
                }
            }
            if (self.reachSmallest)return;
        }
        
        currentOldRect.size.width += offset_X;
        if (CGRectGetWidth(currentOldRect) < kMinWidth && (offset_X < 0))
        {
            currentOldRect.size.width = kMinWidth;
        }
        currentView.frame = currentOldRect;
        currentView.oldRect = currentOldRect;
        //更新邻居
        for (NSString * neighbor in currentView.rightArray) {
            if ([neighbor isEqualToString:@"0"])break;

            NSArray *component = [neighbor componentsSeparatedByString:@"."];
            WXISmallEditView *neighborView = [self viewAccordingToTag:[component[0] integerValue]];
            CGRect neighborRect = neighborView.frame;
            if (CGRectGetHeight(neighborRect) < kMinWidth)
            {
                neighborRect.size.height = kMinWidth;
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
            }
            switch ([component[1] integerValue]) {
                case SmallEditViewBoarderTop:
                    //顶部
                    break;
                case SmallEditViewBoarderLeft:
                    //左边
                    neighborRect = CGRectMake(CGRectGetMaxX(currentOldRect), CGRectGetMinY(neighborView.frame), CGRectGetWidth(neighborView.frame) - offset_X, CGRectGetHeight(neighborView.frame));
                    if (CGRectGetWidth(neighborRect) < kMinWidth && (offset_X > 0))
                    {
                        neighborRect.size.width = kMinWidth;
                        neighborView.frame = neighborRect;
                        neighborView.oldRect = neighborRect;
                        
                        currentOldRect = CGRectMake(CGRectGetMinX(currentView.frame), CGRectGetMinY(currentView.frame), CGRectGetMinX(neighborView.frame) - CGRectGetMinX(currentView.frame), CGRectGetHeight(currentView.frame));
                        currentView.frame = currentOldRect;
                        currentView.oldRect = currentOldRect;
                    }
                    break;
                case SmallEditViewBoarderDown:
                    //底部
                    break;
                case SmallEditViewBoarderRight:
                    //右边
                    neighborRect = CGRectMake(CGRectGetMinX(neighborView.frame), CGRectGetMinY(neighborView.frame), CGRectGetWidth(neighborView.frame) + offset_X, CGRectGetHeight(neighborView.frame));
                    if (CGRectGetWidth(neighborRect) < kMinWidth && (offset_X < 0))
                    {
                        neighborRect.size.width = kMinWidth;
                        neighborView.frame = neighborRect;
                        neighborView.oldRect = neighborRect;
                        
                        currentOldRect = CGRectMake(CGRectGetMinX(currentView.frame), CGRectGetMinY(currentView.frame), CGRectGetMaxX(neighborView.frame) - CGRectGetMinX(currentView.frame), CGRectGetHeight(currentView.frame));
                        currentView.frame = currentOldRect;
                        currentView.oldRect = currentOldRect;
                    }
                    break;
                default:
                    break;
            }
            if (CGRectGetWidth(neighborRect) < kMinWidth)
            {
                neighborRect.size.width = kMinWidth;
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
                return;
            }else
            {
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
            }

        }

    }
    if (touch.view == currentView.leftBoarderView) {
        if ([currentView.leftArray[0] isEqualToString:@"0"])return;
         CGRect currentOldRect = currentView.frame;
        //太小直接返回禁止拖动
        if ((CGRectGetWidth(currentOldRect) <= kMinWidth) && (offset_X > 0))
        {
            currentOldRect.size.width = kMinWidth;
            currentView.frame = currentOldRect;
            currentView.oldRect = currentOldRect;
            return;
        }
        else
        {
            for (NSString * neighbor in currentView.leftArray)
            {
                if ([neighbor isEqualToString:@"0"])
                {
                    break;
                }
                NSArray *component = [neighbor componentsSeparatedByString:@"."];
                WXISmallEditView *neighborView = [self viewAccordingToTag:[component[0] integerValue]];
                CGRect neighborRect = neighborView.frame;
                switch ([component[1] integerValue]) {
                    case SmallEditViewBoarderTop:
                        break;
                    case SmallEditViewBoarderLeft:
                        if (CGRectGetWidth(neighborRect) <= kMinWidth && (offset_X > 0))
                        {
                            neighborRect.size.width = kMinWidth;
                            neighborView.frame = neighborRect;
                            neighborView.oldRect = neighborRect;
                            self.reachSmallest = YES;
                            break;
                        }
                        break;
                    case SmallEditViewBoarderDown:
                        break;
                    case SmallEditViewBoarderRight:
                        if (CGRectGetWidth(neighborRect) <= kMinWidth && (offset_X < 0))
                        {
                            neighborRect.size.width = kMinWidth;
                            neighborView.frame = neighborRect;
                            neighborView.oldRect = neighborRect;
                            self.reachSmallest = YES;
                            break;
                        }
                        break;
                    default:
                        break;
                }
                if (self.reachSmallest)
                {
                    break;
                }
            }
            if (self.reachSmallest)return;
        }
        
        
        currentOldRect = CGRectMake(CGRectGetMinX(currentView.frame) + offset_X, CGRectGetMinY(currentView.frame), CGRectGetWidth(currentView.frame) - offset_X, CGRectGetHeight(currentView.frame));
        if (CGRectGetWidth(currentOldRect) < kMinWidth && (offset_X > 0))
        {
            currentOldRect.size.width = kMinWidth;
        }

        currentView.frame = currentOldRect;
        currentView.oldRect = currentOldRect;
        //更新邻居
        for (NSString * neighbor in currentView.leftArray) {
            if ([neighbor isEqualToString:@"0"])break;
            
            NSArray *component = [neighbor componentsSeparatedByString:@"."];
            WXISmallEditView *neighborView = [self viewAccordingToTag:[component[0] integerValue]];
            CGRect neighborRect = neighborView.frame;
            if (CGRectGetWidth(neighborRect) < kMinWidth)
            {
                neighborRect.size.width = kMinWidth;
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
            }
            if (CGRectGetWidth(neighborRect) < kMinWidth)return;
            switch ([component[1] integerValue]) {
                case SmallEditViewBoarderTop:
                    //顶部
                    break;
                case SmallEditViewBoarderLeft:
                    //左边
                    neighborRect = CGRectMake(CGRectGetMinX(currentView.frame), CGRectGetMinY(neighborView.frame), CGRectGetWidth(neighborView.frame) - offset_X, CGRectGetHeight(neighborView.frame));
                    if (CGRectGetWidth(neighborRect) < kMinWidth && (offset_X > 0))
                    {
                        neighborRect.size.width = kMinWidth;
                        neighborView.frame = neighborRect;
                        neighborView.oldRect = neighborRect;
                        
                        currentOldRect = CGRectMake(CGRectGetMinX(neighborView.frame), CGRectGetMinY(currentView.frame), CGRectGetMaxX(currentView.frame) - CGRectGetMinX(neighborView.frame), CGRectGetHeight(currentView.frame));
                        currentView.frame = currentOldRect;
                        currentView.oldRect = currentOldRect;
                    }
                    break;
                case SmallEditViewBoarderDown:
                    //底部
                    break;
                case SmallEditViewBoarderRight:
                    //右边
                    neighborRect = CGRectMake(CGRectGetMinX(neighborView.frame), CGRectGetMinY(neighborView.frame), CGRectGetWidth(neighborView.frame) + offset_X, CGRectGetHeight(neighborView.frame));
                    if (CGRectGetWidth(neighborRect) < kMinWidth && (offset_X < 0))
                    {
                        neighborRect.size.width = kMinWidth;
                        neighborView.frame = neighborRect;
                        neighborView.oldRect = neighborRect;
                        
                        currentOldRect = CGRectMake(CGRectGetMaxX(neighborView.frame), CGRectGetMinY(currentView.frame), CGRectGetMaxX(currentView.frame) - CGRectGetMaxX(neighborView.frame), CGRectGetHeight(currentView.frame));
                        currentView.frame = currentOldRect;
                        currentView.oldRect = currentOldRect;
                    }
                    break;
                default:
                    break;
            }
            if (CGRectGetWidth(neighborRect) < kMinWidth)
            {
                neighborRect.size.width = kMinWidth;
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
                return;
            }else
            {
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
            }
        }
    }
    if (touch.view == currentView.topBoarderView) {
        if ([currentView.topArray[0] isEqualToString:@"0"])return;
        CGRect currentOldRect = currentView.frame;
        //太小直接返回禁止拖动
        if ((CGRectGetHeight(currentOldRect) <= kMinHeight) && (offset_Y > 0))
        {
            currentOldRect.size.height = kMinHeight;
            currentView.frame = currentOldRect;
            currentView.oldRect = currentOldRect;
            return;
        }
        else
        {
            for (NSString * neighbor in currentView.topArray)
            {
                if ([neighbor isEqualToString:@"0"])
                {
                    break;
                }
                NSArray *component = [neighbor componentsSeparatedByString:@"."];
                WXISmallEditView *neighborView = [self viewAccordingToTag:[component[0] integerValue]];
                CGRect neighborRect = neighborView.frame;
                switch ([component[1] integerValue]) {
                    case SmallEditViewBoarderTop:
                        if (CGRectGetHeight(neighborRect) <= kMinHeight && (offset_Y > 0))
                        {
                            neighborRect.size.height = kMinHeight;
                            neighborView.frame = neighborRect;
                            neighborView.oldRect = neighborRect;
                            self.reachSmallest = YES;
                            break;
                        }
                        break;
                    case SmallEditViewBoarderLeft:
                        break;
                    case SmallEditViewBoarderDown:
                        if (CGRectGetHeight(neighborRect) <= kMinHeight && (offset_Y < 0))
                        {
                            neighborRect.size.height = kMinHeight;
                            neighborView.frame = neighborRect;
                            neighborView.oldRect = neighborRect;
                            self.reachSmallest = YES;
                            break;
                        }
                        break;
                    case SmallEditViewBoarderRight:
                        break;
                    default:
                        break;
                }
                if (self.reachSmallest)
                {
                    break;
                }
            }
            if (self.reachSmallest)return;
        }
        
        currentOldRect = CGRectMake(CGRectGetMinX(currentView.frame), CGRectGetMinY(currentView.frame) + offset_Y, CGRectGetWidth(currentView.frame), CGRectGetHeight(currentView.frame) - offset_Y);
        if (CGRectGetHeight(currentOldRect) < kMinHeight)
        {
            currentOldRect.size.height = kMinHeight;
        }
        currentView.frame = currentOldRect;
        currentView.oldRect = currentOldRect;
        //更新邻居
        for (NSString * neighbor in currentView.topArray) {
            if ([neighbor isEqualToString:@"0"])break;
            
            NSArray *component = [neighbor componentsSeparatedByString:@"."];
            WXISmallEditView *neighborView = [self viewAccordingToTag:[component[0] integerValue]];
            CGRect neighborRect = neighborView.frame;
            if (CGRectGetHeight(neighborRect) < kMinHeight)
            {
                neighborRect.size.height = kMinHeight;
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
            }
            if (CGRectGetWidth(neighborRect) < kMinHeight)return;
            switch ([component[1] integerValue]) {
                case SmallEditViewBoarderTop:
                    //顶部
                    neighborRect = CGRectMake(CGRectGetMinX(neighborView.frame), CGRectGetMinY(neighborView.frame) + offset_Y, CGRectGetWidth(neighborView.frame), CGRectGetHeight(neighborView.frame) - offset_Y);
                    if (CGRectGetHeight(neighborRect) < kMinHeight && (offset_Y > 0))
                    {
                        neighborRect.size.height = kMinHeight;
                        neighborView.frame = neighborRect;
                        neighborView.oldRect = neighborRect;
                        
                        currentOldRect = CGRectMake(CGRectGetMinX(currentView.frame), CGRectGetMinY(neighborView.frame), CGRectGetWidth(currentView.frame), CGRectGetMaxY(currentView.frame) - CGRectGetMinY(neighborView.frame));
                        currentView.frame = currentOldRect;
                        currentView.oldRect = currentOldRect;
                    }
                    break;
                case SmallEditViewBoarderLeft:
                    //左边
                    break;
                case SmallEditViewBoarderDown:
                    //底部
                    neighborRect = CGRectMake(CGRectGetMinX(neighborView.frame), CGRectGetMinY(neighborView.frame), CGRectGetWidth(neighborView.frame), CGRectGetHeight(neighborView.frame) + offset_Y);
                    if (CGRectGetHeight(neighborRect) < kMinHeight && (offset_Y < 0))
                    {
                        neighborRect.size.height = kMinHeight;
                        neighborView.frame = neighborRect;
                        neighborView.oldRect = neighborRect;
                        
                        currentOldRect = CGRectMake(CGRectGetMinX(currentView.frame), CGRectGetMaxY(neighborView.frame), CGRectGetWidth(currentView.frame), CGRectGetMaxY(currentView.frame) - CGRectGetMaxY(neighborView.frame));
                        currentView.frame = currentOldRect;
                        currentView.oldRect = currentOldRect;
                    }
                    break;
                case SmallEditViewBoarderRight:
                    //右边
                    break;
                default:
                    break;
            }
            if (CGRectGetHeight(neighborRect) < kMinHeight)
            {
                neighborRect.size.height = kMinHeight;
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
                return;
            }else
            {
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
            }
            
        }
    }
    if (touch.view == currentView.bottomBoarderView) {
        if ([currentView.bottomArray[0] isEqualToString:@"0"])return;
        CGRect currentOldRect = currentView.frame;
        //太小直接返回禁止拖动
        if ((CGRectGetHeight(currentOldRect) <= kMinHeight) && (offset_Y < 0))
        {
            currentOldRect.size.height = kMinHeight;
            currentView.frame = currentOldRect;
            currentView.oldRect = currentOldRect;
            return;
        }
        else
        {
            for (NSString * neighbor in currentView.bottomArray)
            {
                if ([neighbor isEqualToString:@"0"])break;
                NSArray *component = [neighbor componentsSeparatedByString:@"."];
                WXISmallEditView *neighborView = [self viewAccordingToTag:[component[0] integerValue]];
                CGRect neighborRect = neighborView.frame;
                switch ([component[1] integerValue]) {
                    case SmallEditViewBoarderTop:
                        if (CGRectGetHeight(neighborRect) <= kMinHeight && (offset_Y > 0))
                        {
                            neighborRect.size.height = kMinHeight;
                            neighborView.frame = neighborRect;
                            neighborView.oldRect = neighborRect;
                            self.reachSmallest = YES;
                            break;
                        }
                        break;
                    case SmallEditViewBoarderLeft:
                        break;
                    case SmallEditViewBoarderDown:
                        if (CGRectGetHeight(neighborRect) <= kMinHeight && (offset_Y < 0))
                        {
                            neighborRect.size.height = kMinHeight;
                            neighborView.frame = neighborRect;
                            neighborView.oldRect = neighborRect;
                            self.reachSmallest = YES;
                            break;
                        }
                        break;
                    case SmallEditViewBoarderRight:
                        break;
                    default:
                        break;
                }
                if (self.reachSmallest)
                {
                    break;
                }
            }
            if (self.reachSmallest)return;
        }
        
        currentOldRect.size.height += offset_Y;
        if (CGRectGetHeight(currentOldRect) < kMinHeight)
        {
            currentOldRect.size.height = kMinHeight;
        }
        
        currentView.frame = currentOldRect;
        currentView.oldRect = currentOldRect;
        //更新邻居
        for (NSString * neighbor in currentView.bottomArray) {
            if ([neighbor isEqualToString:@"0"])break;
            
            NSArray *component = [neighbor componentsSeparatedByString:@"."];
            WXISmallEditView *neighborView = [self viewAccordingToTag:[component[0] integerValue]];
            CGRect neighborRect = neighborView.frame;
            if (CGRectGetHeight(neighborRect) < kMinHeight)
            {
                neighborRect.size.height = kMinHeight;
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
            }
            if (CGRectGetWidth(neighborRect) < kMinHeight)return;
            switch ([component[1] integerValue]) {
                case SmallEditViewBoarderTop:
                    //顶部
                    neighborRect = CGRectMake(CGRectGetMinX(neighborView.frame), CGRectGetMinY(neighborView.frame) + offset_Y, CGRectGetWidth(neighborView.frame), CGRectGetHeight(neighborView.frame) - offset_Y);
                    if (CGRectGetHeight(neighborRect) < kMinHeight && (offset_Y > 0))
                    {
                        neighborRect.size.height = kMinHeight;
                        neighborView.frame = neighborRect;
                        neighborView.oldRect = neighborRect;
                        
                        currentOldRect = CGRectMake(CGRectGetMinX(currentView.frame), CGRectGetMinY(currentView.frame), CGRectGetWidth(currentView.frame), CGRectGetMinY(neighborView.frame) - CGRectGetMinY(currentView.frame));
                        currentView.frame = currentOldRect;
                        currentView.oldRect = currentOldRect;
                    }
                    break;
                case SmallEditViewBoarderLeft:
                    //左边
                    break;
                case SmallEditViewBoarderDown:
                    //底部
                    neighborRect = CGRectMake(CGRectGetMinX(neighborView.frame), CGRectGetMinY(neighborView.frame), CGRectGetWidth(neighborView.frame), CGRectGetHeight(neighborView.frame) + offset_Y);
                    if (CGRectGetHeight(neighborRect) < kMinHeight && (offset_Y < 0))
                    {
                        neighborRect.size.height = kMinHeight;
                        neighborView.frame = neighborRect;
                        neighborView.oldRect = neighborRect;
                        
                        currentOldRect = CGRectMake(CGRectGetMinX(currentView.frame), CGRectGetMinY(currentView.frame), CGRectGetWidth(currentView.frame), CGRectGetMaxY(neighborView.frame) - CGRectGetMinY(currentView.frame));
                        currentView.frame = currentOldRect;
                        currentView.oldRect = currentOldRect;
                    }
                    break;
                case SmallEditViewBoarderRight:
                    //右边
                    break;
                default:
                    break;
            }
            if (CGRectGetHeight(neighborRect) < kMinHeight)
            {
                neighborRect.size.height = kMinHeight;
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
                return;
            }else
            {
                neighborView.frame = neighborRect;
                neighborView.oldRect = neighborRect;
            }
            
            
        }
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}
- (WXISmallEditView *)viewAccordingToTag:(NSInteger)tag
{
    self.firstView = self.contentViewArray[0];
    self.secondView = self.contentViewArray[1];
    self.thirdView = self.contentViewArray[2];
    self.fourthView = self.contentViewArray[3];
    self.fifthView = self.contentViewArray[4];
    self.sixthView = self.contentViewArray[5];
    switch (tag) {
        case 51:
            return self.firstView;
            break;
        case 52:
            return self.secondView;
            break;
        case 53:
            return self.thirdView;
            break;
        case 54:
            return self.fourthView;
            break;
        case 55:
            return self.fifthView;
            break;
        case 56:
            return self.sixthView;
            break;
        default:
            return nil;
            break;
    }
}
//- (BOOL)hasViewReachToSmallSize:(NSMutableArray *)currentViewArray
//{
//    for (WXISmallEditView *smallEditView in currentViewArray) {
//        if (CGRectGetWidth(smallEditView.frame) == kMinWidth)
//        {
//            return YES;
//        }
//        if (CGRectGetHeight(smallEditView.frame) == kMinHeight)
//        {
//            
//            return YES;
//        }
//    }
//    return NO;
//}

@end
