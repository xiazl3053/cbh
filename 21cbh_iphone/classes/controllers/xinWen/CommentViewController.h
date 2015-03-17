//
//  CommentViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsDetailViewController.h"

@protocol commentViewContorllerDelegate <NSObject>

-(void)sendSuccessWithContent:(NSString *)content andUserLocaton:(NSString *)userLocaton;

@end

@interface CommentViewController : BaseViewController<UITextViewDelegate>

@property(weak,nonatomic)NewsDetailViewController *ndv;
@property(nonatomic,weak)id<commentViewContorllerDelegate> delegate;

-(id)initWithProgarmID:(NSString *)progarm andArticleID:(NSString *)article andPicsID:(NSString *)pics andFollowID:(NSString *)follow;

-(void)getCommmentFollowInfo:(NSDictionary *)dic isSuccess:(BOOL)b;
@end
