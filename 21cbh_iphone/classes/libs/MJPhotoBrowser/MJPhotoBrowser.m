//
//  MJPhotoBrowser.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "MJPhotoView.h"
#import "PicRecommendViewController.h"
#import "PicsListModel.h"
#import "PicDetailModel.h"
#import "XinWenHttpMgr.h"
#import "NoticeOperation.h"
#import "PicsListDB2.h"
#import "PicDetailDB.h"
#import "PicsListCollectDB.h"
#import "NewsCommentViewController.h"
#import "ShareViewController.h"
#import "MJPhotoToolbar.h"
#import "PicInfoModel.h"
#import "PicInfoModelDB.h"

#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface MJPhotoBrowser () <MJPhotoViewDelegate>
{
    UIView *_top;//标题栏
    UIButton *_cmnBtn;//评论数按钮
    UIView *_loadView;//加载提示view
    UIView *_reloadView;//重新加载view
    
    // 滚动的view
	UIScrollView *_photoScrollView;
    // 所有的图片view
	NSMutableSet *_visiblePhotoViews;
    NSMutableSet *_reusablePhotoViews;
    // 工具条
    MJPhotoToolbar *_toolbar;
    
    PicRecommendViewController *_prvc;
    
    bool isShow;//控制标题栏和底部栏显示
    bool isLocal;//本地是否有资源
}

@property(strong,nonatomic)NSMutableArray *pdms;//该图集的实体类
@property(strong,nonatomic)NSMutableArray *plms;//推荐图集的实体类
@property(strong,nonatomic)PicInfoModel *pim;
@property(weak,nonatomic) NSOperationQueue *dbQueue;//数据库操作队列
@property(strong,nonatomic) PicsListDB2 *plDB2;
@property(strong,nonatomic) PicDetailDB *pdDB;
@property(strong,nonatomic) PicsListCollectDB *plcDB;
@property(strong,nonatomic) PicInfoModelDB *pimDB;

@end

@implementation MJPhotoBrowser

-(id)initWithProgramId:(NSString *)programId picsId:(NSString *)picsId followNum:(NSString *)followNum main:(UIViewController *)main{
    self=[super init];
    if (self) {
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        [dic setValue:programId forKey:@"programId"];
        [dic setValue:picsId forKey:@"picsId"];
        [dic setValue:followNum forKey:@"followNum"];
        
        PicsListModel *plm=[[PicsListModel alloc] initWithDict:dic];
        self.plm=plm;
        self.main=main;
    }
    
    return self;
}


-(id)initWithProgramId:(NSString *)programId picsId:(NSString *)picsId followNum:(NSString *)followNum main:(UIViewController *)main isReturn:(BOOL)isReturn{
    self=[super init];
    if (self) {
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        [dic setValue:programId forKey:@"programId"];
        [dic setValue:picsId forKey:@"picsId"];
        [dic setValue:followNum forKey:@"followNum"];
        
        PicsListModel *plm=[[PicsListModel alloc] initWithDict:dic];
        self.plm=plm;
        self.main=main;
        self.isReturn=isReturn;
    }
    
    return self;
}





#pragma mark - Lifecycle

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[[UIApplication sharedApplication] setStatusBarHidden:isShow];
    //监听未读消息数
    [_toolbar listenToMessageNum:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [[SDImageCache sharedImageCache] clearMemory];
    [super viewDidDisappear:YES];
}

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
	self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化参数和变量
    [self initParams];
    //初始化标题栏
    [self initTop];

    //加载数据
    [self loadLocalData];
}


-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [self cleanImages];
}

-(void)dealloc
{
    [self cleanImages];
}

#pragma mark - -------------------------以下为自定义方法----------------------------
#pragma mark 初始化参数和变量
-(void)initParams{
    _prvc=[[PicRecommendViewController alloc] init];
    _prvc.main=self.main;
    [self addChildViewController:_prvc];
    self.pdms=[NSMutableArray array];
    self.plms=[NSMutableArray array];
    self.plDB2=[[PicsListDB2 alloc] init];
    self.pdDB=[[PicDetailDB alloc] init];
    self.plcDB=[[PicsListCollectDB alloc] init];
    self.pimDB=[[PicInfoModelDB alloc] init];
    self.dbQueue=self.main.dbQueue;
    isShow=NO;
    isLocal=NO;
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setValue:self.plm.programId forKey:@"programId"];
    [dic setValue:self.plm.picsId forKey:@"picsId"];
    [dic setValue:self.plm.type forKey:@"type"];
    [dic setValue:self.plm.title forKey:@"title"];
    [dic setValue:self.plm.followNum forKey:@"followNum"];
    [dic setValue:self.plm.picUrls forKey:@"picUrls"];
    [dic setValue:self.plm.order forKey:@"order"];
    [dic setValue:self.plm.addtime forKey:@"addtime"];
    
    PicsListModel *plm=[[PicsListModel alloc] initWithDict:dic];
    self.plm=plm;
    
}

#pragma mark 初始标题栏
-(void)initTop{
    //顶部标题栏
    _top=[self Title:@"" returnType:1];
    self.view.backgroundColor=k000000;

    //评论数
    UIButton *cmnBtn=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-15-53, (_top.frame.size.height-25)*0.5f, 53, 25)];
    cmnBtn.backgroundColor=UIColorFromRGB(0xffffff);
    cmnBtn.titleLabel.font=[UIFont fontWithName:kFontName size:12];
    cmnBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    cmnBtn.layer.borderWidth=0.5f;
    cmnBtn.layer.borderColor=[UIColorFromRGB(0xcccccc) CGColor];
    [cmnBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
    [cmnBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateHighlighted];
    [_top addSubview:cmnBtn];
    _cmnBtn=cmnBtn;
    [_cmnBtn setTitle:[NSString stringWithFormat:@"%@评",self.plm.followNum] forState:UIControlStateNormal];
    [_cmnBtn setTitle:[NSString stringWithFormat:@"%@评",self.plm.followNum] forState:UIControlStateHighlighted];
    [_cmnBtn addTarget:self action:@selector(goToNcv) forControlEvents:UIControlEventTouchUpInside];
    
    [_top removeFromSuperview];
    [self.view addSubview:_top];
}

#pragma mark 图集尾部添加推荐图集
-(void)addPicRecommendView{
    CGRect frame=CGRectMake(self.view.frame.size.width * (_photos.count), 0, _prvc.view.frame.size.width, _prvc.view.frame.size.height);
    _prvc.view.frame=frame;
    _photoScrollView.contentSize = CGSizeMake(self.view.frame.size.width * (_photos.count+1), 0);
    [_photoScrollView addSubview:_prvc.view];
}

#pragma mark 初始化视图
-(void)initViews{
    
    // 1.创建UIScrollView
    [self createScrollView];
    
    [_top removeFromSuperview];
    [self.view addSubview:_top];
    
    // 2.创建工具条
    [self createToolbar];
    
    //显示图片
    [self showPhotos];
}

-(void)cleanImages
{
    for (MJPhotoView* ptView in _visiblePhotoViews) {
        [ptView clearImage];
        // NSLog(@"ptView.photo.url:%@",ptView.photo.url);
    }
}

#pragma mark 移除旧视图刷新界面
-(void)refreshView{
    if (_photoScrollView) {
        [_photoScrollView removeFromSuperview];
    }
    if (_toolbar) {
        [_toolbar removeFromSuperview];
    }
}

#pragma mark 创建工具条
- (void)createToolbar
{
    CGFloat barHeight =135;
    CGFloat barY = self.view.frame.size.height - barHeight;
    _toolbar = [[MJPhotoToolbar alloc] init];
    
    //设置数据
    _toolbar.plm=self.plm;
    _toolbar.pdms=_pdms;
    _toolbar.delegate=self;
    _toolbar.mpb=self;
    _toolbar.dbQueue=self.dbQueue;
    _toolbar.plcDB=self.plcDB;
    
    _toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _toolbar.backgroundColor=[UIColor clearColor];
    _toolbar.photos = _photos;
    [self.view addSubview:_toolbar];
    
    [self updateTollbarState];
}

#pragma mark 创建UIScrollView
- (void)createScrollView
{
    CGRect frame = self.view.bounds;
    frame.origin.x -= 0;
    frame.size.width += 0;
	_photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
	_photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_photoScrollView.pagingEnabled = YES;
	_photoScrollView.delegate = self;
	_photoScrollView.showsHorizontalScrollIndicator = NO;
	_photoScrollView.showsVerticalScrollIndicator = NO;
	_photoScrollView.backgroundColor = [UIColor clearColor];
    _photoScrollView.contentSize = CGSizeMake(frame.size.width * _photos.count, 0);
	[self.view addSubview:_photoScrollView];
    _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
}

#pragma mark 加载本地资源
-(void)loadLocalData{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //图集详情本地资源
        self.pdms=[self.pdDB getPdmsWithHostPicsId:self.plm.picsId];
        
        self.plms=[self.plDB2 getPlmsWithHostPicsId:self.plm.picsId];
        
        NSMutableArray *pims=[self.pimDB getPimWithProgramId:self.plm.programId picsId:self.plm.picsId];
        if (pims.count>0) {
            self.pim=[pims objectAtIndex:0];
        }
        
        
        if (self.pdms&&self.pdms.count>0) {
            isLocal=YES;
            NSMutableArray *photos = [NSMutableArray array];
            for (int i = 0; i<self.pdms.count; i++) {
                PicDetailModel *pdm=[self.pdms objectAtIndex:i];
                MJPhoto *photo = [[MJPhoto alloc] init];
                photo.url = [NSURL URLWithString:[pdm.picUrls objectAtIndex:0]]; // 图片路径
                [photos addObject:photo];
            }
            self.photos = photos; // 设置所有的图片
            dispatch_async(dispatch_get_main_queue(), ^{
                //加载滚动图集
                [self refreshView];
                [self initViews];
                if (self.plms&&self.plms.count>0){
                    //推荐图集视图
                    [self addPicRecommendView];
                    [_prvc loadData:self.plms];
                }
                //图集详情接口请求
                [self getPicsDetail:self.plm.picsId programId:self.plm.programId];
            });
            
            //这里改变数据是为了图片收藏列表的保存
            PicDetailModel *pdm=[self.pdms objectAtIndex:0];
            self.plm.type=@"0";
            self.plm.picUrls=pdm.picUrls;
            
        }else{
            isLocal=NO;
            //图集详情接口请求
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getPicsDetail:self.plm.picsId programId:self.plm.programId];
           });
        }
    });
}

#pragma mark 跳转到评论页
-(void)goToNcv{
    if (!self.plm) {
        return;
    }
    NewsCommentViewController *ncv=[[NewsCommentViewController alloc] initWithProgramId:self.plm.programId andFollowID:self.plm.picsId];
    ncv.main=self.main;
    [self.navigationController pushViewController:ncv animated:YES];
}

#pragma mark 获取图集详情信息
-(void)getPicsDetail:(NSString *)picsId programId:(NSString *)programId{
    if (!isLocal) {
        _loadView=[[NoticeOperation getId] getLoadView:self.view imageName:@"alert_load_black"];
    }
    
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.mpb=self;
    [hmgr picsDetailWithPicsId:picsId programId:programId];
}

#pragma mark 获取图集详情信息后的处理
-(void)getPicsDetailHandle:(NSMutableArray *)pdms plms:(NSMutableArray *)plms dic:(NSMutableDictionary *)dic{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!isLocal) {
            [[NoticeOperation getId] viewFaceOut:_loadView];
        }
        
    });
    
    if (!pdms) {//如果没数据下面不执行
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isLocal) {
                _reloadView=[[NoticeOperation getId] getReLoadview:self.view obj:self imageName:@"alert_load_black"];
            }
        });
        
        return;
    }
    
    //这里是将相关数据存进数据库
    if (pdms&&pdms.count>0) {
        [self.dbQueue addOperationWithBlock:^{
            [self.pdDB deletePdmWithHostPicsId:self.plm.picsId];
            for (int i=pdms.count-1; i>=0; i--) {
                PicDetailModel *pdm=[pdms objectAtIndex:i];
                [self.pdDB insertPdm:pdm hostPicsId:self.plm.picsId];
            }
            
            if (plms&&plms.count>0){
                [self.plDB2 deletePlmWithHostPicsId:self.plm.picsId];
                for (int i=plms.count-1; i>=0; i--) {
                    PicsListModel *plm=[plms objectAtIndex:i];
                    [self.plDB2 insertPlm:plm hostPicsId:self.plm.picsId];
                }
            }
            
            PicInfoModel *pim=[[PicInfoModel alloc] initWithDict:dic];
            pim.programId=self.plm.programId;
            pim.picsId=self.plm.picsId;
            self.pim=pim;
            [self.pimDB deletePim:pim];
            [self.pimDB insertPim:pim];
        }];
        
        //这里改变数据是为了图片收藏列表的保存
        PicDetailModel *pdm=[pdms objectAtIndex:0];
        self.plm.type=@"0";
        self.plm.picUrls=pdm.picUrls;
        self.plm.title=[dic objectForKey:@"title"];
        self.plm.followNum=[dic objectForKey:@"followNum"];
        self.plm.addtime=[dic objectForKey:@"addtime"];
        self.plm.order=[dic objectForKey:@"order"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_cmnBtn setTitle:[NSString stringWithFormat:@"%@评",[dic objectForKey:@"followNum"]] forState:UIControlStateNormal];
            [_cmnBtn setTitle:[NSString stringWithFormat:@"%@评",[dic objectForKey:@"followNum"]] forState:UIControlStateHighlighted];
        });
        
        if (isLocal) {//本地有数据就不刷新界面了,下面不执行
            return;
        }
        
        
        self.pdms=pdms;
        // 1.封装图片数据
        NSMutableArray *photos = [NSMutableArray array];
        for (int i = 0; i<self.pdms.count; i++) {
            PicDetailModel *pdm=[self.pdms objectAtIndex:i];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:[pdm.picUrls objectAtIndex:0]]; // 图片路径
            [photos addObject:photo];
        }
        
        self.photos = photos; // 设置所有的图片
        dispatch_async(dispatch_get_main_queue(), ^{
            //加载滚动图集
            [self refreshView];
            [self initViews];
            if (plms&&plms.count){
                 self.plms=plms;
                //推荐图集视图
                [self addPicRecommendView];
                [_prvc loadData:plms];
            }

        });
    }
    
}

#pragma mark 点击重新加载
-(void)clickReload{
    if (_reloadView) {
        [_reloadView removeFromSuperview];
        [self getPicsDetail:self.plm.picsId programId:self.plm.programId];
    }
}

-(void)returnBack{
    [super returnBack];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
}


- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    
}

#pragma mark 设置选中的图片
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}


#pragma mark 显示照片
- (void)showPhotos
{
    // 只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
	int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)) / CGRectGetWidth(visibleBounds));
	int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = _photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = _photos.count - 1;
	
	// 回收不再显示的ImageView
    NSInteger photoViewIndex;
	for (MJPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
		if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
			[_reusablePhotoViews addObject:photoView];
			[photoView removeFromSuperview];
		}
	}
    
	[_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
	
	for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
		if (![self isShowingPhotoViewAtIndex:index]) {
			[self showPhotoViewAtIndex:index];
		}
	}
}

#pragma mark 显示一个图片view
- (void)showPhotoViewAtIndex:(int)index
{
    MJPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[MJPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.origin.x = (bounds.size.width * index);
    //奇葩,不知道这里为什么要相差64,不这样设置就无法居中显示
    //photoViewFrame.origin.y=(bounds.size.height-photoViewFrame.size.height)*0.5f-64;
    //photoViewFrame.size.height+=64;
    //NSLog(@"photoViewFrame.origin.y:%f",photoViewFrame.origin.y);
    photoView.tag = kPhotoViewTagOffset + index;
    
    MJPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    [photoView reloadImageView];
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

#pragma mark 加载index附近的图片
- (void)loadImageNearIndex:(int)index
{
    
    if (index > 0) {
        MJPhoto *photo = _photos[index - 1];
        UIImageView *iv=[[UIImageView alloc] init];
        [self.view addSubview:iv];
        __block UIImageView *iv1=iv;
        [iv setImageWithURL:photo.url  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [iv1 removeFromSuperview];
            
        }];
    }
    
    if (index < _photos.count - 1) {
        MJPhoto *photo = _photos[index + 1];
        UIImageView *iv=[[UIImageView alloc] init];
        [self.view addSubview:iv];
        __block UIImageView *iv1=iv;
        [iv setImageWithURL:photo.url  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [iv1 removeFromSuperview];
            
        }];
    }
}

#pragma mark index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
	for (MJPhotoView *photoView in _visiblePhotoViews) {
		if (kPhotoViewIndex(photoView) == index) {
           return YES;
        }
    }
	return  NO;
}

#pragma mark 循环利用某个view
- (MJPhotoView *)dequeueReusablePhotoView
{
    MJPhotoView *photoView = [_reusablePhotoViews anyObject];
	if (photoView) {
		[_reusablePhotoViews removeObject:photoView];
        if (photoView.loadView ) {
            photoView.loadView.hidden=YES;
        }
        
        if (photoView.reloadView) {
            photoView.reloadView.hidden=YES;
        }
	}
    
	return photoView;
}

#pragma mark 更新视图的显示状态
-(void)updateViewStatus:(BOOL)b{
    _toolbar.hidden=b;
    _cmnBtn.hidden=b;
    if (b) {
        self.lable.text=@"推荐图集";
    }else{
        self.lable.text=@"";
    }
}

#pragma mark 更新toolbar状态
- (void)updateTollbarState
{
    if (_photoScrollView.contentOffset.x>_photoScrollView.frame.size.width * (_photos.count-1)+120) {
        [self updateViewStatus:YES];
        return;
    }
    [self updateViewStatus:isShow];
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - ---------------------UIScrollView Delegate-----------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_photoScrollView.contentOffset.x>_photoScrollView.frame.size.width * (_photos.count)-1) {//如果滑到推荐图集就恢复最后一张图的frame
        MJPhotoView *photoView=(MJPhotoView *)[_photoScrollView viewWithTag:(kPhotoViewTagOffset + _photos.count-1)];
        [photoView adjustFrame];
    }
    
    [self showPhotos];
    [self updateTollbarState];
}

#pragma mark - -----------------------MJPhotoView代理---------------------------
- (void)photoViewSingleTap:(MJPhotoView *)photoView
{
    isShow=!isShow;
    _top.hidden=isShow;
    _toolbar.hidden=isShow;
    _cmnBtn.hidden=isShow;
    //[[UIApplication sharedApplication] setStatusBarHidden:isShow];
}

- (void)photoViewDidEndZoom:(MJPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView
{
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - -----------------------MJPhotoToolbar代理---------------------------
-(void)clickShareBtn{
    ShareViewController *svc=[[ShareViewController alloc] initWithTitle:self.pim.title  url:self.pim.shareUrl icon:self.pim.sharePic controller:self];
    [self addChildViewController:svc];
    [self.view addSubview:svc.view];
}

@end