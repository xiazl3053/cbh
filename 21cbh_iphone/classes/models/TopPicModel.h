//
//  TopPicModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopPicModel : NSObject//头图实体类


@property(copy,nonatomic)NSString *picUrl;//头图图片地址
@property(copy,nonatomic)NSString *desc;//头图图片描述
@property(copy,nonatomic)NSString *type;//类型(0:普通文章; 1:原创文章; 2:专题; 3:图集 4:视频; 5:推广 6:独家)
@property(copy,nonatomic)NSString *articleId;//文章id
@property(copy,nonatomic)NSString *specialId;//专题id
@property(copy,nonatomic)NSString *picsId;//图集id
@property(copy,nonatomic)NSString *videoId;//视频id
@property(copy,nonatomic)NSString *adId;//广告id
@property(copy,nonatomic)NSString *adUrl;//广告页(广告客户的网页地址)
@property(copy,nonatomic)NSString *videoUrl;//视频播放地址
@property(copy,nonatomic)NSString *addtime;//时间戳


- (id)initWithDict:(NSDictionary *)dict ;
@end
