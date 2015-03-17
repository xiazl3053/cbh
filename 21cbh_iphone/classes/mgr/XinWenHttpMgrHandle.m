//
//  HttpMgrHandle.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XinWenHttpMgrHandle.h"
#import "DownloadOperation.h"
#import "FileOperation.h"
#import "CommonOperation.h"
#import "AdBarModel.h"
#import "TopPicModel.h"
#import "NewListModel.h"
#import "UserModel.h"
#import "NewsDetailModel.h"
#import "PicsListModel.h"
#import "PicDetailModel.h"
#import "NewsFlashModel.h"
#import "NoticeOperation.h"
#import "liveBroadcastModel.h"
#import "AdDetaiModel.h"


@interface XinWenHttpMgrHandle (){
    
}

@property(strong,nonatomic) NSOperationQueue *queue;// 下载队列

@end

@implementation XinWenHttpMgrHandle

- (id)init
{
    self = [super init];
    if (self) {
        self.queue=[[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)dealloc{
    self.queue=nil;
}


#pragma mark 普通登陆接口处理
-(void)loginHandle:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {
        
        @try {
            NSString *response=[request responseString];
            NSLog(@"普通登陆返回:%@",response);
            NSDictionary *dic=[response JSONValue];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            if (error==0) {//没错误
                NSDictionary *data=[dic objectForKey:@"data"];
                NSString *token=[data objectForKey:@"_tk"];
                NSDictionary *userInfo=[data objectForKey:@"userInfo"];
                //token本地化
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:token forKey:@"token"];
                [defaults synchronize];
                
                //账号数据本地化
                UserModel *um=[UserModel um];
                [um setDict:userInfo];
                // 将账号写入沙盒
                [CommonOperation writeUmToLoacal:um];
                //注册苹果推送服务
                [[CommonOperation getId] registerApplePush];
            }
            
            
            if (self.lvc) {
                [self.lvc getLoginHandleWithMsg:msg error:error];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"普通登陆接口处理异常");
            if (self.lvc) {
                [self.lvc getLoginHandleWithMsg:@"服务器忙" error:2];
            }
        }
        @finally {
            
        }
        
    }else{
        if (self.lvc) {
            [self.lvc getLoginHandleWithMsg:@"网络似乎不给力" error:2];
        }
    }
}

#pragma mark  第三方授权登陆接口处理
-(void)loginSSOHandle:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {
        @try {
            NSString *response=[request responseString];
            NSLog(@"第三方授权返回:%@",response);
            NSDictionary *dic=[response JSONValue];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSInteger isFirst=0;
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            if (error==0) {//没错误
                NSDictionary *data=[dic objectForKey:@"data"];
                NSString *token=[data objectForKey:@"_tk"];
                isFirst=[[data objectForKey:@"isFirst"] intValue];
                NSDictionary *userInfo=[data objectForKey:@"userInfo"];
                //token本地化
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:token forKey:@"token"];
                [defaults synchronize];
                
                //账号数据本地化
                UserModel *um=[UserModel um];
                [um setDict:userInfo];
                // 将账号写入沙盒
                [CommonOperation writeUmToLoacal:um];
                //注册苹果推送服务
                [[CommonOperation getId] registerApplePush];
            }
            
            if (self.lvc) {
                [self.lvc getLoginSSOHandleWithMsg:msg error:error isFirst:isFirst];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"第三方授权登陆接口处理");
            if (self.lvc) {
                [self.lvc getLoginSSOHandleWithMsg:@"服务器忙" error:2 isFirst:0];
            }
        }
        @finally {
           
        }
        
        
        
    }else{
      
        if (self.lvc) {
            [self.lvc getLoginSSOHandleWithMsg:@"网络似乎不给力" error:2 isFirst:0];
        }
    }
}

#pragma mark 注册登陆接口处理
-(void)registerHandle:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {
        @try {
            NSString *response=[request responseString];
            NSLog(@"注册返回:%@",response);
            NSDictionary *dic=[response JSONValue];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"注册登陆接口处理msg:%@",msg);
            
            if (error==0) {//没错误
                NSDictionary *data=[dic objectForKey:@"data"];
                NSString *token=[data objectForKey:@"_tk"];
                NSDictionary *userInfo=[data objectForKey:@"userInfo"];
                //token本地化
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:token forKey:@"token"];
                [defaults synchronize];
                
                //账号数据本地化
                UserModel *um=[UserModel um];
                [um setDict:userInfo];
                // 将账号写入沙盒
                [CommonOperation writeUmToLoacal:um];
                //注册苹果推送服务
                [[CommonOperation getId] registerApplePush];
            }
            
            if (self.rvc) {
                [self.rvc getRegisterHandleWithMsg:msg error:error];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"注册登陆接口处理");
            if (self.rvc) {
                [self.rvc getRegisterHandleWithMsg:@"服务器忙" error:2];
            }
        }
        @finally {
            
        }
        
        
    }else{
        if (self.rvc) {
            [self.rvc getRegisterHandleWithMsg:@"网络不给力" error:2];
        }
        
    }
}

#pragma mark 注销接口处理
-(void)loginOut:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {
        @try {
            NSString *response=[request responseString];
            NSLog(@"注销返回:%@",response);
            NSDictionary *dic=[response JSONValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"注销接口处理msg:%@",msg);
        }
        @catch (NSException *exception) {
            NSLog(@"注销返回异常");
        }
        @finally {
            
        }
        
    }else{
        NSLog(@"注销返回失败");
    }
}


#pragma mark IOS提交设备信息接口处理
-(void)postDeviceInfo:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {
        @try {
            NSString *response=[request responseString];
            NSLog(@"IOS提交设备信息接口返回:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"IOS提交设备信息msg:%@",msg);
        }
        @catch (NSException *exception) {
            NSLog(@"IOS提交设备信息接口异常处理");
        }
        @finally {
            
        }
        
    }else{
        
         NSLog(@"IOS提交设备信息接口返回失败");
    }
}

#pragma mark 是否推送状态接口处理
-(void)postIsPush:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {
        @try {
            NSString *response=[request responseString];
            NSLog(@"是否推送状态接口接口返回:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"是否推送状态接口msg:%@",msg);
        }
        @catch (NSException *exception) {
            NSLog(@"是否推送状态接口异常处理");
        }
        @finally {
            
        }
        
    }else{
        
        NSLog(@"是否推送状态接口返回失败");
    }
}

#pragma mark  新闻快讯接口处理
-(void)newsFlashHandle:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {//成功
        @try {
            NSString *response=[request responseString];
           // NSLog(@"新闻快讯的接口返回:%@",response);
            
            //[CommonOperation goTOLogin];
            
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            NSDictionary *data=[dic objectForKey:@"data"];
            NSArray *list=[data objectForKey:@"list"];
            NSMutableArray *nfms=[NSMutableArray array];
            for (int i=0; i<list.count; i++) {
                NSDictionary *dic1=[list objectAtIndex:i];
                NewsFlashModel *nfm=[[NewsFlashModel alloc] initWithDict:dic1];
                [nfms addObject:nfm];
            }
            
            [self.main getNewsFlashHandle:nfms];
        }
        @catch (NSException *exception) {
            NSLog(@"新闻快讯接口处理");
            [self.main getNewsFlashHandle:nil];
        }
        @finally {
            
        }
        
        
       
        
    }else{//失败
        [self.main getNewsFlashHandle:nil];
    }
}


#pragma mark 启动页接口处理
-(void)launchHandle:(ASIFormDataRequest *)request success:(BOOL)b{
   // NSLog(@"data:%@",data);
    if (b) {//成功
        @try {
            NSString *response=[request responseString];
            NSLog(@"启动页接口返回:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            NSDictionary *data=[dic objectForKey:@"data"];
            
            if(![data isKindOfClass:[NSDictionary class]]){
                return;
            }
            
            NSString *picUrl=[data objectForKey:@"picUrl"];
            NSLog(@"picUrl:%@",picUrl);
            
            if (!picUrl) {//拿不到广告图片的下载地址
                return;
            }
            
            //广告图片地址储存本地
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:picUrl forKey:@"picUrl"];
            [defaults synchronize];// 将数据同步到Preferences文件夹中
            
            //判断本地有无该广告图片
            //UIImage *image=[self.fo getLocalPicWithURL:picUrl FileDirName:kAdFileDir];
            BOOL b=[[FileOperation getId] isExistPicWithURL:picUrl FileDirName:kAdFileDir];
            if (b) {
                NSLog(@"本地已存在该广告图片");
                return;
            }
            
            NSLog(@"本地没该广告图片,开始下载");
            //下载图片
            DownloadOperation *operation = [[DownloadOperation alloc] init];
            operation.url=picUrl;
            operation.downloadCompletionBlock = ^(UIImage *image) {
                NSLog(@"image:%@",image);
                //删除旧图片
                [[FileOperation getId] deleteFolderWithPath:kAdFileDir];
                //保存新图片
                [[FileOperation getId] savePicToLocalWithUIImage:image picUrl:picUrl FileDirName:kAdFileDir isPng:NO];
            };
            [self.queue addOperation:operation];
        }
        @catch (NSException *exception) {
            NSLog(@"启动页接口处理异常");
        }
        @finally {
            
        }
       
        
    }else{//失败
       
        
    }
}

#pragma mark  广告栏接口处理
-(void)adBarHandle:(ASIFormDataRequest *)request success:(BOOL)b{
   // NSLog(@"data:%@",data);
    if (b) {//成功
        @try {
            NSString *response=[request responseString];
            NSLog(@"广告栏接口返回:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];

            NSDictionary *data=[dic objectForKey:@"data"];
            
            if(![data isKindOfClass:[NSDictionary class]]){
                return;
            }
            
            AdBarModel *adBarModel=[[AdBarModel alloc] initWithDict:data];
            
            if (self.nlv) {//新闻列表页
                [self.nlv checkAdBar:adBarModel];
            }
            
            if (self.nlv2) {//推荐新闻页
                [self.nlv2 checkAdBar:adBarModel];
            }
            
            if (self.plc) {//图集列表页
                [self.plc checkAdBar:adBarModel];
            }
            
            if (self.ndv) {//新闻详情页页
                [self.ndv checkAdBar:adBarModel];
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"广告栏异常");
            if (self.nlv) {//新闻列表页
                [self.nlv getAdBarHandle:nil];
            }
            
            if (self.nlv2) {//推荐新闻页
                [self.nlv2 checkAdBar:nil];
            }
            
            if (self.plc) {//图集列表页
                [self.plc getAdBarHandle:nil];
            }
            
            if (self.ndv) {//新闻详情页页
                [self.ndv getAdBarHandle:nil];
            }
        }
        @finally {
           
        }
        
    }else{//失败
        // 请求响应失败，返回错误信息
        NSLog ( @"广告栏接口返回失败!");
        
        if (self.nlv) {//新闻列表页
            [self.nlv getAdBarHandle:nil];
        }
        
        if (self.nlv2) {//推荐新闻页
            [self.nlv2 checkAdBar:nil];
        }
        
        if (self.plc) {//图集列表页
            [self.plc getAdBarHandle:nil];
        }
        
        if (self.ndv) {//新闻详情页页
            [self.ndv getAdBarHandle:nil];
        }
    }
}

#pragma mark 头图接口处理
-(void)headHandle:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {//成功
        @try {
            NSString *response=[request responseString];
            
            NSLog(@"头图接口返回:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            
            if (!dic) {
                if (self.nlv) {
                    [self.nlv getHeadHandle:nil];
                }
                if (self.nlv2) {
                    [self.nlv2 getHeadHandle:nil];
                }
                return;
            }
            
            NSDictionary *data=[dic objectForKey:@"data"];
            if (![data isKindOfClass:[NSDictionary class]]) {
                if (self.nlv) {
                    [self.nlv getHeadHandle:nil];
                }
                if (self.nlv2) {
                    [self.nlv2 getHeadHandle:nil];
                }
                return;
            }
            NSArray *array=[data objectForKey:@"headList"];
            NSMutableArray *tpms=nil;
            if (array&&array.count>0) {
                tpms=[NSMutableArray array];
                for (int i=0; i<array.count; i++) {
                    NSDictionary *dic1=[array objectAtIndex:i];
                    TopPicModel *tpm=[[TopPicModel alloc] initWithDict:dic1];
                    [tpms addObject:tpm];
                    tpm=nil;
                }
            }
            
            if (self.nlv) {
                [self.nlv getHeadHandle:tpms];
            }
            
            if (self.nlv2) {
                [self.nlv2 getHeadHandle:tpms];
            }

        }
        @catch (NSException *exception) {
            NSLog(@"头图异常");
            if (self.nlv) {
                [self.nlv getHeadHandle:nil];
            }
            if (self.nlv2) {
                [self.nlv2 getHeadHandle:nil];
            }
        }
        @finally {
          
        }
        
    }else{//失败
        NSLog(@"头图信息获取失败!");
        if (self.nlv) {
            [self.nlv getHeadHandle:nil];
        }
        if (self.nlv2) {
            [self.nlv2 getHeadHandle:nil];
        }
    }
}


#pragma mark 新闻列表接口处理
-(void)newsListHandle:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp{
    if (b) {//成功
        @try {
            // NSLog(@"%i新闻列表信息获取成功!",isUp);
            NSString *response=[request responseString];
            NSLog(@"新闻列表的数据:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            NSDictionary *data= [dic objectForKey:@"data"];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            if (error==0) {//没错误
                NSMutableArray *array=[data objectForKey:@"newsList"];
                
                NSMutableArray *nlms=[NSMutableArray array];
                if (array&&array.count>0) {
                    
                    for (int i=0; i<array.count; i++) {
                        NSDictionary *obj= [array objectAtIndex:i];
                        NewListModel *nlm=[[NewListModel alloc] initWithDict:obj];
                        obj=nil;
                        [nlms addObject:nlm];
                        nlm=nil;
                    }
                }
                if (self.nlv) {
                    [self.nlv getNewsListHandle:nlms isUp:isUp];
                }
                
            }else if (error==2){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIView *view=[[NoticeOperation getId] showAlertWithMsg:msg imageName:@"alert_tanhao" toView:self.nlv.view autoDismiss:YES viewUserInteractionEnabled:NO];
                    CGRect frame=view.frame;
                    frame.origin.y-=50;
                    view.frame=frame;
                });
                if (self.nlv) {
                    [self.nlv getNewsListHandle:nil isUp:isUp];
                }
                
            }else{
                if (self.nlv) {
                    [self.nlv getNewsListHandle:nil isUp:isUp];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"新闻列表异常");
            if (self.nlv) {
                [self.nlv getNewsListHandle:nil isUp:isUp];
            }
        }
        @finally {
           
        }

        
        
    }else{//失败
         NSLog(@"%i新闻列表信息获取失败!",isUp);
        if (self.nlv) {
            [self.nlv getNewsListHandle:nil isUp:isUp];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIView *view=[[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:self.nlv.view autoDismiss:YES viewUserInteractionEnabled:NO];
                CGRect frame=view.frame;
                frame.origin.y-=50;
                view.frame=frame;
            });
        }
    }
}

#pragma mark 新闻列表接口处理2
-(void)newsListHandle2:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp{
    if (b) {//成功
        @try {
            // NSLog(@"%i新闻列表信息获取成功!",isUp);
            NSString *response=[request responseString];
            NSLog(@"新闻列表2的数据:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            NSDictionary *data= [dic objectForKey:@"data"];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            if (error==0) {//没错误
                NSMutableArray *array=[data objectForKey:@"newsList"];
                
                NSMutableArray *nlms=[NSMutableArray array];
                if (array&&array.count>0) {
                    
                    for (int i=0; i<array.count; i++) {
                        NSDictionary *obj= [array objectAtIndex:i];
                        NewListModel *nlm=[[NewListModel alloc] initWithDict:obj];
                        obj=nil;
                        [nlms addObject:nlm];
                        nlm=nil;
                    }
                }
                if (self.nlv2) {
                    [self.nlv2 getNewsListHandle:nlms data:data isUp:isUp];
                }
                
            }else if (error==2){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIView *view=[[NoticeOperation getId] showAlertWithMsg:msg imageName:@"alert_tanhao" toView:self.nlv2.view autoDismiss:YES viewUserInteractionEnabled:NO];
                    CGRect frame=view.frame;
                    frame.origin.y-=50;
                    view.frame=frame;
                });
                if (self.nlv2) {
                    [self.nlv2 getNewsListHandle:nil data:nil isUp:isUp];
                }
                
            }else{
                if (self.nlv2) {
                   [self.nlv2 getNewsListHandle:nil data:nil isUp:isUp];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"新闻列表接口2异常");
            if (self.nlv2) {
                [self.nlv2 getNewsListHandle:nil data:nil isUp:isUp];
            }
        }
        @finally {
            
        }
        
        
        
    }else{//失败
        NSLog(@"%i新闻列表信息获取失败!",isUp);
        if (self.nlv2) {
            [self.nlv2 getNewsListHandle:nil data:nil isUp:isUp];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIView *view=[[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:self.nlv2.view autoDismiss:YES viewUserInteractionEnabled:NO];
                CGRect frame=view.frame;
                frame.origin.y-=50;
                view.frame=frame;
            });
        }
    }
}

#pragma mark 新闻详情接口处理
-(void)newsDetailHandle:(ASIFormDataRequest *)request success:(BOOL)b isLocalExist:(BOOL)isLocalExist{
    if (b) {
        @try {
            //NSLog(@"新闻详情获取成功!");
            NSString *response=[request responseString];
            NSLog(@"文章详情接口返回数据:%@",response);
            NSDictionary *dic=[response JSONValue];
            // 解析返回的数据
            NSDictionary *data= [dic objectForKey:@"data"];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"msg:%@",msg);
            if (error==0) {//没错误
                NewsDetailModel *ndm=[[NewsDetailModel alloc] initWithDict:data];
                
                if (self.ndv) {
                    [self.ndv getNewsDetailHandle:ndm];
                }
                
            }else if (error==2){
                if (!isLocalExist) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.ndv) {
                            [[NoticeOperation getId] showAlertWithMsg:msg imageName:@"alert_tanhao" toView:self.ndv.view autoDismiss:YES viewUserInteractionEnabled:NO];
                        }
                    });
                }
                
                if (self.ndv) {
                    [self.ndv getNewsDetailHandle:nil];
                }
                
            }else{
                if (self.ndv) {
                    [self.ndv getNewsDetailHandle:nil];
                }
            }
            //释放没必要的内存
            response=nil;
            dic=nil;
            data=nil;
        }
        @catch (NSException *exception) {
            NSLog(@"新闻详情异常");
            if (self.ndv) {
                [self.ndv getNewsDetailHandle:nil];
            }
            if (!isLocalExist){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.ndv) {
                        [[NoticeOperation getId] showAlertWithMsg:@"服务器忙,请稍后再试" imageName:@"alert_tanhao" toView:self.ndv.view autoDismiss:YES viewUserInteractionEnabled:NO];
                    }
                    
                });
            }
        }
        @finally {
            
        }
        
        
    }else{
        if (!isLocalExist){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.ndv) {
                    [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:self.ndv.view autoDismiss:YES viewUserInteractionEnabled:NO];
                }
                
            });
        }

        NSLog(@"新闻详情获取失败!");
        if (self.ndv) {
            [self.ndv getNewsDetailHandle:nil];
        }
        
    }
}

#pragma mark 图集列表接口处理
-(void)picsListHandle:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp{
    if (b) {//成功
        @try {
            NSLog(@"%i图集列表信息获取成功!",isUp);
            NSString *response=[request responseString];
            NSLog(@"图集列表的返回数据:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            NSDictionary *data=[dic objectForKey:@"data"];
            NSArray *picsList=[data objectForKey:@"picsList"];
            NSMutableArray *plms=[NSMutableArray array];
            
            if (picsList&&picsList.count>0) {
                for (int i=0; i<picsList.count; i++) {
                    NSDictionary *dic1=[picsList objectAtIndex:i];
                    PicsListModel *plm=[[PicsListModel alloc] initWithDict:dic1];
                    [plms addObject:plm];
                }
            }
            
            
            if (self.plc) {
                [self.plc getPicsListHandle:plms isUp:isUp];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"图片列表异常");
            if (self.plc) {
                [self.plc getPicsListHandle:nil isUp:isUp];
            }
        }
        @finally {
          
        }
        
        
    }else{//失败
        NSLog(@"%i新闻列表信息获取失败!",isUp);
        if (self.plc) {
            [self.plc getPicsListHandle:nil isUp:isUp];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:self.plc.main.view autoDismiss:YES viewUserInteractionEnabled:NO];
            });
        }
    }
}

#pragma mark 图集详情接口处理
-(void)picsDetailHandle:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {
        @try {
            NSLog(@"图集详情获取成功!");
            NSString *response=[request responseString];
            NSLog(@"图集详情的返回数据:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            NSDictionary *data=[dic objectForKey:@"data"];
            
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"图集详情msg:%@",msg);
            if (error==0) {//没错误
                NSMutableDictionary *dic1=[NSMutableDictionary dictionary];
                NSString *title=[data objectForKey:@"title"];
                if (!title) {
                    title=@"";
                }
                NSString *shareUrl=[data objectForKey:@"shareUrl"];
                if (!shareUrl) {
                    shareUrl=@"";
                }
                NSString *sharePic=[data objectForKey:@"sharePic"];
                if (!sharePic) {
                    sharePic=@"";
                }
                NSString *followNum=[data objectForKey:@"followNum"];
                if (!followNum) {
                    followNum=@"";
                }
                NSString *addtime=[data objectForKey:@"addtime"];
                if (!addtime) {
                    addtime=@"";
                }
                NSString *order=[data objectForKey:@"order"];
                if (!order) {
                    order=@"";
                }
                
                [dic1 setObject:title forKey:@"title"];
                [dic1 setObject:shareUrl forKey:@"shareUrl"];
                [dic1 setObject:sharePic forKey:@"sharePic"];
                [dic1 setObject:followNum forKey:@"followNum"];
                [dic1 setObject:addtime forKey:@"addtime"];
                [dic1 setObject:order forKey:@"order"];
                
                
                NSArray *picsList=[data objectForKey:@"picsList"];//图集详情数组
                NSArray *rcPicsList=[data objectForKey:@"rcPicsList"];//相关图集列表数组
                
                NSMutableArray *pdms=[NSMutableArray array];
                NSMutableArray *plms=[NSMutableArray array];
                
                //图集详情数组解析
                if (picsList&&picsList.count>0) {
                    for (int i=0; i<picsList.count; i++) {
                        NSDictionary *dic1=[picsList objectAtIndex:i];
                        PicDetailModel *pdm=[[PicDetailModel alloc] initWithDict:dic1];
                        [pdms addObject:pdm];
                    }
                    
                    //关联图集列表数组
                    if (rcPicsList&&rcPicsList.count>0) {
                        for (int i=0; i<rcPicsList.count; i++) {
                            NSDictionary *dic1=[rcPicsList objectAtIndex:i];
                            PicsListModel *plm=[[PicsListModel alloc] initWithDict:dic1];
                            [plms addObject:plm];
                        }
                    }
                }
                
                
                if (self.mpb) {
                    [self.mpb getPicsDetailHandle:pdms plms:plms dic:dic1];
                }
                
            }else if (error==2){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.mpb) {
                         [[NoticeOperation getId] showAlertWithMsg:msg imageName:@"alert_tanhao" toView:self.mpb.view autoDismiss:YES viewUserInteractionEnabled:NO];
                    }
                });
                
                if (self.mpb) {
                    [self.mpb getPicsDetailHandle:nil plms:nil dic:nil];
                }
                
            }else{
                
                if (self.mpb) {
                    [self.mpb getPicsDetailHandle:nil plms:nil dic:nil];
                }
                
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"图片详情异常");
            if (self.mpb) {
                [self.mpb getPicsDetailHandle:nil plms:nil dic:nil];
                [[NoticeOperation getId] showAlertWithMsg:@"服务器忙,请稍后再试" imageName:@"alert_tanhao" toView:self.mpb.view autoDismiss:YES viewUserInteractionEnabled:NO];
            }
            
        }
        
        @finally {
           
        }
        
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
        });
        NSLog(@"图集详情获取失败!");
        if (self.mpb) {
            [self.mpb getPicsDetailHandle:nil plms:nil dic:nil];
        }
        
    }
}

#pragma mark 推送新闻列表接口处理
-(void)pushNewListHandle:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp{ 
    if (b) {//成功
        
        @try {
            NSLog(@"推送列表获取成功!");
            NSString *response=[request responseString];
            NSLog(@"推送列表的返回数据:%@",response);
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"推送列表msg:%@",msg);
            NSDictionary *data=[dic objectForKey:@"data"];
            
            NSMutableArray *nlmsGroups=[NSMutableArray array];
            NSMutableArray *todayNlms=[NSMutableArray array];
            NSMutableArray *yesterdayNlms=[NSMutableArray array];
            NSMutableArray *previousNlms=[NSMutableArray array];
            
            [nlmsGroups addObject:todayNlms];
            [nlmsGroups addObject:yesterdayNlms];
            [nlmsGroups addObject:previousNlms];
            
            NSArray *todayList=[data objectForKey:@"todayList"];
            NSArray *yesterdayList=[data objectForKey:@"yesterdayList"];
            NSArray *previousList=[data objectForKey:@"previousList"];
            
            if (todayList&&todayList.count>0) {
                for (int i=0; i<todayList.count; i++) {
                    NSDictionary *obj=[todayList objectAtIndex:i];
                    NewListModel *nlm=[[NewListModel alloc] initWithDict:obj];
                    [todayNlms addObject:nlm];
                }
            }
            
            if (yesterdayList&&yesterdayList.count>0) {
                for (int i=0; i<yesterdayList.count; i++) {
                    NSDictionary *obj=[yesterdayList objectAtIndex:i];
                    NewListModel *nlm=[[NewListModel alloc] initWithDict:obj];
                    [yesterdayNlms addObject:nlm];
                }
            }
            
            if (previousList&&previousList.count>0) {
                for (int i=0; i<previousList.count; i++) {
                    NSDictionary *obj=[previousList objectAtIndex:i];
                    NewListModel *nlm=[[NewListModel alloc] initWithDict:obj];
                    [previousNlms addObject:nlm];
                }
            }
            
            
            
            
            if (self.cplvc) {
                [self.cplvc getPushListHandle:nlmsGroups isUp:isUp];
            }
        }
        @catch (NSException *exception) {
            if (self.cplvc) {
                [self.cplvc getPushListHandle:nil isUp:isUp];
            }
        }
        @finally {
            
        }
        
        
        
    }else{//失败
         NSLog(@"咨询推送列表获取失败!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
        });
        if (self.cplvc) {
            [self.cplvc getPushListHandle:nil isUp:isUp];
        }
    }
}



#pragma mark 直播列表接口处理
-(void)liveBroadcastHandle:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp{
    if (b) {//成功
    
        @try {
            NSLog(@"直播列表获取成功!");
            NSString *response=[request responseString];
            NSLog(@"直播列表的返回数据:%@",response);

            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"直播列表msg:%@",msg);
            
            if (error==0) {//没错误
                NSDictionary *data=[dic objectForKey:@"data"];
                NSArray *liveList=[data objectForKey:@"liveList"];
                NSMutableArray *lbms=[NSMutableArray array];
                if (liveList&&liveList.count>0) {
                    for (int i=0; i<liveList.count; i++) {
                        NSDictionary *obj=[liveList objectAtIndex:i];
                        liveBroadcastModel *lbm=[[liveBroadcastModel alloc] initWithDict:obj];
                        [lbms addObject:lbm];
                    }
                    if (self.lbvc) {
                        [self.lbvc LiveBroadcastHandle:lbms isUp:isUp];
                    }
                }else{
                    if (self.lbvc) {
                        [self.lbvc LiveBroadcastHandle:nil isUp:isUp];
                    }
                }
                return;
            }else if (error==2){//错误提示给用户
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.lbvc){
                       [[NoticeOperation getId] showAlertWithMsg:msg imageName:@"alert_tanhao" toView:self.lbvc.view autoDismiss:YES viewUserInteractionEnabled:NO];
                    }
                    
                });
            }
            
            if (self.lbvc) {
                [self.lbvc LiveBroadcastHandle:nil isUp:isUp];
            }
            
        }
        @catch (NSException *exception) {
            if (self.lbvc) {
                [self.lbvc LiveBroadcastHandle:nil isUp:isUp];
            }
        }
        @finally {
            
        }
        
    
    }else{//失败
       
        NSLog(@"直播列表获取失败!");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.lbvc) {
                [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:self.lbvc.view autoDismiss:YES viewUserInteractionEnabled:NO];
            }            
        });
        if (self.lbvc) {
            [self.lbvc LiveBroadcastHandle:nil isUp:isUp];
        }
        
        
        
    }
}


#pragma mark 广告详情接口处理
-(void)adDetailHandle:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {//成功
        
        @try {
            NSLog(@"广告详情接口获取成功!");
            NSString *response=[request responseString];
            NSLog(@"广告详情接口的返回数据:%@",response);
            
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"广告详情接口msg:%@",msg);
            
            if (error==0) {//没错误
                NSDictionary *data=[dic objectForKey:@"data"];
                AdDetaiModel *adtm=[[AdDetaiModel alloc] initWithDict:data];
                [self.wvc getAdDetailHandle:adtm];
               
            }else if (error==2){//错误提示给用户
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.wvc){
                        [[NoticeOperation getId] showAlertWithMsg:msg imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
                    }
                    
                });
                [self.wvc getAdDetailHandle:nil];
            }
            
        }
        @catch (NSException *exception) {
            [self.wvc getAdDetailHandle:nil];
        }
        @finally {
            
        }
        
        
    }else{//失败
        
        NSLog(@"广告详情接口获取失败!");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.wvc) {
                [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
            }
        });
        [self.wvc getAdDetailHandle:nil];
    }
}


#pragma mark 验证token接口处理
-(void)checkTokenHandle:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {//成功
        
        @try {
            NSLog(@"验证token接口获取成功!");
            NSString *response=[request responseString];
            NSLog(@"验证token接口的返回数据:%@",response);
            
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"验证token接口msg:%@",msg);
            
            if (error==0) {//没错误
                NSDictionary *data=[dic objectForKey:@"data"];
                int isValid=[[data objectForKey:@"isValid"] intValue];
                if (isValid==1) {//token有效
                    self.cl.chatLoginBlock(YES);
                }else{//token无效
                    self.cl.chatLoginBlock(NO);
                }
                
            }else{
                self.cl.chatLoginBlock(NO);
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"验证token接口获取数据异常!");
            self.cl.chatLoginBlock(NO);
        }
        @finally {
            
        }
        
        
    }else{//失败
        NSLog(@"验证token接口获取数据失败!");
        self.cl.chatLoginBlock(NO);
    }
}


#pragma mark 绑定手机号码接口处理
-(void)bindPhoneHandle:(ASIFormDataRequest *)request success:(BOOL)b{
    if (b) {//成功
        
        @try {
            NSLog(@"绑定手机号码接口获取成功!");
            NSString *response=[request responseString];
            NSLog(@"绑定手机号码接口的返回数据:%@",response);
            
            // 解析返回的数据
            NSDictionary *dic= [response JSONValue];
            int error=[[dic objectForKey:@"errno"] integerValue];
            NSString *msg=[dic objectForKey:@"msg"];
            NSLog(@"绑定手机号码接口msg:%@",msg);
            
            if (self.bmccvc) {
                [self.bmccvc bindPhoneHandleWithMsg:msg error:error];
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"绑定手机号码接口获取数据异常!");
            if (self.bmccvc) {
                [self.bmccvc bindPhoneHandleWithMsg:@"服务器忙" error:2];
            }
        }
        @finally {
            
        }
        
        
    }else{//失败
        NSLog(@"绑定手机号码接口获取数据失败!");
        if (self.bmccvc) {
            [self.bmccvc bindPhoneHandleWithMsg:@"网络似乎不给力" error:2];
        }
    }
}













@end
