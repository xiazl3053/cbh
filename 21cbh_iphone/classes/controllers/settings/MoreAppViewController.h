//
//  MoreApplicationViewController.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"

@protocol SKStoreProductViewControllerDelegate;
@class MoreAppOtherInfoModel;

@interface MoreAppViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,SKStoreProductViewControllerDelegate>

-(void)moreAppQueryInfoBackData:(NSArray *)moreApp and:(MoreAppOtherInfoModel *)model isSuccess:(BOOL)success;
@end
