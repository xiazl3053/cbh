//
//  MoreAppModel.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MoreAppModel.h"

@implementation MoreAppModel

-(id)initWithNSDictionary:(NSDictionary *)dic{
    if (self=[super init]) {
        self.iconUrl=[dic objectForKey:@"appImgUrl"];
        if (!self.iconUrl||![self.iconUrl isKindOfClass:[NSString class]]) {
            self.iconUrl=@"";
        }
        self.title=[dic objectForKey:@"appName"];
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.desc=[dic objectForKey:@"appDesc"];
        if (!self.desc||![self.desc isKindOfClass:[NSString class]]) {
            self.desc=@"";
        }
        self.ID=[dic objectForKey:@"appId"];
        if (!self.ID||![self.ID isKindOfClass:[NSString class]]) {
            self.ID=@"";
        }
        self.scheme=[dic objectForKey:@"appScheme"];
        if (!self.scheme||![self.scheme isKindOfClass:[NSString class]]) {
            self.scheme=@"";
        }
    }
    return self;
}

@end
