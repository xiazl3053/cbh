//
//  ContactsViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-6-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ContactBaseViewController.h"
#import "SWTableViewCell.h"
@class NewListModel;

@interface ContactsViewController : ContactBaseViewController<SWTableViewCellDelegate>
@property(strong,nonatomic)NewListModel *nlm;
@end
