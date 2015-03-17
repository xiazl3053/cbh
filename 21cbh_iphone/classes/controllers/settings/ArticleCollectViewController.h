//
//  ArticleCollectViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "MyCollectsViewController.h"

@interface ArticleCollectViewController : UITableViewController

@property(weak,nonatomic)MainViewController *main;
@property(weak,nonatomic)MyCollectsViewController *mcv;
@property(weak,nonatomic)NSOperationQueue *dbQueue;


#pragma mark 设置编辑状态
-(void)setEditStatus:(BOOL)b;

@end
