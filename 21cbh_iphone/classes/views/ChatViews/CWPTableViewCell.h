//
//  CWPTableViewCell.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageItemAdaptor.h"

@interface CWPTableViewCell : UITableViewCell
{
    UILabel* timeLabel_;
    MessageItemAdaptor* message_;
}

+(int)currentCellHeight:(MessageItemAdaptor*)message;
-(void)fitWithData:(MessageItemAdaptor*)message;

@end
