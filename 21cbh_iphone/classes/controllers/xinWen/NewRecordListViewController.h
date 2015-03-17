//
//  NewRecordListViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-7-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NewListModel.h"

@protocol NewRecordListViewControllerDelegate;

@interface NewRecordListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
@property(assign,nonatomic)id<NewRecordListViewControllerDelegate>delegate;
@end

@protocol NewRecordListViewControllerDelegate <NSObject>

-(void)getNewListModel:(NewListModel *)nlm;

@end