//
//  UIImage+FaceRecognization.m
//  WXILayoutImage
//
//  Created by wuxi on 16/9/1.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "UIImage+FaceRecognization.h"

@implementation UIImage (FaceRecognization)

- (NSInteger)totalNumberOfFacesByFaceRecognition{
    CIContext * context = [CIContext contextWithOptions:nil];
    
    CIImage * cImage = [CIImage imageWithCGImage:self.CGImage];
    
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    
    NSArray * detectResult = [faceDetector featuresInImage:cImage];
    
    return detectResult.count;
}

- (CGRect)rectOfFace
{
    CIContext * context = [CIContext contextWithOptions:nil];
    
    CIImage * cImage = [CIImage imageWithCGImage:self.CGImage];
    
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    
    NSArray * detectResult = [faceDetector featuresInImage:cImage];
    CGRect faceRects = CGRectZero;
    if (detectResult.count == 0)
    {
        return CGRectNull;
    }
    faceRects = ((CIFaceFeature*)[detectResult objectAtIndex:0]).bounds;
    for (CIFaceFeature* faceFeature in detectResult) {
        faceRects = CGRectUnion(faceRects, faceFeature.bounds);
    }
    return faceRects;
}
- (CGRect)rectOfFaceFocusingOnRect:(CGSize)size
{
    CGRect faceRect = [self rectOfFace];
    if (CGRectEqualToRect(faceRect, CGRectNull))return CGRectNull;
    CGFloat multi1 = size.width / self.size.width;
    CGFloat multi2 = size.height / self.size.height;
    CGFloat multi = MAX(multi1, multi2);
    
    faceRect.origin.y = self.size.height - faceRect.origin.y - faceRect.size.height;
    faceRect = CGRectMake(faceRect.origin.x*multi, faceRect.origin.y*multi, faceRect.size.width*multi, faceRect.size.height*multi);
    return faceRect;
}
@end
