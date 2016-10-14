//
//  WXIPhotoTool.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/18.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "WXIPhotoTool.h"
#import "AllDefine.h"

static CIDetector* _faceDetector;

@implementation WXIPhotoAblumList

@end

@implementation WXIPhotoTool

static WXIPhotoTool *sharePhotoTool = nil;
+ (instancetype)sharePhotoTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [[self alloc] init];
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                           context:nil
                                           options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    });
    return sharePhotoTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [super allocWithZone:zone];
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                          context:nil
                                          options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    });
    return sharePhotoTool;
}

#pragma mark - 获取相册内所有照片资源
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    
    return assets;
}
#pragma mark - 获取所有相册列表
- (NSArray<WXIPhotoAblumList *> *)getPhotoAblumList
{
    NSMutableArray<WXIPhotoAblumList *> *photoAblumList = [NSMutableArray array];
    
    //获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        //过滤掉视频和最近删除
        if(collection.assetCollectionSubtype != 202 && collection.assetCollectionSubtype < 212){
            NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
            if (assets.count > 0) {
                WXIPhotoAblumList *ablum = [[WXIPhotoAblumList alloc] init];
                ablum.title = collection.localizedTitle;
                ablum.count = assets.count;
                ablum.headImageAsset = assets.firstObject;
                ablum.assetCollection = collection;
                [photoAblumList addObject:ablum];
            }
        }
    }];
    
    //获取用户创建的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
        if (assets.count > 0) {
            WXIPhotoAblumList *ablum = [[WXIPhotoAblumList alloc] init];
            ablum.title = collection.localizedTitle;
            ablum.count = assets.count;
            ablum.headImageAsset = assets.firstObject;
            ablum.assetCollection = collection;
            [photoAblumList addObject:ablum];
        }
    }];
    
    return photoAblumList;
}
- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}
#pragma mark - 获取指定相册内的所有图片
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        }
    }];
    return arr;
}
#pragma mark - 获取asset对应的图片
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *))completion
{
    //请求大图界面，当切换图片时，取消上一张图片的请求，对于iCloud端的图片，可以节省流量
    static PHImageRequestID requestID = -1;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(ScreenWidth, ScreenHeight);
    if (requestID >= 1 && size.width/width==scale) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    
    option.resizeMode = resizeMode;//控制照片尺寸
    //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.networkAccessAllowed = YES;
    
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */
    
    requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}
#pragma mark 是否是人脸PHAsset
- (void)isFaceImage:(PHAsset *)asset complete:(void(^)(BOOL isFace))complete
{
    __block BOOL isFaceImage = NO;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(ScreenWidth/2.f, ScreenWidth/2.f) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        CIImage *cImage = [CIImage imageWithCGImage:result.CGImage];
        NSArray * detectResult = [_faceDetector featuresInImage:cImage];
        if (detectResult.count != 0)
        {
            isFaceImage = YES;
        }
        if (complete)
        {
            complete(isFaceImage);
        }

    }];
}
@end
