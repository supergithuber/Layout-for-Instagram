//
//  WXIEditViewController.h
//  WXILayoutImage
//
//  Created by wuxi on 16/8/9.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXIPhotoTool.h"

@interface WXIEditViewController : UIViewController

@property (nonatomic, assign)NSInteger tag;
//放选中的PHAsset对象
@property (nonatomic, retain)NSMutableArray *selectedAssetsArray;
//选中的相册集
@property (nonatomic, retain)WXIPhotoAblumList *photoAlbum;

@end
