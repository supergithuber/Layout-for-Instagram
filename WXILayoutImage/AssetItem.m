//
//  AssetItem.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/8.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "AssetItem.h"

@implementation AssetItem

- (instancetype)initWithPhasset:(PHAsset *)asset
{
    if (self = [super init])
    {
        self.asset = asset;
        self.selected = NO;
    }
    return self;
}

+ (instancetype)AsseItemWithPhasset:(PHAsset *)asset
{
    return [[self alloc]initWithPhasset:asset];
}
- (instancetype)copyWithZone:(NSZone *)zone
{
    AssetItem *copy = [[[self class] allocWithZone:zone] init];
    copy.selected = self.selected;
    copy.asset = self.asset;
    return copy;
}
@end
