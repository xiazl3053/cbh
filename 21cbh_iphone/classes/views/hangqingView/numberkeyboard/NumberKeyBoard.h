//
//  NumberKeyBoard.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumberKeyBoardDelegate <NSObject>

- (void) numberKeyBoardInput:(NSString*) buttonVlaue;

@end


@interface NumberKeyBoard : UIView

@property(nonatomic, assign) id<NumberKeyBoardDelegate> delegate;

- (IBAction) keyClick:(id) sender;

@end
