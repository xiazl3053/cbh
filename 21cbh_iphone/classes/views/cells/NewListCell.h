//
//  NewListCell.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewListModel.h"
#import "NewListRecordDB.h"

@interface NewListCell : UITableViewCell

@property(weak,nonatomic) NSOperationQueue *dbQueue;//数据库操作队列
@property(strong,nonatomic)NewListRecordDB *nlrDB;

#pragma mark 设置cell1的数据
-(void)setCell1:(NewListModel *)nlm;
#pragma mark 设置cell2的数据
-(void)setCell2:(NewListModel *)nlm;
#pragma mark 设置cell3的数据
-(void)setCell3:(NewListModel *)nlm;

@end
