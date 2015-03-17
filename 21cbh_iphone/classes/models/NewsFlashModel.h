//
//  NewsFlashModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsFlashModel : NSObject

- (id)initWithDict:(NSDictionary *)dict;

@property(copy,nonatomic)NSString *programId;//栏目id
@property(copy,nonatomic)NSString *articleId;//新闻id
@property(copy,nonatomic)NSString *title;//新闻标题


@end
