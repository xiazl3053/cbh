//
//  MoreView.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreMenuItem.h"

@protocol MoreMenuViewDelegate <NSObject>

@optional
- (void)didSelecteMenuItem:(MoreMenuItem *)shareMenuItem atIndex:(NSInteger)index;

@end

@interface MoreMenuView : UIView

@property (nonatomic, strong) NSArray* moreMenuItems;

@property (nonatomic, weak) id<MoreMenuViewDelegate> delegate;

- (void)reloadData;

@end
