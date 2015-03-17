//
//  PushNotificationHandler.m
//  21cbh_iphone
//
//  Created by Franky on 14-5-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PushNotificationHandler.h"
#import <Frontia/Frontia.h>
#import "CommonOperation.h"
#import "CWPHttpRequest.h"
#import "UserModel.h"

#define KPushTags @"PushTags"

@interface PushNotificationHandler()
{
   // NSMutableArray* curTagArray;
}

@property (nonatomic,strong) NSMutableArray *curTagArray;

@end

static PushNotificationHandler *sharedInstance_ = nil;

@implementation PushNotificationHandler

@synthesize delegate;
@synthesize deviceTokenString;
@synthesize pushChannel;
@synthesize pushUserID;

+ (PushNotificationHandler *)instance
{
    @synchronized(self){
        if(sharedInstance_ == nil){
            sharedInstance_ = [[PushNotificationHandler alloc] init];
        }
    }
    return sharedInstance_;
}

-(id)init
{
    if(self=[super init]){
        self.curTagArray=[[NSMutableArray alloc]initWithCapacity:1];
    }
    return self;
}

- (void)registerPushNotificationAndLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *isPush=[defaults objectForKey:kIsPush];
    if ([isPush isEqualToString:@"1"]) {
        NSLog(@"开始注册苹果推送");
        [Frontia getPush];
        [FrontiaPush setupChannel:launchOptions];
        [self registerForRemoteNotification];
        //用户是从推送消息中启动程序时
        if (launchOptions)
        {
            NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (userInfo)
            {
                [self performSelector:@selector(handleRecievePushNotification:) withObject:userInfo afterDelay:2];
            }
        }
    }
}

- (void)registerForRemoteNotification
{
    //设置程序的消息推送
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
    
}

- (void)handleRecievePushNotification:(NSDictionary*)userInfo
{
    NSLog(@"PushNotificationInfo:%@",userInfo);
    if (self.delegate && [self.delegate respondsToSelector:@selector(handleRecievePushNotification: withStart:)])
    {
        [self.delegate handleRecievePushNotification:userInfo withStart:TRUE];
    }
}

- (void)unregisterForRemoteNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void)registerPushNotificationSuccessWithDeviceToken:(NSData*)deviceToken
{
    [FrontiaPush registerDeviceToken: deviceToken];
    NSString *pushToken =[[[deviceToken description]
                           stringByReplacingOccurrencesOfString:@"<" withString:@""]
                          stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSLog(@"获取苹果官方的deviceToken成功!deviceToken:%@", pushToken);
    self.deviceTokenString = pushToken;
    FrontiaPush *push = [Frontia getPush];
    if(push) {
        [push bindChannel:^(NSString *appId, NSString *userId, NSString *channelId) {
            self.pushUserID=userId;
            self.pushChannel=channelId;
            [self performSelectorOnMainThread:@selector(postPushInfo) withObject:nil waitUntilDone:NO];
        } failureResult:^(NSString *action, int errorCode, NSString *errorMessage) {
            NSLog(@"百度推送绑定失败");
        }];
    }
    [[CommonOperation getId] setAppleToken:pushToken];
}

- (void)applicationRecievePushNotification:(NSDictionary *)userInfo
{
    if (!userInfo) {//如果没推送信息就不处理
        return;
    }
    [FrontiaPush handleNotification:userInfo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(handleRecievePushNotification: withStart:)])
    {
        [self.delegate handleRecievePushNotification:userInfo withStart:FALSE];
    }
}

-(void)postPushInfo
{
    NSString* str=[self getPushTags];
    [CWPHttpRequest postPushInfoRequest:self.deviceTokenString userId:self.pushUserID channelId:self.pushChannel tagName:str];
}

-(NSString *)getPushTags
{
    NSString* userId=(NSString*)[UserModel um].userId;
    if([userId.class isSubclassOfClass:[NSString class]]&&userId.length>0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* key=[NSString stringWithFormat:@"%@%@",KPushTags,[UserModel um].userId];
        NSString* str=[defaults objectForKey:key];
        return str;
    }
    else
    {
        return @"";
    }
}

-(void)addPushTags:(NSString *)tagString
{
        NSArray* tagArray=[tagString componentsSeparatedByString:@","];
        for (NSString* str in tagArray) {
            if(![self.curTagArray containsObject:str])
            {
                [self.curTagArray addObject:str];
            }
        }
        
        NSLog(@"[NSThread currentThread]==%@",[NSThread currentThread]);
        NSLog(@"================addPushTags==========%@",tagString);
    @try {
        FrontiaPush *push = [Frontia getPush];
        if(push) {
            [push setTags:tagArray tagOpResult:^(int count, NSArray *failureTag) {
                NSLog(@"添加标签成功数:%d,失败的Tag:%@",count,failureTag);
                for (NSString* str in failureTag) {
                    if([self.curTagArray containsObject:str])
                    {
                        [self.curTagArray removeObject:str];
                    }
                }
            } failureResult:^(NSString *action, int errorCode, NSString *errorMessage) {
                NSLog(@"添加标签失败");
            }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception===%@",exception);
    }
    @finally {
        
    }
}

-(void)deletePushTags:(NSString *)tagString
{
    NSArray* tagArray=[tagString componentsSeparatedByString:@","];
    for (NSString* str in tagArray) {
        if([self.curTagArray containsObject:str])
        {
            [self.curTagArray removeObject:str];
        }
    }
    @try {
        FrontiaPush *push = [Frontia getPush];
        if(push) {
            NSArray* tagArray=[tagString componentsSeparatedByString:@","];
            [push delTags:tagArray tagOpResult:^(int count, NSArray *failureTag) {
                NSLog(@"删除标签成功数:%d,失败的Tag:%@",count,failureTag);
            } failureResult:^(NSString *action, int errorCode, NSString *errorMessage) {
                NSLog(@"删除标签失败");
            }];
        }
    }
    @catch (NSException *exception) {
         NSLog(@"exception======%@",exception);
    }
    @finally {
    
    }
}

-(void)savePushTags
{
    
    NSLog(@"[NSThread currentThread]==%@",[NSThread currentThread]);
    NSLog(@"=========savePushTags==========%@",self.curTagArray);
    NSString* userId=[UserModel um].userId;
    if(userId.length>0)
    {
        BOOL flag=true;
        NSMutableString* muStr=[[NSMutableString alloc]initWithCapacity:1];
        for (NSString* str in self.curTagArray) {
            if(!flag){
                [muStr appendString:@","];
            }
            [muStr appendString:str];
            flag=false;
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* key=[NSString stringWithFormat:@"%@%@",KPushTags,userId];
        [defaults setObject:muStr forKey:key];
        [defaults synchronize];
    }
}

- (void)setPushNotificationStatus:(BOOL)status reportDelegate:(id)reportDelegate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendDeviceTokenToServer:withBaiduPushChannel:withBaiduPushUserID:delegate:)])
    {
        [self.delegate sendDeviceTokenToServer:self.deviceTokenString withBaiduPushChannel:self.pushChannel withBaiduPushUserID:self.pushUserID delegate:reportDelegate];
    }
}

@end
