//
//  ViewController.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/8.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "ViewController.h"
#import "WXICollectionReusableView.h"
#import<AssetsLibrary/ALAssetsLibrary.h>
#import "AssetItem.h"
#import "WXISelectLayoutView.h"
#import "WXIEditViewController.h"
#import "AllDefine.h"
#import "WXICommonPreview.h"
#import "WXIPhotoTool.h"
#import "WXIPhotoTitleCell.h"
#import "UIImage+FaceRecognization.h"

const CGFloat kImageViewHeight = 210;
const CGFloat kTabBarHeight = 49;
const NSInteger kInitTabViewTag = 1000;
const NSInteger kMaxSelectedItem = 6;
const NSInteger kMenuTableViewCellHeight = 60;

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WXISelectLayoutViewDataSource, PHPhotoLibraryChangeObserver,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)UIView *topView;
@property (nonatomic, strong)UIImageView *topImageView;
@property (nonatomic, strong)UIView *tabBarView;
@property (nonatomic, strong)NSArray *tabBarTittleArray;
//存放相册所有AssetItem变量，内含PHAsset
@property (nonatomic, strong)NSMutableArray *assets;
@property (nonatomic, strong)PHImageRequestOptions *option;
//存放选中的AssetItem变量
@property (nonatomic, strong)NSMutableArray *selectedViewArray;
@property (nonatomic, strong)WXISelectLayoutView *selectLayoutView;

@property (nonatomic, strong)NSMutableArray *tabViewButtonArray;

@property (nonatomic, strong)UITableView *menuTableView;
@property (nonatomic, retain)NSMutableArray<WXIPhotoAblumList *> *photoTitleArray;
@property (nonatomic, strong)WXIPhotoAblumList *selectedPhotoAlbum;

@property (nonatomic, strong)UICollectionView *faceCollectionView;
@property (nonatomic, strong)NSMutableArray *faceAssetArray;
@property (nonatomic, strong)CIDetector *faceDetector;

@property (nonatomic, retain)NSMutableDictionary *cellSizeDictionary;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNotification];
    self.selectedViewArray = [NSMutableArray array];
    self.cellSizeDictionary = [NSMutableDictionary dictionary];
    [self addObserver:self forKeyPath:@"selectedViewArray" options:NSKeyValueObservingOptionNew context:NULL];
//    NSLog(@"准备初始化collectionview");
    [self initCollectionView];
//    NSLog(@"初始collectionview完成");
    [self initFaceCollectionView];
    [self initTopView];
    [self initMenuTableView];
    
    [self initTabBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)initNotification
{
    //注册监听相册变化
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectedViewArray" context:NULL];
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)initTopView
{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kImageViewHeight)];
    [self.view addSubview:_topView];
    self.topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instagram"]];
    self.topImageView.frame = CGRectMake(0, 0, ScreenWidth, kImageViewHeight);
    self.topImageView.alpha = 0.9;
    [self.topView addSubview:self.topImageView];
    
    self.selectLayoutView = [[WXISelectLayoutView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kImageViewHeight)];
    self.selectLayoutView.dataSource = self;
    self.selectLayoutView.title = @"选择布局";
    
    [self.selectLayoutView.cancelButton addTarget:self action:@selector(cancenSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.selectLayoutView];
    [self.selectLayoutView setHidden:YES];
}
- (void)initCollectionView
{
    [self getAccessToAlbum];
    
    self.option = [[PHImageRequestOptions alloc] init];
    self.option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - kTabBarHeight) collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionCell_1"];
    self.collectionView.contentInset = UIEdgeInsetsMake(kImageViewHeight - 20, 0, 0, 0);
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    //height:40
    [self.collectionView registerClass:[WXICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
}
- (void)initFaceCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.faceCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - kTabBarHeight) collectionViewLayout:flowLayout];
    [self.faceCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionCell_2"];
    self.faceCollectionView.contentInset = UIEdgeInsetsMake(kImageViewHeight, 0, 0, 0);
    self.faceCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.faceCollectionView];
    self.faceCollectionView.dataSource = self;
    self.faceCollectionView.delegate = self;

    self.faceCollectionView.hidden = YES;
}
- (void)getAccessToAlbum
{
    
    NSMutableArray<AssetItem *> *assets = [NSMutableArray array];
    self.faceAssetArray = [NSMutableArray array];
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                           context:nil
                                           options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    

    self.photoTitleArray = [NSMutableArray arrayWithArray:[[WXIPhotoTool sharePhotoTool] getPhotoAblumList]];
    for (WXIPhotoAblumList *album in self.photoTitleArray) {
        if ([album.title isEqualToString:@"Camera Roll"])
        {
            NSArray<PHAsset *>*result = [[WXIPhotoTool sharePhotoTool] getAssetsInAssetCollection:album.assetCollection ascending:NO];
            [result enumerateObjectsUsingBlock:^(PHAsset*  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                AssetItem *item = [AssetItem AsseItemWithPhasset:asset];
                [assets addObject:item];
            }];
            
        }
    }
    self.assets = assets;
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", NULL);
    for (AssetItem *item in self.assets) {
        //这个block回调返回两次。。。一个是我指定的大小，一次是原尺寸图片，神坑
        [[PHImageManager defaultManager] requestImageForAsset:item.asset targetSize:CGSizeMake(ScreenWidth/2.f, ScreenWidth/2.f) contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {

                dispatch_async(myQueue, ^{
                    CIImage *cImage = [CIImage imageWithCGImage:result.CGImage];
                    NSArray * detectResult = [_faceDetector featuresInImage:cImage];
                    //防止两次返回中重复添加人脸
                    if (detectResult.count != 0 && !item.isFaced)
                    {
                        item.isFaced = YES;
                        //第一张人脸
                        item.facesRect = ((CIFaceFeature *)[detectResult objectAtIndex:0]).bounds;
                        //所有脸取并集
                        for (CIFaceFeature* faceFeature in detectResult) {
                            item.facesRect = CGRectUnion(item.facesRect, faceFeature.bounds);
                        }
                        [self.faceAssetArray addObject:item];
                    }
                });
        }];
    }

    //结束后会刷新人脸
    dispatch_barrier_async(myQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.faceCollectionView reloadData];
        });
    });
    
}
- (void)initMenuTableView
{
    if (!self.menuTableView)
    {
        self.menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - kImageViewHeight - kTabBarHeight) style:UITableViewStylePlain];
        [self.view addSubview:_menuTableView];
        self.menuTableView.delegate = self;
        self.menuTableView.dataSource = self;
        self.menuTableView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(self.menuTableView.frame));
        [self.menuTableView addSubview:effectView];
        [self.menuTableView sendSubviewToBack:effectView];
    }
}
- (void)initTabBarView
{
    self.tabViewButtonArray = [NSMutableArray array];
    _tabBarView = [[UIView alloc]initWithFrame:CGRectMake(0,ScreenHeight-kTabBarHeight,ScreenWidth,kTabBarHeight)];
    [self.view addSubview:_tabBarView];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = CGRectMake(0, 0, ScreenWidth, 49);
    [_tabBarView addSubview:effectview];
    
    
    self.tabBarTittleArray = @[@"相机胶卷", @"面孔", @"最近"];
    CGFloat buttonWidth = ScreenWidth/3.f;
    for (int i = 0; i < _tabBarTittleArray.count; i++) {
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(i*buttonWidth, 0, buttonWidth ,kTabBarHeight)];
        button.showsTouchWhenHighlighted =YES;
        //从左到右tag为1000逐渐加1
        button.tag = kInitTabViewTag + i;
        [button setTitle:_tabBarTittleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.53 green:0.73 blue:0.91 alpha:1.00] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithRed:0.53 green:0.73 blue:0.91 alpha:1.00] forState:UIControlStateSelected];
        
        [button addTarget:self action:@selector(selectedTab:)forControlEvents:UIControlEventTouchUpInside];
        [self.tabViewButtonArray addObject:button];
        [effectview.contentView addSubview:button];

    }

}
//修改字体颜色状态栏为白色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)setStatusBarBackgroundColor:(UIColor *)color
{
    
}
#pragma mark 取消按钮
- (void)cancenSelect:(UIButton *)button
{
    [[self mutableArrayValueForKey:@"selectedViewArray"] removeAllObjects];
    for (AssetItem *item in self.assets) {
        item.selected = NO;
    }
    for (AssetItem *item in self.faceAssetArray)
    {
        item.selected = NO;
    }
    [self.collectionView reloadData];
    [self.faceCollectionView reloadData];
}
#pragma mark 打开相机
- (void)openCamera
{
    if (![self judgeIsHaveCameraAuthority])
    {
        NSLog(@"无法打开相机");
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }
}
- (BOOL)judgeIsHaveCameraAuthority
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}
#pragma mark 下面的tabbar
- (void)selectedTab:(UIButton *)button
{
    for (UIButton *view in self.tabViewButtonArray) {
        if (view == button)
        {
            [view setTitleColor:[UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00] forState:UIControlStateNormal];
        }
        else
        {
            [view setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
    }
    if(button.tag == 1000)
    {
        //防止切换弹出菜单
        if (self.collectionView.hidden == NO)
        {
            button.selected = !button.selected;
            if (button.selected)
            {
                //出现时刷新数据
                [self.menuTableView reloadData];
                [UIView animateWithDuration:0.3 animations:^{
                    self.menuTableView.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), ScreenWidth, ScreenHeight - kImageViewHeight - kTabBarHeight);
                }];
            }else
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.menuTableView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - kImageViewHeight - kTabBarHeight);
                }];
            }
        }else
        {
            [self.collectionView reloadData];
        }
        
        self.collectionView.hidden = NO;
        self.faceCollectionView.hidden = YES;
        
    }
    if (button.tag == 1001)
    {
        if (self.faceCollectionView.hidden)
        {
            [self.faceCollectionView reloadData];
        }
        self.collectionView.hidden = YES;
        self.faceCollectionView.hidden = NO;
        
    }
}
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"selectedViewArray"])
    {
        if ([self mutableArrayValueForKey:@"selectedViewArray"].count != 0)
        {
            self.selectLayoutView.hidden = NO;
            self.topImageView.hidden = YES;
        }
        else
        {
            self.selectLayoutView.hidden = YES;
            self.topImageView.hidden = NO;
        }
    }
    [self.selectLayoutView reload];
    
}

#pragma mark - collectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView)
    {
        return self.assets.count;
    }else
    {
        return self.faceAssetArray.count;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCollectionCell_1" forIndexPath:indexPath];
        if (cell.contentView.subviews.count != 0)
        {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        }
        
        AssetItem *asset = self.assets[indexPath.row];
        //右下角的勾
        UIImageView *checkBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkbox_pic"]];
        CGFloat width = cell.frame.size.width;
        CGFloat height = cell.frame.size.height;
        //用tag标记那个勾
        checkBox.frame = CGRectMake(width - 25, height - 25, 20, 20);
        CGSize size = CGSizeMake(asset.asset.pixelWidth/5.f, asset.asset.pixelHeight/5.f);
        [[PHImageManager defaultManager] requestImageForAsset:asset.asset targetSize:size contentMode:PHImageContentModeAspectFit options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:result];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.frame = CGRectMake(0, 0, (ScreenWidth - 3) / 3.f, (ScreenWidth - 3) / 3.5f);
            //居中
            imageView.center = cell.contentView.center;
            //切掉多余的
            cell.contentView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
            if (asset.selected)
            {
                [cell.contentView addSubview:checkBox];
                cell.contentView.layer.borderWidth = 2.f;
                cell.contentView.layer.borderColor = [UIColor colorWithRed:0.54 green:0.78 blue:0.99 alpha:1.00].CGColor;
            }
        }];
        return cell;
    }else
    {
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCollectionCell_2" forIndexPath:indexPath];
        if (cell.contentView.subviews.count != 0)
        {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        }
        AssetItem *asset = self.faceAssetArray[indexPath.row];
        //右下角的勾
        UIImageView *checkBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkbox_pic"]];
        CGFloat width = cell.frame.size.width;
        CGFloat height = cell.frame.size.height;
        //用tag标记那个勾
        checkBox.frame = CGRectMake(width - 25, height - 25, 20, 20);
        CGSize size = CGSizeMake(asset.asset.pixelWidth/5.f, asset.asset.pixelHeight/5.f);
        [[PHImageManager defaultManager] requestImageForAsset:asset.asset targetSize:size contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:result];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.frame = CGRectMake(0, 0, (ScreenWidth - 3) / 3.f, (ScreenWidth - 3) / 3.5f);
            //居中
            imageView.center = cell.contentView.center;
            //切掉多余的
            cell.contentView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
            if (asset.selected)
            {
                [cell.contentView addSubview:checkBox];
                cell.contentView.layer.borderWidth = 2.f;
                cell.contentView.layer.borderColor = [UIColor colorWithRed:0.54 green:0.78 blue:0.99 alpha:1.00].CGColor;
            }
        }];
        return cell;
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView)
    {
        WXICollectionReusableView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
        
        NSDictionary *attributedDict = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00],NSFontAttributeName:[UIFont systemFontOfSize:15]};
        NSString *title = @"快 照 屋";
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributedDict];
        [titleView.button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
        
        [titleView.button addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside];
        return titleView;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView)
    {
        AssetItem * item = _assets[indexPath.row];
        item.selected = !item.selected;
        if (item.selected)
        {
            if ([self mutableArrayValueForKey:@"selectedViewArray"].count == kMaxSelectedItem)
            {
                item.selected = !item.selected;
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                return;
            }
            [[self mutableArrayValueForKey:@"selectedViewArray"] addObject:item];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            
        }
        else
        {
            NSUInteger index = [[self mutableArrayValueForKey:@"selectedViewArray"] indexOfObject:item];
            [[self mutableArrayValueForKey:@"selectedViewArray"] removeObjectAtIndex:index];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }
    if (collectionView == self.faceCollectionView)
    {
        AssetItem * item = _faceAssetArray[indexPath.row];
        item.selected = !item.selected;
        if (item.selected)
        {
            if ([self mutableArrayValueForKey:@"selectedViewArray"].count == kMaxSelectedItem)
            {
                item.selected = !item.selected;
                [self.faceCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                return;
            }
            [[self mutableArrayValueForKey:@"selectedViewArray"] addObject:item];
            [self.faceCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            
        }
        else
        {
            NSUInteger index = [[self mutableArrayValueForKey:@"selectedViewArray"] indexOfObject:item];
            [[self mutableArrayValueForKey:@"selectedViewArray"] removeObjectAtIndex:index];
            [self.faceCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    NSValue *cellSizeValue = [_cellSizeDictionary objectForKey:@(indexPath.row)];
    if (cellSizeValue)
    {
        size = [cellSizeValue CGSizeValue];
    }
    else
    {
        size = CGSizeMake((ScreenWidth - 3) / 4.f, (ScreenWidth - 3) / 4.f);
        [_cellSizeDictionary setObject:[NSValue valueWithCGSize:size] forKey:@(indexPath.row)];
    }
    return size;

}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.f;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (collectionView == self.collectionView)
    {
        return CGSizeMake(ScreenWidth, 40);
    }
    return CGSizeZero;
}
#pragma mark - tableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * photoTitleCell = @"photoTitleCell";
    WXIPhotoTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:photoTitleCell];
    if (cell == nil)
    {
        cell = [[WXIPhotoTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoTitleCell];
        cell.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = CGRectMake(0, 0, ScreenWidth, kMenuTableViewCellHeight);
        //添加到要有毛玻璃特效的控件中
        [cell.contentView addSubview:effectView];
    }
    
    cell.nameLabel.text = self.photoTitleArray[indexPath.row].title;
    cell.numberLabel.text = [NSString stringWithFormat:@"%i",self.photoTitleArray[indexPath.row].count];
    [[WXIPhotoTool sharePhotoTool] requestImageForAsset:self.photoTitleArray[indexPath.row].headImageAsset size:CGSizeMake(200, 200) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        cell.previewImageView.image = image;
    }];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMenuTableViewCellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *button = self.tabViewButtonArray[0];
    button.selected = NO;
    //更新菜单名字
    [button setTitle:self.photoTitleArray[indexPath.row].title forState:UIControlStateNormal];
    self.selectedPhotoAlbum = (WXIPhotoAblumList *)self.photoTitleArray[indexPath.row];
    //退出菜单
    [UIView animateWithDuration:0.3 animations:^{
        self.menuTableView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - kImageViewHeight - kTabBarHeight);
    }];
    //获取选中相册内容
    NSArray *selectedPhotoArray = [[WXIPhotoTool sharePhotoTool] getAssetsInAssetCollection:self.photoTitleArray[indexPath.row].assetCollection ascending:NO];
    //保持选中的照片还是选中状态
    NSMutableArray * selectedArray = [NSMutableArray array];
    NSMutableArray * selectedIdentifierArray = [NSMutableArray array];
    for (AssetItem *item in self.assets)
    {
        if (item.selected)
        {
            [selectedArray addObject:item];
            [selectedIdentifierArray addObject:item.asset.localIdentifier];
        }
    }
    [self.assets removeAllObjects];
    __block NSInteger index = 0;
    [selectedPhotoArray enumerateObjectsUsingBlock:^(PHAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![selectedIdentifierArray containsObject:obj.localIdentifier])
        {
            AssetItem *item = [AssetItem AsseItemWithPhasset:obj];
            [self.assets addObject:item];
        }
        else
        {
            [self.assets addObject:selectedArray[index++]];
        }
    }];
    [self.collectionView reloadData];
    
}
#pragma mark tableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoTitleArray.count;
}
#pragma mark <WXISelectLayoutViewDataSource>
- (NSInteger)numberOfViewsForSelectLayoutView:(WXISelectLayoutView *)selectLayoutView
{
    //当选中几幅图的时候，顶部的提供几种view
    switch (_selectedViewArray.count) {
        case 1:
            return 4;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 6;
            break;
        case 4:
            return 7;
            break;
        case 5:
            return 7;
            break;
        case 6:
            return 6;
            break;
        default:
            return 3;
            break;
    }
}
- (UIView *)selectLayoutView:(WXISelectLayoutView *)selectLayoutView viewAtIndex:(int)index
{
    NSMutableArray *selectedAssetArray = [NSMutableArray array];
    for (AssetItem * item in self.selectedViewArray)
    {
        [selectedAssetArray addObject:item];
    }
    if (_selectedViewArray.count == 1)
    {
        switch (index) {
            case 0:
            {
                return [self commonPreviewWithTag:leftAndRightViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 1:
            {

                return [self commonPreviewWithTag:topAndDownViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 2:
            {
                return [self commonPreviewWithTag:threeVerticalViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 3:
            {
                return [self commonPreviewWithTag:threeHorizontalViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            default:
            {
                UIView *view = [[UIView alloc] init];
                view.backgroundColor = [UIColor redColor];
                return view;
                break;
            }
        }
    }
    if (_selectedViewArray.count == 2)
    {
        switch (index) {
            case 0:
            {
                return [self commonPreviewWithTag:topAndDownViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 1:
            {
                return [self commonPreviewWithTag:leftAndRightViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 2:
            {
                return [self commonPreviewWithTag:fieldViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            default:
            {
                UIView *view = [[UIView alloc] init];
                view.backgroundColor = [UIColor redColor];
                return view;
                break;
            }
        }
    }
    if (_selectedViewArray.count == 3)
    {
        switch (index) {
            case 0:
            {
                return [self commonPreviewWithTag:threeTopViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 1:
            {
                return [self commonPreviewWithTag:threeVerticalViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 2:
            {
                return [self commonPreviewWithTag:threeLeftViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 3:
            {
                return [self commonPreviewWithTag:threeHorizontalViewTag andPhotoAssetArray:selectedAssetArray];
            }
            case 4:
            {
                return [self commonPreviewWithTag:threeRightViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 5:
            {
                return [self commonPreviewWithTag:threeDownViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            default:
            {
                UIView *view = [[UIView alloc] init];
                view.backgroundColor = [UIColor redColor];
                return view;
                break;
            }
        }
    }
    if (_selectedViewArray.count == 4)
    {
        switch (index) {
            case 0:
            {
                return [self commonPreviewWithTag:fieldViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 1:
            {
                return [self commonPreviewWithTag:fourVerticalViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 2:
            {
                return [self commonPreviewWithTag:fourTopViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 3:
            {
                return [self commonPreviewWithTag:fourLeftViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 4:
            {
                return [self commonPreviewWithTag:fourHorizontalViewTag andPhotoAssetArray:selectedAssetArray];
            }
            case 5:
            {
                return [self commonPreviewWithTag:fourRightViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 6:
            {
                return [self commonPreviewWithTag:fourDownViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            default:
            {
                UIView *view = [[UIView alloc] init];
                view.backgroundColor = [UIColor redColor];
                return view;
                break;
            }
        }
    }
    if (_selectedViewArray.count == 5)
    {
        switch (index) {
            case 0:
            {
                return [self commonPreviewWithTag:fiveTopTwoDownThreeViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 1:
            {
                return [self commonPreviewWithTag:fiveLeftThreeRightTwoViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 2:
            {
                return [self commonPreviewWithTag:fiveVerticalViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 3:
            {
                return [self commonPreviewWithTag:fiveLeftViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 4:
            {
                return [self commonPreviewWithTag:fiveDownViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 5:
            {
                return [self commonPreviewWithTag:fiveVerticalThreePartViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 6:
            {
                return [self commonPreviewWithTag:fiveHorizontalViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            default:
            {
                UIView *view = [[UIView alloc] init];
                view.backgroundColor = [UIColor redColor];
                return view;
                break;
            }
        }
    }
    if (_selectedViewArray.count == 6)
    {
        switch (index) {
            case 0:
            {
                return [self commonPreviewWithTag:sixTwoTimesThreeViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 1:
            {
                return [self commonPreviewWithTag:sixThreeTimesTwoViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 2:
            {
                return [self commonPreviewWithTag:sixTwoFourViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 3:
            {
                return [self commonPreviewWithTag:sixOneFiveViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 4:
            {
                return [self commonPreviewWithTag:sixOneThreeTwoViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            case 5:
            {
                return [self commonPreviewWithTag:sixLeftTopSurroundViewTag andPhotoAssetArray:selectedAssetArray];
                break;
            }
            default:
            {
                UIView *view = [[UIView alloc] init];
                view.backgroundColor = [UIColor redColor];
                return view;
                break;
            }
        }
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    return view;
    
}
- (WXICommonPreview *)commonPreviewWithTag:(NSInteger)tag andPhotoAssetArray:(NSMutableArray *)selectedAssetsArray
{
    WXICommonPreview *view = [[WXICommonPreview alloc] initWithFrame:CGRectMake(0, 0, 150, 150) tag:tag];
    [view setPhotoAsset:selectedAssetsArray];
    [view setStyleTag:tag];
    UITapGestureRecognizer *tagGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [view addGestureRecognizer:tagGesture];
    return view;
}
#pragma mark block回调
- (void)imageWithAssetItem:(AssetItem *)item Size:(CGSize)size resultBlock:(void(^)(UIImage *image))resultblock
{
    
    [[PHImageManager defaultManager] requestImageForAsset:item.asset targetSize:size contentMode:PHImageContentModeDefault options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        resultblock(result);
    }];
    
}

#pragma mark tap事件
- (void)tapView:(UITapGestureRecognizer *)tapGesture
{
    WXIEditViewController *editViewController = [[WXIEditViewController alloc] init];
    WXICommonPreview *preView = (WXICommonPreview *)tapGesture.view;
    editViewController.tag = preView.styleTag;
    editViewController.selectedAssetsArray = [NSMutableArray array];
    editViewController.photoAlbum = self.selectedPhotoAlbum;
    
    for (AssetItem *assetItem in self.selectedViewArray) {
        [editViewController.selectedAssetsArray addObject:assetItem.asset];
    }
    [self.navigationController pushViewController:editViewController animated:YES];
    
}
#pragma mark 相册变化回调
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self loadPhotoForAlbum];
    });
}
- (void)loadPhotoForAlbum
{
    [self.assets removeAllObjects];
    [self.faceAssetArray removeAllObjects];
    [[self mutableArrayValueForKey:@"selectedViewArray"] removeAllObjects];
    //防止新增了相册
    self.photoTitleArray = [NSMutableArray arrayWithArray:[[WXIPhotoTool sharePhotoTool] getPhotoAblumList]];
    for (WXIPhotoAblumList *album in self.photoTitleArray) {
        if ([album.title isEqualToString:@"Camera Roll"])
        {
            NSArray<PHAsset *>*result = [[WXIPhotoTool sharePhotoTool] getAssetsInAssetCollection:album.assetCollection ascending:NO];
            [result enumerateObjectsUsingBlock:^(PHAsset*  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                AssetItem *item = [AssetItem AsseItemWithPhasset:asset];
                [self.assets addObject:item];
            }];
            
        }
    }

    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", NULL);
    for (AssetItem *item in self.assets) {
        //这个block回调返回两次。。。一个是我指定的大小，一次是原尺寸图片，神坑
        [[PHImageManager defaultManager] requestImageForAsset:item.asset targetSize:CGSizeMake(ScreenWidth/2.f, ScreenWidth/2.f) contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            dispatch_async(myQueue, ^{
                CIImage *cImage = [CIImage imageWithCGImage:result.CGImage];
                NSArray * detectResult = [_faceDetector featuresInImage:cImage];
                //防止两次返回中重复添加人脸
                if (detectResult.count != 0 && !item.isFaced)
                {
                    item.isFaced = YES;
                    //第一张人脸
                    item.facesRect = ((CIFaceFeature *)[detectResult objectAtIndex:0]).bounds;
                    //所有脸取并集
                    for (CIFaceFeature* faceFeature in detectResult) {
                        item.facesRect = CGRectUnion(item.facesRect, faceFeature.bounds);
                    }
                    [self.faceAssetArray addObject:item];
                }
            });
        }];
    }

    //结束后会刷新人脸
    dispatch_barrier_async(myQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.faceCollectionView reloadData];
        });
    });
    [self.collectionView reloadData];
    [self.faceCollectionView reloadData];
}

@end
