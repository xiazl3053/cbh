//
//  MainEngine.m
//  21cbh_iphone
//
//  Created by Franky on 14-5-7.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MainEngine.h"
#import "NewsDetailViewController.h"
#import "kNewsDetailViewController.h"
#import "KLineViewController.h"
#import "CommonOperation.h"
#import "selfMarketMessageDB.h"
#import "MainViewController.h"
#import "ChatLogIn.h"

@interface MainEngine()
{
    NSMutableArray* infoArray;//推送消息的用户消息内容列表
    MainViewController* _main;
}
@end

@implementation MainEngine

-(id)initWithMain:(UIViewController*)viewController
{
    if(self=[super init]){
        _main=(MainViewController*)viewController;
        infoArray=[[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

#pragma mark 列表出栈
-(NSDictionary*)pop
{
    if(infoArray&&infoArray.count>0)
    {
        NSDictionary* dic=infoArray.lastObject;
        [infoArray removeLastObject];
        return dic;
    }
    return nil;
}

#pragma mark 列表进栈
-(void)push:(NSDictionary*)dic
{
    [infoArray addObject:dic];
}

#pragma mark 推送跳转
-(void)pushGotoWhere:(NSDictionary*)dic
{
    NSLog(@"执行通知跳转");
    
    if (!dic) {
        return;
    }
    NSString *typeString=[dic objectForKey:@"type"];
    if (!typeString) {
        NSLog(@"apple推送通知的跳转类型type为空!");
        return;
    }
    
    int type=[typeString intValue];
    
    //类型(0:普通文章; 1:原创文章; 2:专题; 3:图集 4:视频; 5:推广 6:独家 7:个股 8:股票公告 9:私信)
    switch (type) {
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
            break;
        case 5:
            
            break;
        case 7://跳转到个股详情
            [self turnToIndividualWithDic:dic];
            break;
        case 8://跳转到公告
            [self turnTokNewsDetailWithDic:dic];
            break;
        case 9://跳转到私信
            [self turnToChat];
            break;
        default://跳转到新闻页
            [self turnToNewsDetailWithDic:dic];
            break;
    }
    
}

#pragma mark 跳转到新闻详情页
-(void)turnToNewsDetailWithDic:(NSDictionary *)dic{
    @try {
        NSString *programId=[dic objectForKey:@"programId"];
        NSString *pushId=[dic objectForKey:@"pushId"];
        NewsDetailViewController *ndv=[[NewsDetailViewController alloc] init];
        ndv.main=_main;
        ndv.programId=programId;
        ndv.articleId=pushId;
        [[CommonOperation getId] gotoViewController:ndv];
    }
    @catch (NSException *exception) {
        NSLog(@"apple推送通知的跳转新闻详情异常");
    }
    @finally {
        
    }
    
}

#pragma mark 跳转个股详情
-(void)turnToIndividualWithDic:(NSDictionary *)dic{
    @try {
        NSString *kId=[dic objectForKey:@"kId"];
        NSString *kType=[dic objectForKey:@"kType"];
        NSString *remindType=[dic objectForKey:@"remindType"];
        KLineViewController *kLineController=[[KLineViewController alloc] initWithPush:kId KType:[kType intValue] KName:nil RemindType:remindType];
        [[CommonOperation getId] gotoViewController:kLineController];
    }
    @catch (NSException *exception) {
        NSLog(@"apple推送通知的跳转个股详情异常");
    }
    @finally {
        
    }
}

#pragma mark 跳转到公告页
-(void)turnTokNewsDetailWithDic:(NSDictionary *)dic{
    @try {
        NSString *pushId=[dic objectForKey:@"pushId"];
        NSString *kId=[dic objectForKey:@"kId"];
        NSString *kType=[dic objectForKey:@"kType"];
        kNewsDetailViewController *notice = [[kNewsDetailViewController alloc] initNoticeWithArticleId:pushId andkId:kId andkType:kType];
        [[CommonOperation getId] gotoViewController:notice];
    }
    @catch (NSException *exception) {
        NSLog(@"apple推送通知的跳转公告页异常");
    }
    @finally {
        
    }
}

#pragma mark 跳转到私信
-(void)turnToChat{
    if (!isActive) {
        [[ChatLogIn getId] manualLoginWithModel:nil];
    }

}


#pragma mark - PushNotificationHandlerDelegate
-(void)handleRecievePushNotification:(NSDictionary *)userInfo withStart:(BOOL)start
{
    if (!isActive){//点击通知栏进来的
        [self pushGotoWhere:userInfo];
        
    }else{//应用没关闭,推送过来了
        [self push:userInfo];
        if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                           delegate:self
                                                  cancelButtonTitle:@"忽略"
                                                  otherButtonTitles:@"查看",nil];
            alert.tag=1000;
            [alert show];
            
        }
    }
    
    //清除通知栏的通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

-(void)sendDeviceTokenToServer:(NSString *)deviceToken withBaiduPushChannel:(NSString *)pushChannel withBaiduPushUserID:(NSString *)pushUserID delegate:(id)delegate
{
    
}

#pragma mark - UIAlertView代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1000){//处理苹果推送消息
        NSDictionary* userInfo=[self pop];
        BOOL flag=NO;
        switch (buttonIndex) {
            case 0://忽略
                break;
            case 1://查看
            {
                flag=YES;
                [self pushGotoWhere:userInfo];
            }
                break;
            default:
                break;
        }
        if (userInfo) {
            [[selfMarketMessageDB instance] insertIfNotExistWithDic:userInfo isRead:flag andUserId:[UserModel um].userId];
        }
    }
}

@end
