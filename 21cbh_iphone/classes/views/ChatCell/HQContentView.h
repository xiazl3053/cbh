//
//  HQContentView.h
//  21cbh_iphone
//
//  Created by Franky on 14-7-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "RequestContentView.h"

@interface HQContentView : RequestContentView
{
    UILabel* titleLabel_;
    UILabel* newestLabel_;
    UILabel* changeRateLabel_;
    UILabel* changeValueLabel_;
    UILabel* loadingLabel_;
}

- (id)initWithFrame:(CGRect)frame kDic:(NSDictionary*)dic;

@end
