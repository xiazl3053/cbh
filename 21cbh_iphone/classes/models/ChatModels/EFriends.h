//
//  EFriends.h
//  DFMMessage
//
//  Created by 21tech on 14-5-27.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EFriends_SELECT_STATUS) {
    EFriends_SELECT_STATUS_NO,
    EFriends_SELECT_STATUS_YES,
    EFriends_SELECT_STATUS_DISABLED,

};

@interface EFriends : NSObject

@property (nonatomic, retain) NSString * firstChar; // 首字母
@property (nonatomic, retain) NSString * userName;  // 用户名
@property (nonatomic, retain) NSString * jid;       // 用户JID  user@domain.com/resouces
@property (nonatomic, retain) NSString * nickName;  // 用户昵称
//@property (nonatomic, retain) NSString * remark;     //  备注
@property (nonatomic, retain) NSString * note;      // 用户简介
@property (nonatomic, retain) NSString * myJID;     // 本地登陆用户的JID
@property (nonatomic, copy)   NSString * pinYin;    // 用户全称拼音
@property (nonatomic, copy)   NSString * iconUrl;   // 用户图像url
@property (nonatomic, copy)   NSString * location;  // 用户位置信息
@property (nonatomic, copy)   NSString * telephone; // 电话号码信息
@property (nonatomic, copy)   NSString * UUID;      // 帐号名
@property (nonatomic, assign) BOOL isTop;           // 是否置顶 0=否 1=是
@property (nonatomic, assign) BOOL isShield;        // 是否屏蔽 0=否 1=是
@property (nonatomic, assign) BOOL isFriend;       //是否是好友
@property (nonatomic, assign) EFriends_SELECT_STATUS isSelect;        // 是否选择

-(id)initWithNSDictionary:(NSDictionary *)dic;

@end
