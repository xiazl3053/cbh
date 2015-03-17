//
//  RequestList.m
//  MultipleRequest
//
//  Created by qinghua on 14-12-26.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import "RequestManager.h"
#import "CommonOperation.h"
#import "DES3Util.h"
#import "MD5.h"
#import "GTMBase64.h"
#import<CommonCrypto/CommonCryptor.h>



__strong static NSMutableDictionary *_requestList=nil;
__strong static RequestManager *_sharedObject = nil;
@interface RequestManager ()<ASIHTTPRequestDelegate>{
    
}

@end

@implementation RequestManager

+(RequestManager *)shareRequestManager
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        _requestList=[[NSMutableDictionary alloc]init];
    });
    return _sharedObject;
}

#pragma mark -添加请求-1
//-(void)addRequestWithQuest:(ASIFormDataRequest *)quest completion:(RequestRepose)block{
//    [self appendBaseParameter:quest];
//    [self addQuestlist:quest completion:block];
//    [quest setDelegate:self];
//    [quest startAsynchronous];
//}

#pragma mark -添加请求-2
-(void)addRequestWithParameter:(NSDictionary *)dic completion:(RequestRepose)block{
    NSString *main=[dic objectForKey:KMainInterface];
    NSString *sub=[dic objectForKey:KSubInterface];
    NSURL *url=[NSURL URLWithString:KNewQuestURL(main, sub)];
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc]initWithURL:url];
    [request setTimeOutSeconds:MAXFLOAT];
    [self appendBaseParameter:request];
    NSString *guid=[self createGUID];
    [self addQuestlist:request requestID:guid completion:block];
    //加密
    NSMutableDictionary *parameter=[self getDevice];
    for (NSString *obj in dic.allKeys) {
        [parameter setValue:[dic objectForKey:obj] forKey:obj];
    }
    [parameter setValue:guid forKey:@"requestId"];
    NSString *data=[[CommonOperation getId]encryptHttp:parameter];
    [request setPostValue:data forKey:@"data"];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:guid,@"requestID",nil]];
    //请求
    [request setDelegate:self];
    [request startAsynchronous];
}

#pragma mark -common参数拼接
-(void)appendBaseParameter:(ASIFormDataRequest *)quest{
    [quest setDefaultResponseEncoding:NSUTF8StringEncoding];//默认编码为utf-8
    [quest setRequestMethod:@"POST"];
}

#pragma mark 初始化参数
-(NSMutableDictionary *)getDevice{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    
    //设置参数
    NSString *version=[[CommonOperation getId] getVersion];
    NSString *screenType=[[CommonOperation getId] getScreenType];
    
    [dic setValue:[NSString stringWithFormat:@"%i",kClientType] forKey:@"clientType"];//客户端类型
    [dic setValue:version forKey:@"version"];//版本号
    [dic setValue:screenType forKey:@"screenType"];//图片尺寸类型
    return dic;
}


#pragma mark -requestFinished
-(void)requestFinished:(ASIHTTPRequest *)request{
    NSLog(@"%s,responseString==%@",__FUNCTION__,[request responseString]);
    NSString *responseString=[request responseString];
    NSDictionary *dic=[responseString JSONValue];
    NSDictionary *data=[dic objectForKey:@"data"];
    NSString *requestId=[data objectForKey:@"requestId"];
    [self removeTimerForGuid:requestId data:dic reposeStatus:ReposeStausCode_Success];
}

#pragma mark -requestFailed
-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"%s,responseString==%@",__FUNCTION__,[request error]);
    [self removeTimerForGuid:[self captureReQuestIDFromRequest:request] data:nil reposeStatus:ReposeStausCode_NetWorkError];
}

#pragma mark -添加到请求列表
-(void)addQuestlist:(ASIFormDataRequest *)quest requestID:(NSString *)guid completion:(RequestRepose)block{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setValue:[self createTimerWithGuid:guid] forKey:KTimerKey];
    [dic setValue:block forKey:KCompletionKey];
    [_requestList setValue:dic forKey:guid];
    NSLog(@"_requestList=%@",_requestList);
}

#pragma mark -createGUID
-(NSString *)createGUID{
    CFUUIDRef guidObj = CFUUIDCreate(nil);
    NSString *guidString = [NSString stringWithFormat:@"%@",CFBridgingRelease(CFUUIDCreateString(nil, guidObj))];
    CFRelease(guidObj);
    return guidString;
}

#pragma mark -createTimer
-(dispatch_source_t )createTimerWithGuid:(NSString *)guid{
    dispatch_source_t source=dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(source, dispatch_time(DISPATCH_TIME_NOW, 15ull*NSEC_PER_SEC), 5ull*NSEC_PER_SEC, 1ull*NSEC_PER_SEC);
    dispatch_source_set_event_handler(source, ^{
        NSLog(@"-------Timer out--------%@,%@",guid,[NSThread currentThread]);
        //dispatch_source_cancel(source);
        dispatch_async(dispatch_get_main_queue(), ^{
           [self removeTimerForGuid:guid data:nil reposeStatus:ReposeStausCode_TimerOut];
        });
    });
    dispatch_resume(source);
    return source;
}

#pragma mark -回调block
-(void)removeTimerForGuid:(NSString *)guid data:(NSDictionary *)data reposeStatus:(ReposeStausCode)code{
    NSDictionary *dic=_requestList[guid];
    if (dic) {
        dispatch_source_t  t= [dic objectForKey:KTimerKey];
        RequestRepose completion=[dic objectForKey:KCompletionKey];
        if (t) {
            dispatch_source_cancel(t);
        }
        if (completion) {
            completion(data,code);
        }
        [_requestList removeObjectForKey:guid];
    }
    NSLog(@"_requestList=%@",_requestList);
}

-(NSString *)captureReQuestIDFromRequest:(ASIHTTPRequest *)request{
    NSDictionary *dic=[request userInfo];
    return [dic objectForKey:@"requestID"];
}


-(void)test{
//    VoiceListModel *model=[[VoiceListModel alloc]init];
//    model.title=@"曲目1-1:今天-刘德华-Andy";
//    model.addtime=@"1-11";
//    model.duration=@"1分";
//    model.voiceUrl=@"http://y1.eoews.com/assets/ringtones/2012/5/18/34045/hi4dwfmrxm2citwjcc5841z3tiqaeeoczhbtfoex.mp3";
//    
//    VoiceListModel *model1=[[VoiceListModel alloc]init];
//    model1.title=@"曲目1-2:温柔--五月天";
//    model1.addtime=@"1-12";
//    model1.duration=@"2分";
//    model1.voiceUrl=@"http://y1.eoews.com/assets/ringtones/2012/5/18/34049/oiuxsvnbtxks7a0tg6xpdo66exdhi8h0bplp7twp.mp3";
//    
//    VoiceListModel *model2=[[VoiceListModel alloc]init];
//    model2.title=@"曲目1-3:K歌之王-陈奕迅";
//    model2.addtime=@"1-13";
//    model2.duration=@"3分";
//    model2.voiceUrl=@"http://y1.eoews.com/assets/ringtones/2012/5/17/34031/axiddhql6nhaegcofs4hgsjrllrcbrf175oyjuv0.mp3";
//    
//    
//    NSArray *list=[NSArray arrayWithObjects:model,model1,model2, nil];
}

@end
