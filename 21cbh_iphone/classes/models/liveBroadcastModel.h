//
//  liveBroadcastModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-5-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface liveBroadcastModel : NSObject

- (id)initWithDict:(NSDictionary *)dict ;

@property(copy,nonatomic)NSString *liveType;//图标类型(1:普通消息; 2:消费指数消息; 3:专题)
@property(copy,nonatomic)NSString *programId;//栏目id
@property(copy,nonatomic)NSString *articleId;//该条新闻对应的ID
@property(copy,nonatomic)NSString *addtime;//时间戳
@property(copy,nonatomic)NSString *desc;//直播列表描述

@end
