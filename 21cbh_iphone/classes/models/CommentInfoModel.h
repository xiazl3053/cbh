//
//  CommentInfoModel.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentInfoModel : NSObject<NSCopying,NSMutableCopying>

@property (nonatomic,copy) NSString *commentTitle;//新闻标题
@property (nonatomic,copy) NSString *commentUrl;//新闻Url
@property (nonatomic,copy) NSString *progarmID;//目录ID
@property (nonatomic,copy) NSString *followID;//followID
@property (nonatomic,copy) NSString *commentID;//评论ID
@property (nonatomic,copy) NSString *commentUserHeadUrl;//用户相片
@property (nonatomic,copy) NSString *commentUserNickName;//用户昵称
@property (nonatomic,copy) NSString *commentUserLocation;//用户地址
@property (nonatomic,copy) NSString *commentTopNum;//顶贴数
@property (nonatomic,copy) NSString *commentContent;//回复内容
@property (nonatomic,assign) BOOL isOpenComment;//是否展开楼层
@property (nonatomic,assign) BOOL isTop;
@property (nonatomic,assign) int number;

//newFollows
@property (nonatomic,copy) NSString *commentTime;

@property (nonatomic,copy) NSArray *commentFollows;
-(id)initWithNSDictionary:(NSDictionary *)dic;

@end
