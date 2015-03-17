//
//  NewsSepcialViewController.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"
@class NewListModel;

@interface NewsSpecialViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

-(void)getSpecialBack:(NSArray *)data andSpecialInfo:(NewListModel *)info isSuccess:(BOOL)b errro:(NSDictionary *)dic;

-(id)initWithProgramID:(NSString *)programID AndSpecialID:(NSString *)specialID;

@end
