//
//  UserModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject<NSCoding>

@property(copy,nonatomic)NSString *userName;//用户名
@property(copy,nonatomic)NSString *userId;//用户id
@property(copy,nonatomic)NSString *nickName;//用户昵称
@property(copy,nonatomic)NSString *balance;//余额
@property(copy,nonatomic)NSString *grade;//等级
@property(copy,nonatomic)NSString *gradeName;//等级称号
@property(copy,nonatomic)NSString *expbalance;//升级经验差额
@property(copy,nonatomic)NSString *picUrl;//用户头像
@property(copy,nonatomic)NSString *phoneNum;//用户绑定的手机号
@property(copy,nonatomic)NSString *uuid;//OpenFire的登陆id,聊天用到


#pragma mark 返回单例对象
+ (UserModel *)um;
#pragma mark 设置数据
- (void)setDict:(NSDictionary *)dict;
#pragma mark 清除数据
-(void)clearData;
@end
