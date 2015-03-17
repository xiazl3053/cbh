//
//  NewsContentView.h
//  21cbh_iphone
//
//  Created by Franky on 14-7-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewListModel.h"

@interface NewsContentView : UIView
{
    UIImageView* logoImg_;
    UILabel* titleLabel_;
    UILabel* descLabel_;
}

-(void)fillWithData:(NewListModel *)data;

@end
