//
//  SessionsViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-6-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"
#import "SWTableViewCell.h"
@class NewListModel;
@interface SessionsViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>
@property(strong,nonatomic)NewListModel *nlm;
@end
