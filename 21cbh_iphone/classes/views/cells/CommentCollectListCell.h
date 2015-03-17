//
//  ReplyListCell.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CommentInfoModel;

@interface CommentCollectListCell : UITableViewCell

#pragma mark 设置cell的数据
-(void)setCell:(CommentInfoModel *)nlm;

@end
