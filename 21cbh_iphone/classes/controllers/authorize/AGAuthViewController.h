//
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>
#import "BaseViewController.h"

/**
 *	@brief	授权视图控制器
 */
@interface AGAuthViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>
{
@private
    UITableView *_tableView;
    NSMutableArray *_shareTypeArray;
}

@end
