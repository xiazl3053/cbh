//
//  CommonOperation.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileOperation.h"
#import "ZXCycleScrollView.h"
#import "UserModel.h"
#import "AppDelegate.h"
#import <sqlite3.h>
#import "Reachability.h"
#import "TopPicModel.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "ZXUserDataManager.h"
#import "XinWenHttpMgr.h"
#import "BindingMobileViewController.h"
#import "SelectUserChatViewController.h"
#import "ChatViewController.h"
#import "PlayManager.h"

BOOL isActive;//app是否是激活状态
CBPMoviePlaybackState playerState; //播放器进入后台状态

@interface CommonOperation : NSObject

+(CommonOperation *)getId;

#pragma mark 获取网络连接状态
-(BOOL)getNetStatus;
#pragma mark 提示信息
-(void)showAlert:(NSString *)info;
#pragma mark 获取屏幕宽度和高度
-(CGSize)getScreenSize;
#pragma mark 获取最佳尺寸类型参数
-(NSString *)getScreenType;
#pragma mark 获取版本号
-(NSString *)getVersion;
#pragma mark 设置token
-(void)setToken:(NSString *)token;
#pragma mark 获取token
-(NSString *)getToken;
#pragma mark 设置appleToken
-(void)setAppleToken:(NSString *)appleToken;
#pragma mark 获取appleToken
-(NSString *)getAppleToken;
#pragma mark 检验账号昵称的合法性
-(BOOL)isValidateName:(NSString *)name;
#pragma mark 检验密码的合法性
-(BOOL)isValidatePassword:(NSString *)password;
#pragma mark 检验邮箱的合法性
-(BOOL)isValidateEmail:(NSString *)email;
#pragma 手机号码验证
-(BOOL) isValidateMobile:(NSString *)mobileNum;
#pragma mark 跳转到登陆页
+(void)goTOLogin;
#pragma mark 跳转到手机绑定页
+(void)goToBindPhone;
#pragma mark 跳转到联系人页
+(void)goToContacts;
#pragma mark 跳转到聊天主页
+(void)goToChatViewWithModel:(NewListModel *)nlm;
#pragma mark 将用户信息写进本地
+(void)writeUmToLoacal:(UserModel *)um;
#pragma mark 清除用户信息
+(void)clearUm;
#pragma mark 获取UUID(自写的标识)
-(NSString *)getUUID;
#pragma mark 获取时间戳
-(NSString *)getAddtime;
#pragma mark 具体跳转操作(公共方法)
-(void)gotoViewController:(UIViewController*)controller;
#pragma mark 获取main
-(MainViewController *)getMain;
#pragma mark 设置lable的行距
-(void)setIntervalWithTextView:(UITextView *)textView text:(NSString *)text font:(UIFont *)font lineSpace:(CGFloat)lineSpace color:(UIColor *)color;
#pragma mark 时间戳转换成时间
-(NSString *)addtimeTurnToTimeString:(NSString *)addtime;
-(NSString *)addtimeTurnToTimeString2:(NSString *)addtime;

#pragma mark 获取当前UINavigationController
- (UIViewController*)getCurrectNavigationController;

#pragma mark 第三方授权成功后存储用户信息
-(void)savedata:(NSString *)nickName andShareType:(int)type;

#pragma 检测是否删表
-(void)checkTableUpdateWithTableName:(NSString *)tableName className:(NSString *)className db:(sqlite3 *)db;
#pragma 检测是否删数据库
-(void)checkTableDeleteWithClassName:(NSString *)className path:(NSString*)path;
-(BOOL)addCoumnWithTableName:(NSString *)tableName className:(NSString *)className columnName:(NSString*)columnName typeData:(NSString*)typeData db:(sqlite3 *)db;
#pragma mark 生成唯一GUID
+ (NSString*)stringWithGUID;
#pragma mark 清缓存
-(void)clearCach;
#pragma mark 自动检查清除用户的缓存数据
-(void)automaticClearCach;
#pragma mark 退出登陆
-(void)loginout;
#pragma mark 注册苹果推送服务
-(void)registerApplePush;
#pragma mark 获取屏幕的高度
-(CGFloat)getScreenHeight;
#pragma mark 加密
-(NSString *)encryptHttp:(NSDictionary *)dic;
#pragma mark 获取手机存储空间
-(NSString *)freeDiskSpaceInBytes;
@end
