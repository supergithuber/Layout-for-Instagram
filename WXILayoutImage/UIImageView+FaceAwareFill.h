//
//  UIImageView+FaceAwareFill.h
//  WXILayoutImage
//
//  Created by wuxi on 16/8/31.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (FaceAwareFill)

/**
 *  UIImageView调用这个方法会使得图片头像居中排列
 */
- (void) faceAwareFill;
/**
 *  已知人脸faceRect的时候
 *
 *  @param rect 人脸faceRect
 */
- (void)faceAwareFillWithRect:(CGRect)rect;
@end
