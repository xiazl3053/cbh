//
//  PicRecommendViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PicRecommendViewController.h"
#import "UIImageView+WebCache.h"
#import "PicsListModel.h"
#import "MJPhotoBrowser.h"
#import "MJRefresh.h"

#define kContentHeight 412
#define knormalPicWidth 159
#define kCommonHeight 132

@interface PicRecommendViewController (){
    UIScrollView *_contentView;
    NSMutableArray *_plms;
    MJRefreshHeaderView *_header;
    int index;
}

@property(strong,nonatomic)NSMutableArray *imageViews;
@property(strong,nonatomic)NSMutableArray *lables;

@end

@implementation PicRecommendViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)dealloc
{
    [_plms removeAllObjects];
    _plms=nil;
    [self.imageViews removeAllObjects];
    self.imageViews=nil;
    [self.lables removeAllObjects];
    self.lables=nil;
    [_header free];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.imageViews removeAllObjects];
    [self.lables removeAllObjects];
}

#pragma mark - ------------自定义方法--------------------
#pragma mark 初始化数据
-(void)initParams{
    self.imageViews=[NSMutableArray array];
    self.lables=[NSMutableArray array];
    index=0;
}

#pragma mark 初始化视图
-(void)initViews{
    //顶部标题栏
    UIView *top=[self Title:@"推荐图集" returnType:1];
    self.view.backgroundColor=[UIColor clearColor];
    top.backgroundColor=[UIColor clearColor];
    self.backView.backgroundColor=[UIColor clearColor];
    self.returnBtn.hidden=YES;
    
    CGRect frame=CGRectMake(0, (self.view.frame.size.height-kContentHeight)*0.5f+30, self.view.frame.size.width, kContentHeight);
    UIScrollView *contentView=[[UIScrollView alloc] initWithFrame:frame];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.contentSize=CGSizeMake(self.view.frame.size.width, kContentHeight+1);
    [self.view addSubview:contentView];
    _contentView=contentView;
    
    [self initImageViewWithFrame:CGRectMake(0, 0, knormalPicWidth, kCommonHeight) defaultImageName:@"PicRecommend_default_normal"];
    
    [self initImageViewWithFrame:CGRectMake(self.view.frame.size.width-knormalPicWidth, 0, knormalPicWidth, kCommonHeight) defaultImageName:@"PicRecommend_default_normal"];
    
    [self initImageViewWithFrame:CGRectMake(0, kCommonHeight+3, self.view.frame.size.width, kCommonHeight) defaultImageName:@"PicRecommend_default_large"];
    
    [self initImageViewWithFrame:CGRectMake(0, (kCommonHeight+3)*2, knormalPicWidth, kCommonHeight) defaultImageName:@"PicRecommend_default_normal"];
    
    [self initImageViewWithFrame:CGRectMake(self.view.frame.size.width-knormalPicWidth, (kCommonHeight+3)*2, knormalPicWidth, kCommonHeight) defaultImageName:@"PicRecommend_default_normal"];
    
    [self addHeader];
}

- (void)addHeader
{
    __unsafe_unretained PicRecommendViewController *prv = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _contentView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [prv loadData:_plms];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        //NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                //NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                //NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    _header = header;
    _header.activityView.color=K808080;
}

#pragma mark 初始化imageView
-(void)initImageViewWithFrame:(CGRect)frame defaultImageName:(NSString *)defaultImageName{
    UIButton *view=[[UIButton alloc] initWithFrame:frame];
    view.tag=index;
    [view addTarget:self action:@selector(clickImageView:) forControlEvents:UIControlEventTouchUpInside];

    
    UIImage *img=[UIImage imageNamed:defaultImageName];
    UIImageView *iv=[[UIImageView alloc] initWithFrame:frame];
    iv.contentMode=UIViewContentModeScaleToFill;
    [iv setImage:img];
    [_contentView addSubview:iv];
    [self.imageViews addObject:iv];
    
    CGFloat height=(index==2)?27:47;
    
    UIView *maskView=[[UIView alloc] initWithFrame:CGRectMake(iv.frame.origin.x,iv.frame.origin.y+iv.frame.size.height-height, iv.frame.size.width, height)];
    maskView.backgroundColor=[UIColor blackColor];
    maskView.alpha=0.45;
    [_contentView addSubview:maskView];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(iv.frame.origin.x+10,iv.frame.origin.y+iv.frame.size.height-height, iv.frame.size.width-20, height)];
    label.textColor=[UIColor whiteColor];
    label.font=[UIFont fontWithName:kFontName size:12];
    label.textAlignment=NSTextAlignmentLeft;
    [_contentView addSubview:label];
    //自动折行设置
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    [self.lables addObject:label];
    
    [_contentView addSubview:view];
    index++;

}

#pragma mark 下载图片
-(void)loadData:(NSMutableArray *)plms{
    if (plms&&plms.count>0) {
        _plms=plms;
        for (int i=0; i<plms.count; i++) {
            PicsListModel *plm=[plms objectAtIndex:i];
            UILabel *label=[self.lables objectAtIndex:i];
            label.text=plm.title;
            
            if (plm.picUrls.count<1) {
                return;
            }
            
            UIImageView *iv=[self.imageViews objectAtIndex:i];
            __block UIImageView *iv1=iv;
            [iv setImageWithURL:[NSURL URLWithString:[plm.picUrls objectAtIndex:0]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (image) {
                    [iv1 setImage:image];
                    if (cacheType!=2) {
                        iv1.alpha=0.0;
                        [UIView animateWithDuration:kAnimateTime animations:^{iv1.alpha=1.0;} completion:^(BOOL finished) {}];
                    }
                }
            }];
        }
    }
    [self performSelector:@selector(doneWithView:) withObject:_header afterDelay:0.5];
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

#pragma mark 图片点击
-(void)clickImageView:(UIButton *)btn{
    
    if (_plms) {
        PicsListModel *plm=[_plms objectAtIndex:btn.tag];
        MJPhotoBrowser *mpb=[[MJPhotoBrowser alloc] init];
        mpb.main=self.main;
        mpb.plm=plm;
        [self.navigationController pushViewController:mpb animated:YES];
    }
    
    NSLog(@"点击了图片%i",btn.tag);
}

@end
