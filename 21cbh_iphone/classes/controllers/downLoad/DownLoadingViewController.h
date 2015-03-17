//
//  DownLoadingViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-12.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownLoadManager.h"

@interface DownLoadingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,DownLoadManagerDelegate>

#pragma mark 设置编辑状态
-(void)setEditStatus:(BOOL)b;

@end
