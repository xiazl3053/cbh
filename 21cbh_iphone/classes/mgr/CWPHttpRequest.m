//
//  CWPHttpRequest.m
//  21cbh_iphone
//
//  Created by Franky on 14-5-7.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CWPHttpRequest.h"
#import "ASIFormDataRequest.h"
#import "CommonOperation.h"

@implementation CWPHttpRequest

#pragma mark 初始化ASIFormDataRequest
+(ASIFormDataRequest *)getRequest:(NSString *)urlString{
    if(![[CommonOperation getId] getNetStatus]){
        return nil;
    }
    NSURL *url =[NSURL URLWithString:urlString];
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:url];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];//默认编码为utf-8
    [request setRequestMethod:@"POST"];
    
    //超时时间
    request.timeOutSeconds = 8;
    
    //设置参数
    NSString *version=[[CommonOperation getId] getVersion];
    NSString *token=[[CommonOperation getId] getToken];
    
    [request setPostValue:version forKey:@"version"];//版本号
    [request setPostValue:[NSString stringWithFormat:@"%i",kClientType] forKey:@"clientType"];//客户端类型
    
    if (token) {
        //[request setPostValue:token forKey:@"_tk"];//tokens
    }
    
    return request;
}

+(ASIHTTPRequest *)postPushInfoRequest:(NSString *)deviceToken userId:(NSString *)userId channelId:(NSString *)channelId tagName:(NSString *)tagName
{
    ASIFormDataRequest *request=[CWPHttpRequest getRequest:kURL(@"postPushInfo")];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return nil;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //设备号
        NSString *deviceId=[[CommonOperation getId] getUUID];
        [request setPostValue:deviceId forKey:@"deviceId"];
        [request setPostValue:userId forKey:@"userId"];
        [request setPostValue:channelId forKey:@"channelId"];
        [request setPostValue:tagName forKey:@"tagName"];
        //backUserId(我们自己后台的用户id,根据它来查找百度推送id)
        NSString *backUserId=[UserModel um].userId;
        [request setPostValue:backUserId forKey:@"backUserId"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            
            NSString *response=[blockRequest responseString];
            NSLog(@"IOS提交设备信息接口返回:%@",response);
        }];
        //请求失败
        [request setFailedBlock:^{
            NSLog(@"IOS提交设备信息接口失败");
        }];
        //发送请求
        [request startAsynchronous];
    });
    return request;
}

+(ASIHTTPRequest *)postPictureRequest:(NSString *)path progressBlock:(ASIProgressBlock)progressBlock completionBlock:(httpCompleteBlock)completionBlock
{
    ASIFormDataRequest *request=[CWPHttpRequest getRequest:kURL(@"picture")];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return nil;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *token=[[CommonOperation getId] getToken];
        if (token) {
            [request setPostValue:token forKey:@"_tk"];//tokens
        }
        NSString *screenType=[[CommonOperation getId] getScreenType];
        [request setPostValue:screenType forKey:@"screenType"];
        [request addFile:path forKey:@"pictureData"];
        
        [request setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
            if (progressBlock) {
                progressBlock(size,total);
            }
        }];
        
        __block ASIFormDataRequest* blockRequest=request;

        [request setCompletionBlock:^{
            NSString* respone=blockRequest.responseString;
            NSDictionary* dic=[respone JSONValue];
            NSString* error=[dic objectForKey:@"errno"];
            if([error isEqualToString:@"0"])
            {
                NSLog(@"上传图片成功%@",respone);
                NSDictionary* data=[dic objectForKey:@"data"];
                if(completionBlock && dic && [[dic class]isSubclassOfClass:[NSDictionary class]]){
                    completionBlock(data,YES);
                }
            }
        }];
        
        //请求失败
        [request setFailedBlock:^{
            NSLog(@"上传图片失败");
        }];

        //发送请求
        [request startAsynchronous];
    });
    return request;
}
#pragma mark 通讯录匹配上传接口
+(ASIHTTPRequest*)postMatchContactsRequest:(NSString*)phone completionBlock:(httpCompleteBlock)completionBlock
{
    ASIFormDataRequest* request=[CWPHttpRequest getRequest:kURL(@"matchContacts")];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *token=[[CommonOperation getId] getToken];
        if (token) {
            [request setPostValue:token forKey:@"_tk"];//tokens
        }
        [request setPostValue:phone forKey:@"phone"];
        
        __block ASIFormDataRequest* blockRequest=request;
        [request setCompletionBlock:^{
            NSString* respone=blockRequest.responseString;
            NSDictionary* dic=[respone JSONValue];
            NSString* error=[dic objectForKey:@"errno"];
            if([error isEqualToString:@"0"])
            {
                NSLog(@"通讯录匹配接口请求成功%@",respone);
                if(completionBlock && dic && [[dic class]isSubclassOfClass:[NSDictionary class]]){
                    completionBlock(dic,YES);
                }
            }
        }];
        
        //请求失败
        [request setFailedBlock:^{
            NSLog(@"通讯录匹配接口请求失败");
            if(completionBlock)
            {
                completionBlock(nil,NO);
            }
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
    return request;
}
#pragma mark 聊天界面股票接口
+(ASIHTTPRequest*)postStockInformationRequest:(NSString*)marketId markType:(NSString*)type completionBlock:(httpCompleteBlock)completionBlock
{
    ASIFormDataRequest* request=[CWPHttpRequest getRequest:kURL(@"stockInformation")];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [request setPostValue:marketId forKey:@"marketId"];
        [request setPostValue:type forKey:@"type"];
        
        __block ASIFormDataRequest* blockRequest=request;
        [request setCompletionBlock:^{
            NSString* respone=blockRequest.responseString;
            NSDictionary* dic=[respone JSONValue];
            NSString* error=[dic objectForKey:@"errno"];
            if([error isEqualToString:@"0"])
            {
                NSDictionary* data=[dic objectForKey:@"data"];
                if(completionBlock && dic && [[dic class]isSubclassOfClass:[NSDictionary class]]){
                    completionBlock(data,YES);
                }
            }
        }];
        
        [request setFailedBlock:^{
            
            NSLog(@"股票接口请求失败");
            if(completionBlock){
                completionBlock(nil,NO);
            }
        }];
        
        //发送请求
        [request startAsynchronous];
    });
    
    
    return request;
}

@end
