//
//  CommentThemeModel.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentThemeModel : NSObject

@property (nonatomic,copy) NSString *programID;
@property (nonatomic,copy) NSString *shareUrl;
@property (nonatomic,copy) NSString *articleId;
@property (nonatomic,copy) NSString *picsId;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *sharePic;

-(id)initWithNSDictionary:(NSDictionary *)dic;

@end
