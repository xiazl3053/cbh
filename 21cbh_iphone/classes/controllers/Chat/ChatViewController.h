//
//  ChatViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"
#import "TopBar.h"
#import "NewListModel.h"

@interface ChatViewController : BaseViewController<TopBarDelegate>

@property(strong,nonatomic)NewListModel *nlm;


-(id)initWithModel:(NewListModel *)nlm;

@end
