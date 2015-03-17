//
//  MoreApplicationViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MoreAppViewController.h"
#import "MoreAppModel.h"
#import "MoreAppListCell.h"
#import <StoreKit/StoreKit.h>
#import "NCMConstant.h"
#import "MoreAppOtherInfoModel.h"
#import "PingLunHttpRequest.h"
#import "UIImageView+WebCache.h"
#import "NoticeOperation.h"

@interface MoreAppViewController ()
{
    UITableView *_table;
    UIImageView *_head;
    UIView *_top;
    MoreAppOtherInfoModel *_othreModel;
    UIView *_bgView;

}
@property (nonatomic,strong) NSMutableArray *data;

@end

@implementation MoreAppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initParams];
    [self initNavigationBar];
    [self initStyle];
}

-(void)initParams{
    PingLunHttpRequest *quest=[[PingLunHttpRequest alloc]init];
    [quest queryMoreApp:self andPage:@"1"];
}

-(void)initViews{
    [self initTableViewHead];
    [self initTable];
    [_bgView removeFromSuperview];
}

-(void)initStyle{
    switch (KAppStyle) {
        case APPSTYLE_TYPE_WHITE:{
            self.view.backgroundColor=KBgWitheColor;
            _table.backgroundColor=KBgWitheColor;
        }break;
        case APPSTYLE_TYPE_BLACK:{
            self.view.backgroundColor=kBgcolor;
            _table.backgroundColor=kBgcolor;
        }break;
            
        default:
            break;
    }
}

-(void)initBGView{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(initParams)];
    tap.numberOfTapsRequired=1;
    
    UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0, _top.frame.size.height+_top.frame.origin.y, 320, KScreenSize.height-_top.frame.size.height-_top.frame.origin.y)];
   // bgView.backgroundColor=[UIColor greenColor];
    [bgView addGestureRecognizer:tap];
    _bgView=bgView;
    
    UIImageView *img=[[UIImageView alloc]init];
    img.frame=CGRectMake((bgView.frame.size.width-239)*.5, (bgView.frame.size.height-34)*.5, 239, 34);
    img.image=[UIImage imageNamed:@"alert_load.png"];
    [bgView addSubview:img];
    
    UILabel *label=[[UILabel alloc]init];
    label.frame=CGRectMake((bgView.frame.size.width-200)*.5, img.bottom, 200, 30);
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=UIColorFromRGB(0X808080);
    label.text=@"点击屏幕,重新加载";
    [bgView addSubview:label];
    
    [self.view addSubview:bgView];

}

-(void)initNavigationBar{
    UIView *top=[self Title:@"更多应用" returnType:1];
    _top=top;
}
-(void)initTableViewHead{
    UIImageView *head=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 159)];
    head.image=[UIImage imageNamed:@"picture_large.png"];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]init];
    tap.numberOfTapsRequired=1;
    [tap addTarget:self action:@selector(jumpToAd)];
    head.userInteractionEnabled=YES;
    [head addGestureRecognizer:tap];
    _head=head;
    
    
}

-(void)initTable{
    UITableView *table=[[UITableView alloc]init];
    table.frame=CGRectMake(0, _top.frame.size.height+_top.frame.origin.y, 320, KScreenSize.height-_top.frame.size.height-_top.frame.origin.y);
    table.delegate=self;
    table.dataSource=self;
    table.tableHeaderView=_head;
    table.separatorStyle=UITableViewCellSeparatorStyleNone;
    table.indicatorStyle=UIScrollViewIndicatorStyleWhite;
    _table=table;
    [self.view addSubview:table];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    MoreAppListCell *cell=(MoreAppListCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    return 70;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identificer=@"ModeAppListCell";
    MoreAppListCell *cell=[tableView dequeueReusableCellWithIdentifier:identificer];
    if (cell==nil) {
        cell=[[MoreAppListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identificer];
    }
    MoreAppModel *model=[self.data objectAtIndex:indexPath.row];
    [cell setCellValue:model];
    return cell;
}

#pragma mark -点击方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MoreAppModel *model=[self.data objectAtIndex:indexPath.row];
    BOOL isOpen=[[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:model.scheme]];
    if (isOpen) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"确定要打开 %@",model.title] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alert.tag=indexPath.row;
        [alert show];
    }else{
       // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:model.url]];
        SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
        storeProductVC.delegate = self;
        NSDictionary *dict = [NSDictionary dictionaryWithObject:model.ID forKey:SKStoreProductParameterITunesItemIdentifier];
        [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
            if (result) {
              
            }
        }];
          [self presentViewController:storeProductVC animated:YES completion:nil];
        NSLog(@"不能打开----------application");
    }
}

#pragma mark -alertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:model.url]];
        } break;
        case 1:{
           MoreAppModel *model=[self.data objectAtIndex:alertView.tag];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:model.scheme]];
        }break;
        default:
        break;
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -数据回调
-(void)moreAppQueryInfoBackData:(NSArray *)moreApp and:(MoreAppOtherInfoModel *)model isSuccess:(BOOL)success{
    if (success) {
        [self initViews];
        _othreModel=model;
        self.data=(NSMutableArray *)moreApp;
        [_table reloadData];
        [_head setImageWithURL:[NSURL URLWithString:model.advImageUrl] placeholderImage:[UIImage imageNamed:@"picture_large.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
        }];
    }else{
        [_bgView removeFromSuperview];
        [self initBGView];
        NoticeOperation *notice=[[NoticeOperation alloc]init];
        [notice showAlertWithMsg:KNoticeLoadMoreAppFailTitle  imageName:KNoticeLoadMoreAppFailIcon toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
    }
}

#pragma mark -跳到广告页
-(void)jumpToAd{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_othreModel.adActionUrl]];

}

#pragma mark -delloc
-(void)dealloc{
    NSLog(@"--------MoreApp--------dealloc");
    self.data=nil;
    _table=nil;
    _head=nil;
    _top=nil;
    _bgView=nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
