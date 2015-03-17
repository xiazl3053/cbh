//
//  PushNotificationHandler.h
//  21cbh_iphone
//
//  Created by Franky on 14-5-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PushNotificationHandlerDelegate <NSObject>

/**
 @brief 处理推送消息，本来应该在内部进行一些类型等判别，但还没有格式，先全部数据给出去处理。
 @param userInfo 消息的userinfo
 @param start 消息是在启动程序时还是程序运行中收到
 */
- (void)handleRecievePushNotification:(NSDictionary *)userInfo withStart:(BOOL)start;

/**
 @brief 发送设备令牌到服务器，发送中还需要用户信息的一些参数以供服务器查询相关要推送的信息。
 @param deviceToken 设备令牌
 @param pushChannel 对应百度 "channel_id"
 @param pushUserID 对应百度 "user_id"
 @param delegate 服务返回数据接收处理代理,为nil时不处理
 */
- (void)sendDeviceTokenToServer:(NSString*)deviceToken withBaiduPushChannel:(NSString*)pushChannel withBaiduPushUserID:(NSString*)pushUserID delegate:(id)delegate;

@end

@interface PushNotificationHandler : NSObject

@property (nonatomic, assign) NSObject<PushNotificationHandlerDelegate>* delegate;
@property (nonatomic, retain) NSString *deviceTokenString;
@property (nonatomic, retain) NSString *pushChannel;
@property (nonatomic, retain) NSString *pushUserID;

/**
 @brief 取单例实体。
 */
+ (PushNotificationHandler *)instance;

/**
 @brief 发送给服务器 启动的时候执行。
 */
//-(void)postPushInfo;

/**
 @brief 注册push消息，放在AppDelegate的application:didFinishLaunchingWithOptions:中调用。
 @param launchOptions 程序启动选项参数，如果是push消息，此函数才进行处理。
 */
- (void)registerPushNotificationAndLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 @brief 注册push消息，当要启动推送的时候设置。
 */
- (void)registerForRemoteNotification;

/**
 @brief 取消注册push消息，在要取消push消息时调用。
 */
- (void)unregisterForRemoteNotifications;

/**
 @brief 注册远程消息push成功，放在AppDelegate的application:didRegisterForRemoteNotificationsWithDeviceToken:中调用。
 @param deviceToken 设备令牌
 */
- (void)registerPushNotificationSuccessWithDeviceToken:(NSData*)deviceToken;

/**
 @brief 程序运行时收到push消息，放在AppDelegate的applicationRecievePushNotification:中调用
 @param userInfo 消息的userinfo
 */
- (void)applicationRecievePushNotification:(NSDictionary *)userInfo;

/**
 @brief 获取推送标签列表
 */
-(NSString *)getPushTags;

/**
 @brief 添加多个标签
 @param tagString 要设置的标签字符串,用","号分割
 */
-(void)addPushTags:(NSString *)tagString;

/**
 @brief 移除多个标签
 @param tagString 要设置的标签字符串,用","号分割
 */
-(void)deletePushTags:(NSString *)tagString;

/**
 @brief 保存推送标签设置
 */
-(void)savePushTags;

/**
 @brief 设置推送消息的开启关闭状态
 @param status 开启关闭状态
 @param reportDelegate 服务返回数据接收处理代理
 */
- (void)setPushNotificationStatus:(BOOL)status reportDelegate:(id)reportDelegate;

@end
