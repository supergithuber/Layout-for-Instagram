//
//  WXIEditViewController.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/9.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "WXIEditViewController.h"
#import "AllDefine.h"
#import "WXIEditButton.h"
#import "WXIEditContentView.h"
#import "WXISmallEditView.h"
#import "WXIPhotoTool.h"
#import "WXIPhotoTitleCell.h"

const CGFloat kNavigationBarHeight = 44;
const CGFloat kTopMenuHeight = 20;
const CGFloat kEditContentViewHeight = 360;
const NSInteger kInitEditButtonTag = 2000;
const NSInteger kInitTabButtonTag = 5000;

const NSInteger ktableViewCellHeight = 50;
@interface WXIEditViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WXIEditContentViewDelegate, PHPhotoLibraryChangeObserver, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UIView *topView;
@property (nonatomic, strong)UIScrollView *editMenuView;
@property (nonatomic, strong)NSMutableArray *editButtonArray;
@property (nonatomic, strong)UICollectionView *photoCollectionView;
//PHAsset对象
@property (nonatomic, strong)NSMutableArray *photoAssets;
@property (nonatomic, strong)PHImageRequestOptions *option;

@property (nonatomic, strong)UIBarButtonItem *saveButton;
@property (nonatomic, strong)UIBarButtonItem *doneButton;

//上面那个由多个smalleditview组成的view,放在editContentView
@property (nonatomic, strong)WXIEditContentView *editContentView;
@property (nonatomic, assign)CGFloat leftTopX;
@property (nonatomic, assign)CGFloat leftTopY;
@property (nonatomic, assign)CGFloat rightDownX;
@property (nonatomic, assign)CGFloat rightDownY;

//需要监听的选中变量
//下部相册中选中的index
@property (nonatomic, assign)NSInteger selectedIndex;
//上部选中的index
@property (nonatomic, assign)NSInteger smallViewIndex;

@property (nonatomic, assign)BOOL addBorder;

@property (nonatomic, strong)UIView *tabBarView;
@property (nonatomic, strong)UITableView *menuTableView;
@property (nonatomic, retain)NSMutableArray<WXIPhotoAblumList *> *photoTitleArray;
@property (nonatomic, strong)NSMutableArray *tabViewButtonArray;
@property (nonatomic, strong)NSMutableArray *tabBarTittleArray;

@end

@implementation WXIEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self initNavigation];
    
    [self initPhotoCollecionView];
    [self initEditContentView];
    [self initEditMenuView];
    [self initKVC];
    [self initNotification];
    [self initTabBarView];
    [self initMenuTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.editContentView setPhotoAsset:self.selectedAssetsArray];
    [self.editContentView setStyleTag:self.tag];
    //初始显示一个边框
    [self.editContentView.firstView drawInnerBoarder];
    [self.editContentView drawBoarderMiddleView:self.editContentView.firstView];
    [self.editContentView setValue:[NSNumber numberWithInteger:0] forKey:@"smallViewIndex"];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)initKVC
{
    [self addObserver:self forKeyPath:@"selectedIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.editContentView addObserver:self forKeyPath:@"smallViewIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.editContentView setValue:[NSNumber numberWithInteger:0] forKey:@"smallViewIndex"];
    
//    [self.editContentView addObserver:self forKeyPath:@"scaleRation" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}
- (void)initNavigation
{
    [self.navigationController setNavigationBarHidden:NO];
    //高度为44
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.1 alpha:0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    //当状态栏在nav中的时候，这样修改字体颜色
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.title = @"编辑";
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = _saveButton;
    //禁止手势返回
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)initEditContentView
{
    //kNavigationBarHeight+kTopMenuHeight
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight+kTopMenuHeight, ScreenWidth, kEditContentViewHeight)];
    self.topView.backgroundColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.17 alpha:1.00];
    [self.view addSubview:self.topView];
    
    self.editContentView = [[WXIEditContentView alloc] initWithFrame:CGRectMake(0, 0, self.topView.frame.size.width, self.topView.frame.size.height) tag:self.tag];
    self.editContentView.moveDelegate = self;
    [self.topView addSubview:self.editContentView];
}

- (void)initEditMenuView
{
    self.editButtonArray = [NSMutableArray array];
    self.editMenuView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight+kTopMenuHeight+kEditContentViewHeight, ScreenWidth, ScreenHeight - (kNavigationBarHeight+kTopMenuHeight+kEditContentViewHeight))];

    self.editMenuView.backgroundColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.17 alpha:1.00];
    
    CGFloat buttonWidth = 80;
    CGFloat margin = 30;
    NSArray *titleArray = @[@"替换",@"镜像",@"翻转",@"边框"];
    NSArray *imageArray = @[@"替换",@"镜像",@"翻转",@"边框"];
    for (NSInteger i = 0;i < 4; i++)
    {
        WXIEditButton *editButton = [[WXIEditButton alloc] initWithFrame:CGRectMake(margin + (margin + buttonWidth) * i, (self.editMenuView.frame.size.height/2) - 60, buttonWidth, 120)];
        editButton.title = titleArray[i];
        editButton.buttonImage = [UIImage imageNamed:imageArray[i]];
        //tag从2000开始加1
        editButton.button.tag = kInitEditButtonTag + i;
        [editButton.button addTarget:self action:@selector(clickEditButton:) forControlEvents:UIControlEventTouchUpInside];
        [_editButtonArray addObject:editButton];
        [self.editMenuView addSubview:editButton];
    }
    self.editMenuView.contentSize = CGSizeMake(titleArray.count*(margin + buttonWidth), ScreenHeight - (kNavigationBarHeight+kTopMenuHeight+kEditContentViewHeight));
    self.editMenuView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.editMenuView];
}
- (void)initPhotoCollecionView
{
    [self getAccessToAlbum];
    self.option = [[PHImageRequestOptions alloc] init];
    self.option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:flowLayout];
    [self.photoCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionCell_1"];
    self.photoCollectionView.contentInset = UIEdgeInsetsMake(kEditContentViewHeight - 40, 0, 49, 0);
    [self.view addSubview:self.photoCollectionView];
    self.photoCollectionView.dataSource = self;
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.hidden = YES;
}
- (void)getAccessToAlbum
{
    if (self.photoAlbum == nil)
    {
        NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
        
        [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *asset = (PHAsset *)obj;
            [assets addObject:asset];
        }];
        self.photoAssets = assets;
    }else
    {
        self.photoAssets = [[[WXIPhotoTool sharePhotoTool] getAssetsInAssetCollection:self.photoAlbum.assetCollection ascending:NO] mutableCopy];
    }
    self.photoTitleArray = [NSMutableArray arrayWithArray:[[WXIPhotoTool sharePhotoTool] getPhotoAblumList]];
}
- (void)initNotification
{
    //注册监听相册变化
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}
- (void)initTabBarView
{
    self.tabViewButtonArray = [NSMutableArray array];
    _tabBarView = [[UIView alloc]initWithFrame:CGRectMake(0,ScreenHeight-49,ScreenWidth,49)];
    [self.view addSubview:_tabBarView];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = CGRectMake(0, 0, ScreenWidth, 49);
    [_tabBarView addSubview:effectview];
    
    self.tabBarTittleArray = [NSMutableArray arrayWithObjects:@"相机胶卷",@"面孔", @"最近", nil];
    if (self.photoAlbum)
    {
        [self.tabBarTittleArray replaceObjectAtIndex:0 withObject:self.photoAlbum.title];
    }
    CGFloat buttonWidth = ScreenWidth/3.f;
    for (int i = 0; i < _tabBarTittleArray.count; i++) {
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(i*buttonWidth, 0, buttonWidth ,49)];
        button.showsTouchWhenHighlighted =YES;
        //从左到右tag为1000逐渐加1
        button.tag = kInitTabButtonTag + i;
        [button setTitle:_tabBarTittleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.53 green:0.73 blue:0.91 alpha:1.00] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithRed:0.53 green:0.73 blue:0.91 alpha:1.00] forState:UIControlStateSelected];
        
        [button addTarget:self action:@selector(selectedTab:)forControlEvents:UIControlEventTouchUpInside];
        [self.tabViewButtonArray addObject:button];
        [effectview.contentView addSubview:button];
        
    }
    self.tabBarView.hidden = YES;
}
- (void)initMenuTableView
{
    if (!self.menuTableView)
    {
        self.menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - CGRectGetHeight(self.topView.frame) - CGRectGetHeight(self.tabBarView.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame) - 20) style:UITableViewStylePlain];
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
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectedIndex"];
    [self.editContentView removeObserver:self forKeyPath:@"smallViewIndex"];
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
//    [self.editContentView removeObserver:self forKeyPath:@"scaleRation"];
}

#pragma mark 点击editButton事件
- (void)clickEditButton:(UIButton *)button
{
    if(button.tag == 2000)
    {
        [self showReplaceView];
    }
    if (button.tag == 2001)
    {
        [self mirrorImage];
    }
    if (button.tag == 2002)
    {
        [self flipImage];
    }
    if (button.tag == 2003)
    {
        [self boarderImage];
    }
}
- (void)showReplaceView
{
    if(!self.editMenuView.hidden)
    {
        self.editMenuView.hidden = YES;
    }
    if (self.photoCollectionView.hidden)
    {
        self.photoCollectionView.hidden = NO;
    }
    if (self.tabBarView.hidden)
    {
        self.tabBarView.hidden = NO;
    }
//    [UIView animateWithDuration:0.3 animations:^{
//        self.editContentView.transform = CGAffineTransformMakeScale(0.9, 0.9);
//    }];
//    [self.editContentView setValue:[NSNumber numberWithFloat:0.9] forKey:@"scaleRation"];
    self.title = @"替换";
    self.navigationItem.rightBarButtonItem = _doneButton;
    self.navigationItem.hidesBackButton = YES;
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
    if(button.tag == 5000)
    {
        button.selected = !button.selected;
        if (button.selected)
        {
        [self.menuTableView reloadData];
        [UIView animateWithDuration:0.3 animations:^{
            self.menuTableView.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), ScreenWidth, ScreenHeight - CGRectGetHeight(self.topView.frame) - CGRectGetHeight(self.tabBarView.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame) - 20);
        }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.menuTableView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - CGRectGetHeight(self.topView.frame) - CGRectGetHeight(self.tabBarView.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame) - 20);
            }];
        }
    }
    
}
#pragma mark 镜像
//利用CGAffineTransform做镜像
- (void)mirrorImage
{
    self.smallViewIndex = [[self.editContentView valueForKey:@"smallViewIndex"] integerValue];
    WXISmallEditView *smallView = self.editContentView.contentViewArray[self.smallViewIndex];
    
    CGSize contentSize = smallView.contentView.contentSize;
    CGPoint contentOffset = smallView.contentView.contentOffset;
    CGRect imageViewFrame = smallView.imageView.frame;
    
    UIImage *image = smallView.imageView.image;
    
    [smallView setImageViewData:[self mirrorWithImage:image]];
    //重置配置
    smallView.contentView.contentSize = contentSize;
    smallView.contentView.contentOffset = contentOffset;
    smallView.imageView.frame = imageViewFrame;
}
#pragma mark 翻转
- (void)flipImage
{
    self.smallViewIndex = [[self.editContentView valueForKey:@"smallViewIndex"] integerValue];
    WXISmallEditView *smallView = self.editContentView.contentViewArray[self.smallViewIndex];
    
    CGSize contentSize = smallView.contentView.contentSize;
    CGPoint contentOffset = smallView.contentView.contentOffset;
    CGRect imageViewFrame = smallView.imageView.frame;
    
    UIImage *image = smallView.imageView.image;
    [smallView setImageViewData:[self flipWithImage:image]];
    smallView.contentView.contentSize = contentSize;
    smallView.contentView.contentOffset = contentOffset;
    smallView.imageView.frame = imageViewFrame;
}
#pragma mark 边框
- (void)boarderImage
{
    self.addBorder = !self.addBorder;
    if (self.addBorder)
    {
        self.leftTopX = self.editContentView.frame.origin.x;
        self.leftTopY = self.editContentView.frame.origin.y;
        self.rightDownX = CGRectGetMaxX(self.editContentView.frame);
        self.rightDownY = CGRectGetMaxY(self.editContentView.frame);
        
        for (WXISmallEditView *smallView in self.editContentView.subviews) {
            //先清除外部选中蓝色边框
            [smallView clearInnerBoarder];
            //移除拖动提示边框
            [self.editContentView removeBoarderMiddleView:smallView];
            [self drawInnerBoarder:smallView];
        }
        //这个变量传给topIndex决定是否可以点击
        [self.editContentView setValue:[NSNumber numberWithInteger:-1] forKey:@"smallViewIndex"];
    }else
    {
        for (WXISmallEditView *smallView in self.editContentView.subviews) {
            [self clearInnerBoarder:smallView];
        }
        //这个变量传给topIndex决定是否可以点击
        [self.editContentView setValue:[NSNumber numberWithInteger:0] forKey:@"smallViewIndex"];
    }
    
}
- (void)drawInnerBoarder:(WXISmallEditView *)smallEditView
{
    if (smallEditView.frame.size.width == 0 || smallEditView.frame.size.height == 0)
    {
        return;
    }
    if (smallEditView.frame.origin.x != self.leftTopX)
    {
        smallEditView.leftBoarderLayer.backgroundColor = [UIColor whiteColor];
    }
    if (smallEditView.frame.origin.y != self.leftTopY)
    {
        smallEditView.topBoarderLayer.backgroundColor = [UIColor whiteColor];
    }
    if (CGRectGetMaxX(smallEditView.frame) != self.rightDownX)
    {
        smallEditView.rightBoarderLayer.backgroundColor = [UIColor whiteColor];
    }
    if (CGRectGetMaxY(smallEditView.frame) != self.rightDownY)
    {
        smallEditView.bottomBoarderLayer.backgroundColor = [UIColor whiteColor];
    }
}
- (void)clearInnerBoarder:(WXISmallEditView *)smallEditView
{
    smallEditView.leftBoarderLayer.backgroundColor = [UIColor clearColor];
    smallEditView.topBoarderLayer.backgroundColor = [UIColor clearColor];
    smallEditView.rightBoarderLayer.backgroundColor = [UIColor clearColor];
    smallEditView.bottomBoarderLayer.backgroundColor = [UIColor clearColor];
}
#pragma mark 翻转和镜像函数,只翻转内部image
- (UIImage *)flipWithImage:(UIImage *)image
{
    UIImage *resultImage;
    if (image.imageOrientation == UIImageOrientationUp)
    {
        resultImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationDownMirrored];
    }
    else
    {
        resultImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUp];
    }
    return resultImage;
}
- (UIImage *)mirrorWithImage:(UIImage *)image
{
    UIImage *resultImage;
    if (image.imageOrientation == UIImageOrientationUp)
    {
        resultImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
    }
    else
    {
        resultImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUp];
    }
    return resultImage;
}
#pragma mark 保存
- (void)save
{
    UIImage *resuleImage = [self cutImageWithView:self.editContentView];
    UIImageWriteToSavedPhotosAlbum(resuleImage, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:), nil);
}
#pragma mark - savePhotoAlbumDelegate
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo {
    
    NSString *message;
    NSString *title;
    if (!error) {
        title = @"恭喜";
        message = @"成功保存到相册";
    } else {
        title = @"失败";
        message = [error description];
    }
    
}
//从uiview导出UIImage
- (UIImage *)cutImageWithView:(WXIEditContentView *)contentView
{

    UIGraphicsBeginImageContextWithOptions(contentView.frame.size, NO, 2.0);
    //保存时去选中边框,用CGColorEqualToColor判断是否是选中边框
    for (WXISmallEditView *smallView in contentView.subviews) {
        if (CGColorEqualToColor(smallView.topBoarderLayer.backgroundColor.CGColor, [UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00].CGColor))
        {
            [smallView clearInnerBoarder];
        }
        [self.editContentView removeBoarderMiddleView:smallView];
    }
    [contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)done
{
    if(self.editMenuView.hidden)
    {
        self.editMenuView.hidden = NO;
    }
    if (!self.photoCollectionView.hidden)
    {
        self.photoCollectionView.hidden = YES;
    }
    if (!self.tabBarView.hidden)
    {
        self.tabBarView.hidden = YES;
    }
//    [UIView animateWithDuration:0.3 animations:^{
//        self.editContentView.transform = CGAffineTransformMakeScale(1, 1);
//        
//    }];
//    [self.editContentView setValue:[NSNumber numberWithFloat:1] forKey:@"scaleRation"];
    self.title = @"编辑";
    self.navigationItem.rightBarButtonItem = _saveButton;
    self.navigationItem.hidesBackButton = NO;
}
#pragma mark KVC
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedIndex"])
    {
        //防闪替换
        PHAsset *asset = self.photoAssets[[[self valueForKeyPath:@"selectedIndex"] integerValue] ];
        [self.selectedAssetsArray replaceObjectAtIndex:self.smallViewIndex withObject:asset];
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [self.editContentView.contentViewArray[self.smallViewIndex] setImageViewData:result];
        }];
    }
    if ([keyPath isEqualToString:@"smallViewIndex"])
    {
        self.smallViewIndex = [[self.editContentView valueForKey:@"smallViewIndex"] integerValue];
        if (self.smallViewIndex == -1)
        {
            WXIEditButton *mirroButton = self.editButtonArray[1];
            [mirroButton disableClick];
            
            WXIEditButton *flipButton = self.editButtonArray[2];
            [flipButton disableClick];
        }
        else
        {
            WXIEditButton *mirroButton = self.editButtonArray[1];
            [mirroButton enableClick];
            
            WXIEditButton *flipButton = self.editButtonArray[2];
            [flipButton enableClick];
            //保证在去边框的情况下，下次可以加边框
            self.addBorder = NO;
            //去除内边框
            for (WXISmallEditView *smallView in self.editContentView.subviews)
            {
                [self clearInnerBoarder:smallView];
            }
        }
    }
    
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
    [self.photoAssets removeAllObjects];
    
    NSArray<PHAsset *> *assetArray = [[WXIPhotoTool sharePhotoTool] getAllAssetInPhotoAblumWithAscending:NO];
    for (PHAsset *asset in assetArray)
    {
        [self.photoAssets addObject:asset];
    }
    
    [self.photoCollectionView reloadData];
}
#pragma mark WXIEditContentViewDelegate
- (void)movedEditView
{
    
}
#pragma mark photoCollectionViewDatasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoAssets.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCollectionCell_1" forIndexPath:indexPath];
    if (cell.contentView.subviews.count != 0)
    {
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    PHAsset *asset = self.photoAssets[indexPath.row];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(ScreenWidth / 2.f, ScreenWidth / 2.f) contentMode:PHImageContentModeDefault options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:result];
        imageView.frame = CGRectMake(0, 0, (ScreenWidth - 3) / 3.f, (ScreenWidth - 3) / 3.5f);
        //居中
        imageView.center = cell.contentView.center;
        //切掉多余的
        cell.contentView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
    }];
    return cell;
}
#pragma mark tableViewDelegate
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
        effectView.frame = CGRectMake(0, 0, ScreenWidth, ktableViewCellHeight);
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
    return ktableViewCellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *button = self.tabViewButtonArray[0];
    button.selected = NO;
    //更新菜单名字
    [button setTitle:self.photoTitleArray[indexPath.row].title forState:UIControlStateNormal];
    self.photoAlbum = (WXIPhotoAblumList *)self.photoTitleArray[indexPath.row];
    //退出菜单
    [UIView animateWithDuration:0.3 animations:^{
        self.menuTableView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - CGRectGetHeight(self.topView.frame) - CGRectGetHeight(self.tabBarView.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame) - 20);
    }];
    //获取选中相册内容，取消选中
    UICollectionViewCell *cell = [self.photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[[self valueForKey:@"selectedIndex"] integerValue] inSection:0]];
    cell.contentView.backgroundColor = nil;
    [cell.contentView.layer setBorderColor:[UIColor clearColor].CGColor];
    [cell.contentView.layer setBorderWidth:3.0f];
    
    [self.photoAssets removeAllObjects];
    self.photoAssets = [[[WXIPhotoTool sharePhotoTool] getAssetsInAssetCollection:self.photoTitleArray[indexPath.row].assetCollection ascending:NO] mutableCopy];
    [self.photoCollectionView reloadData];
    
    
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
#pragma mark photoCollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setValue:[NSNumber numberWithInteger:indexPath.row] forKey:@"selectedIndex"];
    UICollectionViewCell *selectedCell =
    [collectionView cellForItemAtIndexPath:indexPath];
    
    selectedCell.contentView.backgroundColor = nil;
    [selectedCell.contentView.layer setBorderColor:[UIColor colorWithRed:0.53 green:0.78 blue:1.00 alpha:1.00].CGColor];
    [selectedCell.contentView.layer setBorderWidth:2.0f];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *deselectedCell =
    [collectionView cellForItemAtIndexPath:indexPath];
    deselectedCell.contentView.backgroundColor = nil;
    [deselectedCell.contentView.layer setBorderColor:[UIColor clearColor].CGColor];
    [deselectedCell.contentView.layer setBorderWidth:3.0f];
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((ScreenWidth - 3) / 4.f, (ScreenWidth - 3) / 4.f);
    
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
    return CGSizeMake(ScreenWidth, 40);
}
@end
