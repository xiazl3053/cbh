//
//  PushListViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewListModel.h"

@interface ConsultPushListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>


#pragma mark 获取新闻列表数据后的处理
-(void)getPushListHandle:(NSMutableArray *)_nlmsGroups isUp:(BOOL)isUp;

@end

