//
//  DownLoadManagerViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-8.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "DownLoadManagerViewController.h"
#import "DownLoadingViewController.h"
#import "DownLoadedViewController.h"
#define kEdit @"编辑"
#define kCancel @"取消"



@interface DownLoadManagerViewController (){
    NSMutableArray *_controllers;//临时存放控制器
    UIView *_contentView;//内容区
    UIButton *_editBtn;//编辑按钮
    DownLoadingViewController *_dling;
    DownLoadedViewController *_dled;
    
    NSInteger _index;//0:DownLoadingViewController 1:DownLoadedViewController
    BOOL dling_edit;
    BOOL dled_edit;
}

@end

@implementation DownLoadManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - --------------------------------代理方法--------------------------------
#pragma mark - -----------------TopBar的代理方法------------------
-(void)topBarclickBtn:(UIButton *)btn{
    _index=btn.tag;
    [self setEditStatus:nil];
    [_contentView removeAllSubviews];
    UIViewController *uc=[_controllers objectAtIndex:btn.tag];
    UIView *view=uc.view;
    view.frame=_contentView.bounds;
    [_contentView addSubview:view];
}




#pragma mark - --------------------------------自定义方法--------------------------------
#pragma mark 初始化数据
-(void)initParams{
    _controllers=[NSMutableArray array];
    _dling=[[DownLoadingViewController alloc] init];
    [self addChildViewController:_dling];
    [_controllers addObject:_dling];
    
    _dled=[[DownLoadedViewController alloc] init];
    [self addChildViewController:_dling];
    [_controllers addObject:_dled];
    
    _index=0;
    dling_edit=NO;
    dled_edit=NO;
}

#pragma mark 初始化视图
-(void)initViews{
    //标题栏
    UIView *top=[self Title:@"下载管理" returnType:1];
    top.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.backView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.lable.textColor=UIColorFromRGB(0x000000);
    
    //编辑按钮
    UIButton *editBtn=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50-17, (top.frame.size.height-25)*0.5f, 50, 25)];
    editBtn.backgroundColor=UIColorFromRGB(0xffffff);
    editBtn.layer.borderWidth=0.5f;
    editBtn.layer.borderColor=[UIColorFromRGB(0xcccccc) CGColor];
    editBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    editBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [editBtn setTitle:[NSString stringWithFormat:kEdit]forState:UIControlStateNormal];
    [editBtn setTitle:[NSString stringWithFormat:kEdit]forState:UIControlStateHighlighted];
    [editBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(setEditStatus:) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:editBtn];
    _editBtn=editBtn;
    
    
    
    NSArray *array=@[@"正在下载",@"已下载"];
    TopBar *topBar=[[TopBar alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.frame.size.width, 40) array:array btnTexNormalColor:UIColorFromRGB(0x000000) btnTextSelectedColor:UIColorFromRGB(0xe86e25)];
    topBar.backgroundColor=UIColorFromRGB(0xe1e1e1);
    topBar.line.backgroundColor=UIColorFromRGB(0xe86e25);
    [self.view addSubview:topBar];
    topBar.delegate=self;
    
    _contentView=[[UIView alloc] initWithFrame:CGRectMake(0, topBar.frame.origin.y+topBar.frame.size.height, self.view.frame.size.width, KScreenSize.height-top.frame.size.height-topBar.frame.size.height-20)];
    [self.view addSubview:_contentView];
    
    
    //刷新下子控制器的界面,不刷新,里面btn的点击事件可能不响应
    UIViewController *uc=[_controllers objectAtIndex:0];
    UIViewController *uc1=[_controllers objectAtIndex:1];
    UIView *view=uc1.view;
    view.frame=_contentView.bounds;
    [_contentView addSubview:view];
    [_contentView removeAllSubviews];
    view=uc.view;
    view.frame=_contentView.bounds;
    [_contentView addSubview:view];
}


#pragma mark _editBtn设置编辑状态
-(void)setEditStatus:(UIButton *)btn{
    switch (_index) {
        case 0:{
            if (btn) {
                dling_edit=!dling_edit;
            }
            
            if (dling_edit) {
                [_editBtn setTitle:[NSString stringWithFormat:kCancel]forState:UIControlStateNormal];
                [_editBtn setTitle:[NSString stringWithFormat:kCancel]forState:UIControlStateHighlighted];

            }else{
                [_editBtn setTitle:[NSString stringWithFormat:kEdit]forState:UIControlStateNormal];
                [_editBtn setTitle:[NSString stringWithFormat:kEdit]forState:UIControlStateHighlighted];
                
            }
            
            [_dling setEditStatus:dling_edit];
            
        }
            
            break;
        case 1:{
            if (btn) {
                dled_edit=!dled_edit;
            }
            
            if (dled_edit) {
                [_editBtn setTitle:[NSString stringWithFormat:kCancel]forState:UIControlStateNormal];
                [_editBtn setTitle:[NSString stringWithFormat:kCancel]forState:UIControlStateHighlighted];
                
            }else{
                [_editBtn setTitle:[NSString stringWithFormat:kEdit]forState:UIControlStateNormal];
                [_editBtn setTitle:[NSString stringWithFormat:kEdit]forState:UIControlStateHighlighted];
                
            }
            
            [_dled setEditStatus:dled_edit];
            
        }
            
            break;
            
        default:
            break;
    }
    
    
}


@end
