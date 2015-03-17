//
//  PicInfoModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicInfoModel : NSObject

- (id)initWithDict:(NSDictionary *)dict ;

@property(copy,nonatomic)NSString *programId;//栏目id
@property(copy,nonatomic)NSString *picsId;//图集id
@property(copy,nonatomic)NSString *title;//图集标题
@property(copy,nonatomic)NSString *sharePic;//分享微缩图
@property(copy,nonatomic)NSString *shareUrl;//分享地址


@end
