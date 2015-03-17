//
//  HttpMgr.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XinWenHttpMgr.h"
#import "CommonOperation.h"

@interface XinWenHttpMgr(){
    
}


@end

@implementation XinWenHttpMgr

- (id)init
{
    self = [super init];
    if (self) {
        self.hh=[[XinWenHttpMgrHandle alloc] init];
    }
    return self;
}


-(void)dealloc{
    self.hh=nil;
}

#pragma mark 初始化ASIFormDataRequest
-(ASIFormDataRequest *)getRequest:(NSString *)urlString{
    //先注释起来,网络判断不准确
    if(![[CommonOperation getId] getNetStatus]){//检查网络状态
        return nil;
    }
    
    NSURL *url =[NSURL URLWithString:urlString];
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:url];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];//默认编码为utf-8
    [request setRequestMethod:@"POST"];
    
    //超时时间
    request.timeOutSeconds = 8;
    
    return request;
}


#pragma mark 初始化参数
-(NSMutableDictionary *)getDic{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    
    //设置参数
    NSString *version=[[CommonOperation getId] getVersion];
    NSString *screenType=[[CommonOperation getId] getScreenType];
    
    [dic setValue:[NSString stringWithFormat:@"%i",kClientType] forKey:@"clientType"];//客户端类型
    [dic setValue:version forKey:@"version"];//版本号
    [dic setValue:screenType forKey:@"screenType"];//图片尺寸类型
    
    
    return dic;
}


#pragma mark - ------------------------------------以下为接口请求-----------------------------------

#pragma mark 普通登陆接口
-(void)loginWithUserName:(NSString *)userName passWord:(NSString *)passWord{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kLogin)];
        // NSLog(@"启动页的接口:%@",kURL(kLaunch));
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh loginHandle:nil success:NO];
            });
            return;
        }
        
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        [dic setValue:userName forKey:@"userName"];
        [dic setValue:passWord forKey:@"passWord"];
        //设备号
        NSString *deviceId=[[CommonOperation getId] getUUID];
        [dic setValue:deviceId forKey:@"deviceId"];
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh loginHandle:blockRequest success:YES];
            });
            
        }];
        
        //请求失败
        [request setFailedBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh loginHandle:blockRequest success:NO];
            });
            
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}

#pragma mark 第三方授权登陆接口
-(void)loginSSOwithPlatformId:(NSString *)platformId platformUserId:(NSString *)platformUserId platformNickName:(NSString *)platformNickName platformPicUrl:(NSString *)platformPicUrl{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kLoginSSO)];
        // NSLog(@"启动页的接口:%@",kURL(kLaunch));
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh loginSSOHandle:nil success:NO];
            });
            return;
        }
        
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        [dic setValue:platformId forKey:@"platformId"];
        [dic setValue:platformUserId forKey:@"platformUserId"];//platformUserId以后要加密
        [dic setValue:platformNickName forKey:@"platformNickName"];
        [dic setValue:platformPicUrl forKey:@"platformPicUrl"];
        //设备号
        NSString *deviceId=[[CommonOperation getId] getUUID];
        [dic setValue:deviceId forKey:@"deviceId"];
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh loginSSOHandle:blockRequest success:YES];
            });
            
        }];
        
        //请求失败
        [request setFailedBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh loginSSOHandle:blockRequest success:NO];
            });
            
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
    
}

#pragma mark 注册接口
-(void)registerWithUserName:(NSString *)userName nickName:(NSString *)nickName email:(NSString *)email passWord:(NSString *)passWord platformId:(NSString *)platformId platformUserId:(NSString *)platformUserId{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kRegister)];
        // NSLog(@"启动页的接口:%@",kURL(kLaunch));
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        [dic setValue:userName forKey:@"userName"];
        [dic setValue:nickName forKey:@"nickName"];
        [dic setValue:email forKey:@"email"];
        [dic setValue:passWord forKey:@"passWord"];//以后要加密
        [dic setValue:platformId forKey:@"platformId"];
        [dic setValue:platformUserId forKey:@"platformUserId"];//platformUserId以后要加密
        //设备号
        NSString *deviceId=[[CommonOperation getId] getUUID];
        [dic setValue:deviceId forKey:@"deviceId"];
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh registerHandle:blockRequest success:YES];
            });
            
        }];
        
        //请求失败
        [request setFailedBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh registerHandle:blockRequest success:NO];
            });
            
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}

#pragma mark 注销登陆接口
-(void)loginOut{
    ASIFormDataRequest *request=[self getRequest:kURL(kLoginOut)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    
    NSMutableDictionary *dic=[self getDic];
    
    //设备号
    NSString *deviceId=[[CommonOperation getId] getUUID];
    [dic setValue:deviceId forKey:@"deviceId"];
    //token
    NSString *token=[[CommonOperation getId] getToken];
    [dic setValue:token forKey:@"_tk"];
    //backUserId
    NSString *backUserId=[UserModel um].userId;
    [dic setValue:backUserId forKey:@"backUserId"];
    //type	操作类型 0=自选股清除设备号 1=其他 默认0
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *type=[defaults objectForKey:kSelfMarketOperationType];
    if (!type) {
        type=@"0";
    }
    [dic setValue:type forKey:@"type"];
    //恢复默认
    [defaults setObject:@"0" forKey:kSelfMarketOperationType];
    [defaults synchronize];
    
    //加密
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
    __block ASIFormDataRequest* blockRequest=request;
    
    //请求成功
    [request setCompletionBlock:^{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.hh loginOut:blockRequest success:YES];
        });
        
    }];
    
    //请求失败
    [request setFailedBlock:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.hh loginOut:blockRequest success:NO];
        });
        
    }];
    
    //发送请求
    [request startAsynchronous];
}



#pragma mark 是否推送状态接口
-(void)postIsPushWithIsPush:(NSString *)isPush{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kPostIsPush)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        
        //设备号
        NSString *deviceToken=[[CommonOperation getId] getAppleToken];
        NSLog(@"deviceToken:%@",deviceToken);
        [dic setValue:deviceToken forKey:@"deviceToken"];
        [dic setValue:isPush forKey:@"isPush"];
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh postIsPush:blockRequest success:YES];
            });
            
        }];
        
        //请求失败
        [request setFailedBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh postIsPush:blockRequest success:NO];
            });
            
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}

#pragma mark 新闻快讯接口
-(void)newsFlash{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kNewsFlash)];
        // NSLog(@"新闻快讯的接口:%@",kURL(kNewsFlash));
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsFlashHandle:blockRequest success:YES];
            });
            
        }];
        
        //请求失败
        [request setFailedBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsFlashHandle:blockRequest success:NO];
            });
            
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}

#pragma mark 启动页接口
-(void)launch{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kLaunch)];
        NSLog(@"启动页的接口:%@",kURL(kLaunch));
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh launchHandle:blockRequest success:YES];
            });
            
        }];
        
        //请求失败
        [request setFailedBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh launchHandle:blockRequest success:NO];
            });
            
        }];
        
        //发送请求
        [request startAsynchronous];
    });

}

#pragma mark 广告栏接口
-(void)adBarWithProgramId:(NSString *)programId isProgram:(NSString *)isProgram{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        ASIFormDataRequest *request=[self getRequest:kURL(kAdBar)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh adBarHandle:nil success:NO];
            });
            return;
        }
        
        
        NSMutableDictionary *dic=[self getDic];
        if (programId) {
            [dic setValue:programId forKey:@"programId"];
        }
        if (isProgram) {
            [dic setValue:isProgram forKey:@"isProgram"];
        }
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh adBarHandle:blockRequest success:YES];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh adBarHandle:blockRequest success:NO];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}


#pragma mark 头图接口
-(void)headWithProgramId:(NSString *)programId{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kHead)];
        //NSLog(@"头图请求地址:%@",kURL(kHead));
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh headHandle:nil success:NO];
            });
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        if (programId) {
            [dic setValue:programId forKey:@"programId"];//临时数据
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh headHandle:blockRequest success:YES];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh headHandle:blockRequest success:NO];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
}

#pragma mark 新闻列表接口
-(void)newsListWithProgramId:(NSString *)programId type:(NSString *)type id:(NSString *)newListId order:(NSString *)order addtime:(NSString *)addtime isUp:(BOOL)isUp{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kNewsList)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsListHandle:nil success:NO isUp:isUp];
            });
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        if (programId) {
            [dic setValue:programId forKey:@"programId"];
        }
        if (type) {
            [dic setValue:type forKey:@"type"];
        }
        if (newListId) {
            [dic setValue:newListId forKey:@"id"];
        }
        if (order) {
            [dic setValue:order forKey:@"order"];
        }
        if (addtime) {
            [dic setValue:addtime forKey:@"addtime"];
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsListHandle:blockRequest success:YES isUp:isUp];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsListHandle:blockRequest success:NO isUp:isUp];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
}

#pragma mark 新闻列表接口2
-(void)newsList2WithProgramId:(NSString *)programId type:(NSString *)type id:(NSString *)newListId order:(NSString *)order addtime:(NSString *)addtime page:(NSString *)page pageNum:(NSString *)pageNum isUp:(BOOL)isUp{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kNewsList2)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsListHandle2:nil success:NO isUp:isUp];
            });
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        if (programId) {
            [dic setValue:programId forKey:@"programId"];
        }
        if (type) {
            [dic setValue:type forKey:@"type"];
        }
        if (newListId) {
            [dic setValue:newListId forKey:@"id"];
        }
        if (order) {
            [dic setValue:order forKey:@"order"];
        }
        if (addtime) {
            [dic setValue:addtime forKey:@"addtime"];
        }
        if (page) {
            [dic setValue:page forKey:@"page"];
        }
        if (pageNum) {
            [dic setValue:pageNum forKey:@"pageNum"];
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsListHandle2:blockRequest success:YES isUp:isUp];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsListHandle2:blockRequest success:NO isUp:isUp];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
}


#pragma mark 新闻详情接口
-(void)newsDetailWithArticleId:(NSString *)articleId programId:(NSString *)programId isLocalExist:(BOOL)isLocalExist{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kNewsDetail)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsDetailHandle:nil success:NO isLocalExist:isLocalExist];
            });
            return;
        }
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        [dic setValue:articleId forKey:@"articleId"];
        [dic setValue:programId forKey:@"programId"];
        //设备号
        NSString *deviceId=[[CommonOperation getId] getUUID];
        [dic setValue:deviceId forKey:@"deviceId"];
        
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsDetailHandle:blockRequest success:YES isLocalExist:isLocalExist];
            });
            
        }];
        
        //请求失败
        [request setFailedBlock:^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh newsDetailHandle:blockRequest success:NO isLocalExist:isLocalExist];
            });
            
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}


#pragma mark 图集列表接口
-(void)picsListWithProgramId:(NSString *)programId id:(NSString *)picsId order:(NSString *)order addtime:(NSString *)addtime isUp:(BOOL)isUp{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kPicsList)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh picsListHandle:nil success:NO isUp:isUp];
            });
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        if (programId) {
            [dic setValue:programId forKey:@"programId"];//临时数据
        }
        if (picsId) {
            [dic setValue:picsId forKey:@"id"];
        }
        if (order) {
            [dic setValue:order forKey:@"order"];
        }
        if (addtime) {
            [dic setValue:addtime forKey:@"addtime"];
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh picsListHandle:blockRequest success:YES isUp:isUp];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh picsListHandle:blockRequest success:NO isUp:isUp];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
}

#pragma mark 图集详细接口
-(void)picsDetailWithPicsId:(NSString *)picsId programId:(NSString *)programId{
        
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kPicsDetail)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh picsDetailHandle:nil success:NO];
            });
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        if (picsId) {
            [dic setValue:picsId forKey:@"picsId"];
        }
        if (programId) {
            [dic setValue:programId forKey:@"programId"];
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh picsDetailHandle:blockRequest success:YES];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh picsDetailHandle:blockRequest success:NO];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
}

#pragma mark 推送新闻列表接口
-(void)pushNewListWithPushId:(NSString *)pushId order:(NSString *)order addtime:(NSString *)addtime isUp:(BOOL)isUp{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kPushNewList)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh pushNewListHandle:nil success:NO isUp:isUp];
            });
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        if (pushId) {
            [dic setValue:pushId forKey:@"id"];
        }
        if (order) {
            [dic setValue:order forKey:@"order"];
        }
        if (addtime) {
            [dic setValue:addtime forKey:@"addtime"];
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh pushNewListHandle:blockRequest success:YES isUp:isUp];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh pushNewListHandle:blockRequest success:NO isUp:isUp];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}


#pragma mark 直播列表接口
-(void)liveBroadcastWithAddtime:(NSString *)addtime isUp:(BOOL)isUp{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kLiveBroadcast)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh liveBroadcastHandle:nil success:NO isUp:isUp];
            });
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        if (addtime) {
            [dic setValue:addtime forKey:@"addtime"];
        }
        if (isUp) {//刷新
            [dic setValue:@"0" forKey:@"refresh"];
        }else{//查询历史记录
            [dic setValue:@"1" forKey:@"refresh"];
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh liveBroadcastHandle:blockRequest success:YES isUp:isUp];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh liveBroadcastHandle:nil success:NO isUp:isUp];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}

#pragma mark 广告详情接口
-(void)adDetailWithAdId:(NSString *)adId type:(NSString *)type{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kAdDetail)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            [self.hh adDetailHandle:nil success:NO];
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        if (adId) {
            [dic setValue:adId forKey:@"adId"];
        }
        if (type) {
            [dic setValue:type forKey:@"type"];
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh adDetailHandle:blockRequest success:YES];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh adDetailHandle:blockRequest success:NO];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}

#pragma mark 验证token接口
-(void)checkToken{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kCheckToken)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        NSString *userId=[UserModel um].userId;
        if (userId) {
            [dic setValue:userId forKey:@"userId"];
        }
        NSString *_tk=[[CommonOperation getId] getToken];
        if (_tk) {
            [dic setValue:_tk forKey:@"_tk"];
        }
    
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh checkTokenHandle:blockRequest success:YES];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hh checkTokenHandle:blockRequest success:NO];
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}

#pragma mark 获取手机验证码接口
-(void)phoneAuthCodeWithPhoneNum:(NSString *)phoneNum{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIFormDataRequest *request=[self getRequest:kURL(kPhoneAuthCode)];
        if (!request) {//没网络,下面不执行
            NSLog(@"暂无可用网络");
            return;
        }
        
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        NSString *userId=[UserModel um].userId;
        if (userId) {
            [dic setValue:userId forKey:@"userId"];
        }
        NSString *_tk=[[CommonOperation getId] getToken];
        if (_tk) {
            [dic setValue:_tk forKey:@"_tk"];
        }
        if (phoneNum) {
            [dic setValue:phoneNum forKey:@"phoneNum"];
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *response=[blockRequest responseString];
                NSLog(@"获取手机验证码接口的返回数据:%@",response);
                // 解析返回的数据
                NSDictionary *dic= [response JSONValue];
                int error=[[dic objectForKey:@"errno"] integerValue];
                NSString *msg=[dic objectForKey:@"msg"];
                NSLog(@"获取手机验证码接口msg:%@",msg);
                if (error==2) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NoticeOperation getId] showAlertWithMsg:msg imageName:@"error" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
                    });
                }else if(error==3){//重新登录
                    [CommonOperation goTOLogin];
                }
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"获取手机验证码接口请求网络异常!");
            });
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
}


#pragma mark 绑定手机号码
-(void)bindPhoneWithPhoneNum:(NSString *)phoneNum authCode:(NSString *)authCode{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        ASIFormDataRequest *request=[self getRequest:kURL(kBindPhonel)];
        if (!request) {//没网络,下面不执行
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
            });
            return;
        }
        NSMutableDictionary *dic=[self getDic];
        //设置参数
        NSString *userId=[UserModel um].userId;
        if (userId) {
            [dic setValue:userId forKey:@"userId"];
        }
        NSString *_tk=[[CommonOperation getId] getToken];
        if (_tk) {
            [dic setValue:_tk forKey:@"_tk"];
        }
        if (phoneNum) {
            [dic setValue:phoneNum forKey:@"phoneNum"];
        }
        if (authCode) {
            [dic setValue:authCode forKey:@"authCode"];
        }
        
        //加密
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        __block ASIFormDataRequest* blockRequest=request;
        
        //请求成功
        [request setCompletionBlock:^{
            [self.hh bindPhoneHandle:blockRequest success:YES];
        }];
        
        //请求失败
        [request setFailedBlock:^{
            [self.hh bindPhoneHandle:blockRequest success:NO];
        }];
        
        //发送请求
        [request startAsynchronous];
    });
}



@end
