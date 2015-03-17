//
//  MainViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ZXTabbarDelegate;
@protocol MainDelegate;
@protocol PlayerToolProtocol;

@interface MainViewController : UIViewController<ZXTabbarDelegate,PlayerToolProtocol>

@property(strong,nonatomic) NSOperationQueue *dbQueue;//数据库操作队列

@property(assign,nonatomic)id<MainDelegate>delegate;

#pragma mark 新闻快讯接口请求处理
-(void)getNewsFlashHandle:(NSMutableArray *)nfms;

@end

@protocol MainDelegate <NSObject>

- (void)bottomUp:(UIView *)bottom;
- (void)bottomDown:(UIView *)bottom;

@end