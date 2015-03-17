//
//  NewsDetailModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsDetailModel : NSObject

@property(copy,nonatomic)NSString *programId;//栏目id
@property(copy,nonatomic)NSString *type;//类型(0:普通文章; 1:原创文章; 2:专题; 3:图集 4:视频; 5:推广 6:独家)
@property(copy,nonatomic)NSString *articleId;//本新闻的ID
@property(copy,nonatomic)NSString *followNum;//跟帖数
@property(copy,nonatomic)NSString *title;//新闻标题
@property(copy,nonatomic)NSString *articUrl;//新闻来源url(分享时用到)sharePic
@property(copy,nonatomic)NSString *sharePic;//分享微缩图
@property(copy,nonatomic)NSArray *picUrls;//图片数组
@property(copy,nonatomic)NSArray *descs;//描述数组
@property(copy,nonatomic)NSString *template;//模板
@property(copy,nonatomic)NSString *body;//新闻主体信息
@property(copy,nonatomic)NSString *addtime;//时间戳
@property(copy,nonatomic)NSString *breif;//描述

- (id)initWithDict:(NSDictionary *)dict;

@end
