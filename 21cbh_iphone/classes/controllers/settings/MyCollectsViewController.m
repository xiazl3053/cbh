//
//  MyCollectsViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MyCollectsViewController.h"
#import "ArticleCollectViewController.h"
#import "PicCollectViewController.h"
#import "CommentCollectViewController.h"

@interface MyCollectsViewController (){
    UIView *_top;
    UIButton *_editBtn;//编辑按钮
    UIView *_contentView;//内容区
    NSMutableArray *_controllers;//临时存放控制器
    BOOL _isEdit;
    
    ArticleCollectViewController *_acv;
    PicCollectViewController *_pcv;
    CommentCollectViewController *_ccv;
}

@end

@implementation MyCollectsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化数据
    [self initParams];
    //初始化布局
    [self initViews];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - --------------以下为自定义方法---------------------
#pragma mark 初始化数据
-(void)initParams{
    _isEdit=NO;
    _controllers=[NSMutableArray array];
    
    ArticleCollectViewController *acv=[[ArticleCollectViewController alloc] init];
    acv.mcv=self;
    acv.main=self.main;
    acv.dbQueue=self.main.dbQueue;
    [self addChildViewController:acv];
    [_controllers addObject:acv];
    _acv=acv;
    
    PicCollectViewController *pcv=[[PicCollectViewController alloc] initWithStyle:UITableViewStylePlain];
    pcv.mcv=self;
    pcv.main=self.main;
    pcv.dbQueue=self.main.dbQueue;
    [self addChildViewController:pcv];
    [_controllers addObject:pcv];
    _pcv=pcv;
    
    CommentCollectViewController *ccv=[[CommentCollectViewController alloc] initWithStyle:UITableViewStylePlain];
    ccv.mcv=self;
    ccv.main=self.main;
    ccv.dbQueue=self.main.dbQueue;
    [self addChildViewController:ccv];
    [_controllers addObject:ccv];
    _ccv=ccv;
}

#pragma mark 初始布局
-(void)initViews{
    //标题栏
    UIView *top=[self Title:@"我的收藏" returnType:2];
    _top=top;
    
    //编辑按钮
    UIButton *editBtn=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50-17, (top.frame.size.height-25)*0.5f, 50, 25)];
    editBtn.backgroundColor=UIColorFromRGB(0xffffff);
    editBtn.layer.borderWidth=0.5f;
    editBtn.layer.borderColor=[UIColorFromRGB(0xcccccc) CGColor];
    editBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    editBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [editBtn setTitle:[NSString stringWithFormat:@"编辑"]forState:UIControlStateNormal];
    [editBtn setTitle:[NSString stringWithFormat:@"编辑"]forState:UIControlStateHighlighted];
    [editBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
    [editBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateHighlighted];
//    [editBtn setImage:[UIImage imageNamed:@"MyCollects_Edit_normal.png"] forState:UIControlStateNormal];
//    [editBtn setImage:[UIImage imageNamed:@"MyCollects_Edit_Highlighted.png"] forState:UIControlStateHighlighted];
  
    [editBtn addTarget:self action:@selector(setEditStatus) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:editBtn];
    _editBtn=editBtn;
    
    NSArray *array=@[@"文章",@"图集",@"跟贴"];
    TopBar *topBar=[[TopBar alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.frame.size.width, 40) array:array btnTexNormalColor:UIColorFromRGB(0x000000) btnTextSelectedColor:UIColorFromRGB(0xe86e25)];
    topBar.backgroundColor=UIColorFromRGB(0xe1e1e1);
    topBar.line.backgroundColor=UIColorFromRGB(0xe86e25);
    [self.view addSubview:topBar];
    topBar.delegate=self;
    
    _contentView=[[UIView alloc] initWithFrame:CGRectMake(0, topBar.frame.origin.y+topBar.frame.size.height, self.view.frame.size.width, KScreenSize.height-top.frame.size.height-topBar.frame.size.height-20)];
    [self.view addSubview:_contentView];
    
    UIViewController *uc=[_controllers objectAtIndex:0];
    UIView *view=uc.view;
    view.frame=_contentView.bounds;
    [_contentView addSubview:view];
}

-(void)setEditStatus{
    _isEdit=!_isEdit;
    [_acv setEditStatus:_isEdit];
    [_pcv setEditStatus:_isEdit];
    [_ccv setEditStatus:_isEdit];
    if (_isEdit) {
        [_editBtn setTitle:[NSString stringWithFormat:@"完成"]forState:UIControlStateNormal];
        [_editBtn setTitle:[NSString stringWithFormat:@"完成"]forState:UIControlStateHighlighted];
//        [_editBtn setImage:[UIImage imageNamed:@"FeedBack_Done_normal.png"] forState:UIControlStateNormal];
//        [_editBtn setImage:[UIImage imageNamed:@"FeedBack_Done_hlight.png"] forState:UIControlStateHighlighted];
    }else{
        [_editBtn setTitle:[NSString stringWithFormat:@"编辑"]forState:UIControlStateNormal];
        [_editBtn setTitle:[NSString stringWithFormat:@"编辑"]forState:UIControlStateHighlighted];
//        [_editBtn setImage:[UIImage imageNamed:@"MyCollects_Edit_normal.png"] forState:UIControlStateNormal];
//        [_editBtn setImage:[UIImage imageNamed:@"MyCollects_Edit_Highlighted.png"] forState:UIControlStateHighlighted];
    }
    
}


#pragma mark - -----------------TopBar的代理方法------------------
-(void)topBarclickBtn:(UIButton *)btn{
    NSLog(@"topBar的btn.tag==%i",btn.tag);
    [_contentView removeAllSubviews];
    UIViewController *uc=[_controllers objectAtIndex:btn.tag];
    UIView *view=uc.view;
    view.frame=_contentView.bounds;
    [_contentView addSubview:view];
}


@end
