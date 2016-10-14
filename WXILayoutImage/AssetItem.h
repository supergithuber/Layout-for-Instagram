//
//  AssetItem.h
//  WXILayoutImage
//
//  Created by wuxi on 16/8/8.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface AssetItem : NSObject<NSCopying>

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL isFaced;
//提供用于在UIImageView中展示居中位置
@property (nonatomic, assign) CGRect facesRect;

- (instancetype)initWithPhasset:(PHAsset *)asset;
+ (instancetype)AsseItemWithPhasset:(PHAsset *)asset;

@end
