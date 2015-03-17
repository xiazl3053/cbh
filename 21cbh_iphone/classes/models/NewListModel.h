//
//  NewListModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewListModel : NSObject


@property(copy,nonatomic)NSString *type;//类型(0:普通文章; 1:原创文章; 2:专题; 3:图集 4:视频; 5:推广)
@property(copy,nonatomic)NSString *programId;//栏目id
@property(copy,nonatomic)NSString *articleId;//文章id
@property(copy,nonatomic)NSString *picsId;//图集id
@property(copy,nonatomic)NSString *specialId;//专题id
@property(copy,nonatomic)NSString *videoId;//视频id
@property(copy,nonatomic)NSString *adId;//广告id
@property(strong,nonatomic)NSArray *picUrls;//图片集合(图集类型是3张微缩图,其余类型一张)
@property(copy,nonatomic)NSString *title;//新闻列表标题
@property(copy,nonatomic)NSString *desc;//新闻列表描述
@property(copy,nonatomic)NSString *followNum;//跟贴数
@property(copy,nonatomic)NSString *adUrl;//广告页(广告客户的网页地址)
@property(copy,nonatomic)NSString *videoUrl;//视频播放地址
@property(copy,nonatomic)NSString *order;//排序号
@property(copy,nonatomic)NSString *addtime;//时间戳



- (id)initWithDict:(NSDictionary *)dict;

@end
