//
//  DNumberKeyBoard.h
//  21cbh_iphone
//
//  Created by 21tech on 14-4-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DNumberKeyBoardDelegate <NSObject>

- (void) numberKeyBoardInput:(NSString*) buttonVlaue;

@end

@interface DNumberKeyBoard : UIView

@property(nonatomic, assign) id<DNumberKeyBoardDelegate> delegate;

- (IBAction) keyClick:(id) sender;

@end
