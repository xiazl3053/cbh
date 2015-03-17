//
//  kNewsDetailViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-4-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hqBaseViewController.h"

@interface kNewsDetailViewController : hqBaseViewController

@property (nonatomic,retain) NSString *column;// 栏目ID 0=新闻  1=情报 2=公告
@property (nonatomic,retain) NSString *articleId;// 新闻Id

#pragma mark 初始化控制器
-(id)initNoticeWithArticleId:(NSString*)articleId andkId:(NSString*)kId andkType:(NSString*)type;
@end
