//
//  PicsListModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicsListModel : NSObject

- (id)initWithDict:(NSDictionary *)dict;


@property(copy,nonatomic)NSString *programId;//栏目id
@property(copy,nonatomic)NSString *picsId;//图集id
@property(copy,nonatomic)NSString *type;//图集展示类型(0:大; 1:大小小;  2:小小大)
@property(copy,nonatomic)NSString *title;//标题
@property(copy,nonatomic)NSString *followNum;//跟贴数
@property(copy,nonatomic)NSArray *picUrls;//item的微缩图集
@property(copy,nonatomic)NSString *order;//排序号
@property(copy,nonatomic)NSString *addtime;//时间戳

@end
