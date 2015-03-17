//
//  PingLunHttpRequest.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PingLunHttpRequest.h"
#import "CommonOperation.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NCMConstant.h"





@interface PingLunHttpRequest ()<ASIProgressDelegate> {

}


@property(strong,nonatomic)CommonOperation *co;



@end

@implementation PingLunHttpRequest

-(void)dealloc{
    self.co=nil;
    self.PLResponse=nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.co=[[CommonOperation alloc] init];
        self.PLResponse=[[PingLunHttpResponse alloc]init];
    }
    return self;
}


//#pragma mark -初始化ASIFormDataRequest
//-(ASIFormDataRequest *)getRequest:(NSString *)urlString{
//    //先注释起来,网络判断不准确
//    if(![self.co getNetStatus]){//检查网络状态
//        return nil;
//    }
//    
//    NSURL *url =[NSURL URLWithString:urlString];
//    ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:url];
//    [request setDefaultResponseEncoding:NSUTF8StringEncoding];//默认编码为utf-8
//    [request setRequestMethod:@"POST"];
//    //设置参数
//    NSString *version=[self.co getVersion];
//    NSString *screenType=[self.co getScreenType];
//   // NSString *token=[self.co getToken];
//    [request setPostValue:[NSString stringWithFormat:@"%i",kClientType] forKey:@"clientType"];//客户端类型
//    [request setPostValue:screenType forKey:@"screenType"];
//    [request setPostValue:version forKey:@"version"];//版本号
////    if (token) {
////        [request setPostValue:token forKey:@"_tk"];//tokens
////    }
//    
//    
//    return request;
//}

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

#pragma mark - 获取软件最新版本
-(void)getAppleID:(VersionCheckViewController *)VC{
    self.PLResponse.vc=VC;
    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup"]];
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:url];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];//默认编码为utf-8
    [request setRequestMethod:@"POST"];
    [request setPostValue:KApple_ID forKey:@"id"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse versionInfoBackData:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse versionInfoBackData:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        [request startAsynchronous];
        
    });
    
    
    
}




#pragma mark -请求评论数据
-(void)queryCommentNCM:(NewsCommentViewController *)VC andProgramId:(NSInteger )nProgramID andFollowListID:(NSInteger )nFollow andCursor:(NSInteger )nCursor andCount:(NSInteger)nCount{
    self.PLResponse.nc=VC;
    ASIFormDataRequest *request=[self getRequest:kURL(KfollowList)];
    NSMutableDictionary *dic=[self getDic];
    [dic setValue:[NSNumber numberWithInteger:nProgramID] forKey:@"programId"];
    [dic setValue:[NSNumber numberWithInteger:nFollow] forKey:@"followListId"];
    [dic setValue:[NSNumber numberWithInteger:nCursor] forKey:@"cursor"];
    [dic setValue:[NSNumber numberWithInteger:nCount] forKey:@"Count"];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
//    [request setPostValue:[NSNumber numberWithInteger:nProgramID] forKey:@"programId"];
//    [request setPostValue:[NSNumber numberWithInteger:nFollow] forKey:@"followListId"];
//    [request setPostValue:[NSNumber numberWithInteger:nCursor] forKey:@"cursor"];
//    [request setPostValue:[NSNumber numberWithInteger:nCount] forKey:@"Count"];
    
    
    NSLog(@"---NCM---请求评论");
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.PLResponse commentListInfoBackWithData:nil isSuccess:NO];
        });
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse commentListInfoBackWithData:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse commentListInfoBackWithData:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
            [request startAsynchronous];
    
    });


}

#pragma mark -请求专题数据
-(void)querySepcialNSP:(NewsSpecialViewController *)VC andProgramID:(int)nProgramID andSepcial:(int)nSepcialID{
    self.PLResponse.np=VC;
    ASIFormDataRequest *request=[self getRequest:kURL(Ksepcial)];
    
    NSMutableDictionary *dic=[self getDic];
    [dic setValue:[NSNumber numberWithInteger:nSepcialID] forKey:@"specialId"];
    [dic setValue:[NSNumber numberWithInt:nProgramID] forKey:@"nProgramID"];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
//    [request setPostValue:[NSNumber numberWithInteger:nSepcialID] forKey:@"specialId"];
//    [request setPostValue:[NSNumber numberWithInt:nProgramID] forKey:@"nProgramID"];
    
    
    NSLog(@"---NSP---专题接口");
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setObject:KServerBackNetWorkDisconnectMsg forKey:KServerBackMsgKey];
            [self.PLResponse specialInfoBackWithData:nil isSuccess:NO error:dic];
        });

        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse specialInfoBackWithData:blockRequest isSuccess:YES error:nil];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                [dic setObject:KServerBackNetWorkFialMsg forKey:KServerBackMsgKey];
                [self.PLResponse specialInfoBackWithData:blockRequest isSuccess:NO error:dic];
            });
        }];
        //发送请求
        [request startAsynchronous];
        
    });
}

#pragma mark -发送点赞接口
-(void)sendCommenDingtNCM:(NewsCommentViewController *)VC andProgarmID:(int)nProgarm andArticleID:(int)nArticle andPicsID:(int)nPic andFollowID:(int)nFollow{
    self.PLResponse.nc=VC;
    
    ASIFormDataRequest *request=[self getRequest:kURL(Kding)];
    
    NSMutableDictionary *dic=[self getDic];
    [dic setValue:[NSNumber numberWithInteger:nProgarm] forKey:@"programId"];
    [dic setValue:[NSNumber numberWithInteger:nArticle] forKey:@"articleId"];
    [dic setValue:[NSNumber numberWithInteger:nFollow] forKey:@"followId"];
    [dic setValue:[NSNumber numberWithInt:nPic] forKey:@"picId"];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
    
//    [request setPostValue:[NSNumber numberWithInteger:nProgarm] forKey:@"programId"];
//    [request setPostValue:[NSNumber numberWithInteger:nArticle] forKey:@"articleId"];
//    [request setPostValue:[NSNumber numberWithInteger:nFollow] forKey:@"followId"];
//    [request setPostValue:[NSNumber numberWithInt:nPic] forKey:@"picId"];
    NSLog(@"---CNM---点赞");
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse commentDingInfoBackWithData:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse commentDingInfoBackWithData:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        [request startAsynchronous];
        
    });
}

//#pragma mark -评论回复接口
//-(void)sendCommenFollowNCM:(NewsCommentViewController *)VC andProgarm:(int)nProgarmID andArticleOrPicsID:(int)nArticle andFollowID:(int)nFollowID andContent:(NSString *)content{
//    self.PLResponse.Ncm=VC;
//    //获取当前时间
//    NSDate *date=[NSDate date];
//    NSTimeInterval time=[date timeIntervalSince1970];
//    NSString *token=[self.co getToken];
//    
//    ASIFormDataRequest *request=[self getRequest:kURL(Kfollow)];
//    [request setPostValue:[NSNumber numberWithInteger:nProgarmID] forKey:@"programId"];
//    [request setPostValue:[NSNumber numberWithInteger:nArticle] forKey:@"articleId"];
//    [request setPostValue:[NSNumber numberWithInteger:nFollowID] forKey:@"followId"];
//    [request setPostValue:[NSString stringWithString:content] forKey:@"content"];
//    [request setPostValue:[NSNumber numberWithInt:time] forKey:@"addtime"];
//    if (token) {
//            [request setPostValue:token forKey:@"_tk"];//tokens
//        }
//
//    NSLog(@"---NCM---请求评论");
//    if (!request) {//没网络,下面不执行
//        NSLog(@"暂无可用网络");
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [self.PLResponse commentFollowInfoBackWithData:nil isSuccess:NO];
//        });
//        return;
//    }
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        __block ASIFormDataRequest* blockRequest=request;
//        //请求成功
//        [request setCompletionBlock:^{
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [self.PLResponse commentFollowInfoBackWithData:blockRequest isSuccess:YES];
//            });
//        }];
//        //请求失败
//        [request setFailedBlock:^{
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [self.PLResponse commentFollowInfoBackWithData:blockRequest isSuccess:NO];
//            });
//        }];
//        //发送请求
//        [request startAsynchronous];
//        
//    });
//}

#pragma mark -图像上传
-(void)updateUserFigrueWith:(HeadSettingViewController *)VC andFigurePath:(NSString *)file{
    self.PLResponse.hs=VC;
    ASIFormDataRequest *request=[self getRequest:kURL(Kfigure)];
    NSString *token=[self.co getToken];
    
    NSMutableDictionary *dic=[self getDic];
    [dic setValue:token forKey:@"_tk"];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    [request addFile:file forKey:@"img"];
    
    
//    if (token) {
//        [request setPostValue:token forKey:@"_tk"];//tokens
//    }
//    [request addFile:file forKey:@"img"];
    
    
//    request.uploadProgressDelegate=self;
//    request.showAccurateProgress=YES;
    NSLog(@"---HSV---图像上传");
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.PLResponse settingHeadInfoBackWithData:nil isSuccess:NO];
        });
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse settingHeadInfoBackWithData:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse settingHeadInfoBackWithData:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        [request startAsynchronous];
        
    });


}

//-(void)setProgress:(float)newProgress{
//
//    NSLog(@"---newProgress==%f",newProgress);
//
//}

#pragma mark -评论回复
-(void)sendCommenFollowCMV:(CommentViewController *)VC andProgarm:(int)nProgarmID andArticleID:(int)nArticle andPicsID:(int)picID andFollowID:(int)nFollowID andContent:(NSString *)content{
    
    self.PLResponse.cv=VC;
    //获取当前时间
    NSDate *date=[NSDate date];
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString *token=[self.co getToken];
    
    ASIFormDataRequest *request=[self getRequest:kURL(Kfollow)];
    NSMutableDictionary *dic=[self getDic];
    [dic setValue:[NSNumber numberWithInteger:nProgarmID] forKey:@"programId"];
    [dic setValue:[NSNumber numberWithInteger:nArticle] forKey:@"articleId"];
    [dic setValue:[NSNumber numberWithInteger:nFollowID] forKey:@"followId"];
    [dic setValue:[NSString stringWithString:content] forKey:@"content"];
    [dic setValue:[NSNumber numberWithInt:time] forKey:@"addtime"];
    [dic setValue:[NSNumber numberWithInt:picID] forKey:@"picsId"];
    if (token) {
        [dic setValue:token forKey:@"_tk"];//tokens
    }
    
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
//    [request setPostValue:[NSNumber numberWithInteger:nProgarmID] forKey:@"programId"];
//    [request setPostValue:[NSNumber numberWithInteger:nArticle] forKey:@"articleId"];
//    [request setPostValue:[NSNumber numberWithInteger:nFollowID] forKey:@"followId"];
//    [request setPostValue:[NSString stringWithString:content] forKey:@"content"];
//    [request setPostValue:[NSNumber numberWithInt:time] forKey:@"addtime"];
//    [request setPostValue:[NSNumber numberWithInt:picID] forKey:@"picsId"];
//    if (token) {
//        [request setPostValue:token forKey:@"_tk"];//tokens
//    }
    
    NSLog(@"---NCM---请求评论");
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.PLResponse commentFollowInfoBackWithData:nil isSuccess:NO];
        });
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse commentFollowInfoBackWithData:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse commentFollowInfoBackWithData:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        [request startAsynchronous];
        
    });


}

#pragma mark -用户反馈
-(void)sendUserFeedBack:(FeedBackViewController *)VC andContent:(NSString *)info{
    ASIFormDataRequest *request=[self getRequest:kURL(kfeedBack)];
    self.PLResponse.fb=VC;
    
    NSMutableDictionary *dic=[self getDic];
    [dic setValue:[NSString stringWithString:info] forKey:@"content"];
    [dic setValue:[NSString stringWithString:KSystemVersion] forKey:@"systemVersion"];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
//    [request setPostValue:[NSString stringWithString:info] forKey:@"content"];
//    [request setPostValue:[NSString stringWithString:KSystemVersion] forKey:@"systemVersion"];
    
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.PLResponse feedBackInfoBackData:nil isSuccess:NO];
        });
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse feedBackInfoBackData:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse feedBackInfoBackData:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        [request startAsynchronous];
        
    });
}

#pragma mark -更多应用
-(void)queryMoreApp:(MoreAppViewController *)VC andPage:(NSString *)page{
    ASIFormDataRequest *request=[self getRequest:kURL(kmoreApp)];
    self.PLResponse.ma=VC;
    
    NSMutableDictionary *dic=[self getDic];
    [dic setValue:[NSString stringWithString:page] forKey:@"page"];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
    
   // [request setPostValue:[NSString stringWithString:page] forKey:@"page"];
    
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.PLResponse moreAppInfoBackData:nil isSuccess:NO];
        });
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse moreAppInfoBackData:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.PLResponse moreAppInfoBackData:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        [request startAsynchronous];
        
    });
}


//#pragma mark -请求用户信息
//-(void)queryUserInfo:(UserInfoViewController *)VC andUserName:(NSString *)name{
//    ASIFormDataRequest *request=[self getRequest:kURL(Kuserinfo)];
//    self.PLResponse.ui=VC;
//    
//    [request setPostValue:[NSString stringWithString:name] forKey:@"userName"];
//    
//    if (!request) {//没网络,下面不执行
//        NSLog(@"暂无可用网络");
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [self.PLResponse userinfoBackData:nil isSuccess:NO];
//        });
//        return;
//    }
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        __block ASIFormDataRequest* blockRequest=request;
//        //请求成功
//        [request setCompletionBlock:^{
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [self.PLResponse userinfoBackData:blockRequest isSuccess:YES];
//            });
//        }];
//        //请求失败
//        [request setFailedBlock:^{
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [self.PLResponse userinfoBackData:blockRequest isSuccess:NO];
//            });
//        }];
//        //发送请求
//        [request startAsynchronous];
//        
//    });
//
//}

@end
