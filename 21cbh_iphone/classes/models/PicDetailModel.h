//
//  PicDetailModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicDetailModel : NSObject

- (id)initWithDict:(NSDictionary *)dict ;

@property(copy,nonatomic)NSString *desc;//图集里的单张图片描述
@property(copy,nonatomic)NSArray *picUrls;//图集里的单张图片地址


@end

