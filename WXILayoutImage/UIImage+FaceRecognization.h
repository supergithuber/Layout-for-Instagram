//
//  UIImage+FaceRecognization.h
//  WXILayoutImage
//
//  Created by wuxi on 16/9/1.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FaceRecognization)

/**
 *  @return 有效人脸个数
 */
- (NSInteger)totalNumberOfFacesByFaceRecognition;
/**
 *  如果没有人脸返回CGRectNull
 *  @return 人脸的bounds
 */
- (CGRect)rectOfFace;
/**
 *  依据给定的size返回更合适的区域大小
 *
 *  @param size     给定的size
 *
 *  @return 合适的人脸区域大小
 */
- (CGRect)rectOfFaceFocusingOnRect:(CGSize)size;
@end
