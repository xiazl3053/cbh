//
//  PicsListCell.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicsListModel.h"

@interface PicsListCell : UITableViewCell

#pragma mark 设置cell1的数据(大微缩图)
-(void)setCell1:(PicsListModel *)plm;
#pragma mark 设置cell2的数据(大小小微缩图)
-(void)setCell2:(PicsListModel *)plm;
#pragma mark 设置cell3的数据(小小大微缩图)
-(void)setCell3:(PicsListModel *)plm;

@end
