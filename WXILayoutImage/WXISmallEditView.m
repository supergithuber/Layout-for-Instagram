//
//  WXISmallEditView.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/11.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "WXISmallEditView.h"
#import "AllDefine.h"
#import "Masonry.h"

#import "UIImage+FaceRecognization.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

const CGFloat kWXISmallEditViewGlobalInset = 15.f;
const NSInteger kWXISmallEditViewSelectedBorderWidth = 4;
const CGFloat kWXISmallEditViewInnerBoarderWidth = 2;

@interface WXISmallEditView ()

@property (nonatomic, assign)CGSize originalContentSize;
@property (nonatomic, assign)CGRect originalImageViewFrame;
@property (nonatomic, assign)CGSize originalSize;

@end

@implementation WXISmallEditView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initImageView];
        [self setupDefaultAttributes];
//        [self addMasConstraints];
    }
    return self;
}

- (void)initImageView
{
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectInset(self.bounds, 0, 0)];
    _contentView.delegate = self;
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.showsVerticalScrollIndicator = NO;
    [self addSubview:_contentView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.userInteractionEnabled = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_contentView addSubview:_imageView];
    
    CGFloat minimumScale = self.frame.size.width / _imageView.frame.size.width;
    _contentView.minimumZoomScale = minimumScale;
    _contentView.zoomScale = minimumScale;
    
    
    //最后加上borderView
    _topBoarderView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 0, 0)];
    _rightBoarderView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 0, 0)];
    _bottomBoarderView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 0, 0)];
    _leftBoarderView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 0, 0)];
    [self addSubview:_topBoarderView];
    [self addSubview:_rightBoarderView];
    [self addSubview:_bottomBoarderView];
    [self addSubview:_leftBoarderView];
    
    //四个用于呈现内边框的layer
    _topBoarderLayer = [UIView new];
    self.topBoarderLayer.userInteractionEnabled = NO;
    [self addSubview:_topBoarderLayer];
    _rightBoarderLayer = [UIView new];
    self.rightBoarderLayer.userInteractionEnabled = NO;
    [self addSubview:_rightBoarderLayer];
    _bottomBoarderLayer = [UIView new];
    self.bottomBoarderLayer.userInteractionEnabled = NO;
    [self addSubview:_bottomBoarderLayer];
    _leftBoarderLayer = [UIView new];
    self.leftBoarderLayer.userInteractionEnabled = NO;
    [self addSubview:_leftBoarderLayer];
    
    //四个顶部中间的view
    self.topMiddleView = [UIView new];
    self.rightMiddleView = [UIView new];
    self.bottomMiddleView = [UIView new];
    self.leftMiddleView = [UIView new];
    
    self.topMiddleView.layer.cornerRadius = 5;
    self.rightMiddleView.layer.cornerRadius = 5;
    self.bottomMiddleView.layer.cornerRadius = 5;
    self.leftMiddleView.layer.cornerRadius = 5;
    
    self.topMiddleView.userInteractionEnabled = NO;
    self.rightMiddleView.userInteractionEnabled = NO;
    self.bottomMiddleView.userInteractionEnabled = NO;
    self.leftMiddleView.userInteractionEnabled = NO;
    

    [self addSubview:_topMiddleView];
    [self addSubview:_rightMiddleView];
    [self addSubview:_bottomMiddleView];
    [self addSubview:_leftMiddleView];
    
}

- (void)setupDefaultAttributes
{
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
}
- (void)addMasConstraints
{
//    WS(ws);
//    [self.rightBoarderLayer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(kWXISmallEditViewInnerBoarderWidth);
//        make.height.mas_equalTo(ws.frame.size.height);
//        make.top.right.bottom.equalTo(ws);
//    }];
//    [self.topBoarderLayer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(ws.frame.size.width);
//        make.height.mas_equalTo(kWXISmallEditViewInnerBoarderWidth);
//        make.left.top.right.equalTo(ws);
//    }];
//    [self.leftBoarderLayer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(kWXISmallEditViewInnerBoarderWidth);
//        make.height.mas_equalTo(ws.frame.size.height);
//        make.left.top.bottom.equalTo(ws);
//    }];
//    [self.bottomBoarderLayer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(ws.frame.size.width);
//        make.height.mas_equalTo(kWXISmallEditViewInnerBoarderWidth);
//        make.left.bottom.right.equalTo(ws);
//    }];
}
- (void)setFrame:(CGRect)frame
{
    //重新设置frame
    [super setFrame:frame];
    _contentView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    //后期缩放时
    if (self.originalContentSize.width != 0)
    {
        if (frame.size.width > self.imageView.frame.size.width)
        {
            CGFloat widthRation = frame.size.width / self.imageView.frame.size.width;
            _imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width * widthRation, self.imageView.frame.size.height);
            _contentView.contentSize = CGSizeMake(_imageView.frame.size.width+1, _imageView.frame.size.height+1);
        }
        if(frame.size.height > self.imageView.frame.size.height)
        {
            CGFloat heightRation = frame.size.height / self.imageView.frame.size.height;
            _imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height * heightRation);
            _contentView.contentSize = CGSizeMake(_imageView.frame.size.width+1, _imageView.frame.size.height+1);
        }
        if (frame.size.width < self.imageView.frame.size.width && frame.size.width > self.originalImageViewFrame.size.width)
        {
            CGFloat widthRation = frame.size.width / self.imageView.frame.size.width;
            _imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width * widthRation, self.imageView.frame.size.height);
            _contentView.contentSize = CGSizeMake(_imageView.frame.size.width+1, _imageView.frame.size.height+1);
        }
        if (frame.size.height < self.imageView.frame.size.height && frame.size.height > self.originalImageViewFrame.size.height)
        {
            CGFloat heightRation = frame.size.height / self.imageView.frame.size.height;
            _imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height * heightRation);
            _contentView.contentSize = CGSizeMake(_imageView.frame.size.width+1, _imageView.frame.size.height+1);
        }
    }

    _contentView.minimumZoomScale = 1.2;
    _contentView.maximumZoomScale = 3.8;

    //boarderView的frame
    self.topBoarderView.frame = CGRectMake(0, 0, self.bounds.size.width - kWXISmallEditViewGlobalInset, kWXISmallEditViewGlobalInset);
    self.rightBoarderView.frame = CGRectMake(self.bounds.size.width - kWXISmallEditViewGlobalInset, 0, kWXISmallEditViewGlobalInset, self.bounds.size.height - kWXISmallEditViewGlobalInset);
    self.bottomBoarderView.frame = CGRectMake(kWXISmallEditViewGlobalInset, self.bounds.size.height - kWXISmallEditViewGlobalInset, self.bounds.size.width - kWXISmallEditViewGlobalInset, kWXISmallEditViewGlobalInset);
    self.leftBoarderView.frame = CGRectMake(0, kWXISmallEditViewGlobalInset, kWXISmallEditViewGlobalInset, self.bounds.size.height - kWXISmallEditViewGlobalInset);

    //改变frame时重置layer的frame
    self.topBoarderLayer.frame = CGRectMake(0, 0, self.frame.size.width, kWXISmallEditViewInnerBoarderWidth);
    self.rightBoarderLayer.frame = CGRectMake(self.frame.size.width - kWXISmallEditViewInnerBoarderWidth, 0, kWXISmallEditViewInnerBoarderWidth, self.frame.size.height);
    self.bottomBoarderLayer.frame = CGRectMake(0, self.frame.size.height - kWXISmallEditViewInnerBoarderWidth, self.frame.size.width, kWXISmallEditViewInnerBoarderWidth);
    self.leftBoarderLayer.frame = CGRectMake(0.0f, 0.0f, kWXISmallEditViewInnerBoarderWidth, self.frame.size.height);
    
    //四个边中间的view
    self.topMiddleView.frame = CGRectMake(CGRectGetMaxX(self.bounds)/4.f, -kWXISmallEditViewSelectedBorderWidth, CGRectGetWidth(self.bounds)/2.f, kWXISmallEditViewSelectedBorderWidth * 2);
    self.rightMiddleView.frame = CGRectMake(CGRectGetMaxX(self.bounds) - kWXISmallEditViewSelectedBorderWidth, CGRectGetMaxY(self.bounds)/4.f, kWXISmallEditViewSelectedBorderWidth * 2, CGRectGetHeight(self.bounds)/2.f);
    self.bottomMiddleView.frame = CGRectMake(CGRectGetMaxX(self.bounds)/4.f, CGRectGetMaxY(self.bounds) - kWXISmallEditViewSelectedBorderWidth, CGRectGetWidth(self.bounds)/2.f, kWXISmallEditViewSelectedBorderWidth * 2);
    self.leftMiddleView.frame = CGRectMake(-kWXISmallEditViewSelectedBorderWidth, CGRectGetMaxY(self.bounds)/4.f, kWXISmallEditViewSelectedBorderWidth * 2, CGRectGetHeight(self.bounds)/2.f);
    
}

- (void)setNotReloadFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)setImageViewData:(UIImage *)imageData rect:(CGRect)rect
{
    self.frame = rect;
    [self setImageViewData:imageData];
}

- (void)setImageViewData:(UIImage *)imageData
{
    _imageView.image = imageData;
    if (imageData == nil)
    {
        return;
    }
    
    CGRect rect = CGRectZero;
//    CGFloat scale = 1.0f;
    CGFloat width = 0.f;
    CGFloat height = 0.f;
    if (self.contentView.frame.size.width > self.contentView.frame.size.height)
    {
        width = self.contentView.frame.size.width;
        height = width * imageData.size.height/imageData.size.width;
        if(height < self.contentView.frame.size.height){
            height = self.contentView.frame.size.height;
            width = height*imageData.size.width/imageData.size.height;
        }
    }else
    {
        height = self.contentView.frame.size.height;
        width = height*imageData.size.width/imageData.size.height;
        if(width < self.contentView.frame.size.width){
            width = self.contentView.frame.size.width;
            height = width*imageData.size.height/imageData.size.width;
        }
    }
    rect.size = CGSizeMake(width, height);
    
    @synchronized(self){
        _imageView.frame = rect;
        //太坑爹了！！！
        [_contentView setZoomScale:1.1 animated:YES];
        [self setNeedsLayout];
        self.originalContentSize = _contentView.contentSize;
        self.originalImageViewFrame = self.imageView.frame;
        self.originalSize = self.bounds.size;
//        NSLog(@"imageData%@", NSStringFromCGSize(imageData.size));
//        NSLog(@"contentsize%@",NSStringFromCGSize(_contentView.contentSize));
//        NSLog(@"contentoffset%@", NSStringFromCGPoint(_contentView.contentOffset));
//        NSLog(@"imageview%@", NSStringFromCGRect(_imageView.frame));
//        NSLog(@"self.frame%@",NSStringFromCGRect(self.frame));
//        NSLog(@"self.bounds%@",NSStringFromCGRect(self.bounds));
//        NSLog(@"-------");
    }

}

- (void)drawInnerBoarder
{
    self.leftBoarderLayer.backgroundColor = [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00];
    self.rightBoarderLayer.backgroundColor = [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00];
    self.topBoarderLayer.backgroundColor = [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00];
    self.bottomBoarderLayer.backgroundColor = [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00];
}
- (void)clearInnerBoarder
{
    self.leftBoarderLayer.backgroundColor = [UIColor clearColor];
    self.topBoarderLayer.backgroundColor = [UIColor clearColor];
    self.rightBoarderLayer.backgroundColor = [UIColor clearColor];
    self.bottomBoarderLayer.backgroundColor = [UIColor clearColor];
    
}
-(UIImage*)OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //如果是人脸
    UIImage *scaleImage = [self OriginImage:_imageView.image scaleToSize:_contentView.contentSize];
    CGRect facesRect = [scaleImage rectOfFace];
//    CGRect facesRect = [scaleImage rectOfFaceFocusingOnRect:self.bounds.size];
    if (CGRectIsNull(facesRect))
    {
        self.contentView.contentOffset = CGPointMake(self.contentView.contentSize.width / 2.f - self.bounds.size.width / 2.f, self.contentView.contentSize.height / 2.f - self.bounds.size.height / 2.f);
    }
    else
    {
        CGFloat offsetX = facesRect.origin.x + facesRect.size.width/2.f - self.bounds.size.width/2.f;
        CGFloat offsetY = facesRect.origin.y;
        CGFloat maxOffset_x = scaleImage.size.width - self.bounds.size.width;
        CGFloat maxOffset_y = scaleImage.size.height - self.bounds.size.height;
        offsetX = ((offsetX) > maxOffset_x) ? (maxOffset_x) : (offsetX);
        offsetY = ((offsetY) > maxOffset_y) ? (maxOffset_y) : (offsetY);
        
        offsetX = ((offsetX) < 0) ? (0) : (offsetX);
        offsetY = ((offsetY) < 0) ? (0) : (offsetY);
        self.contentView.contentOffset = CGPointMake(offsetX, offsetY);
        
    }

}
@end
