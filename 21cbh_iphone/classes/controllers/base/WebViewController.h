//
//  MoreListWebViewController.h
//  customer
//
//  Created by 周晓 on 13-8-23.
//  Copyright (c) 2013年 yuyin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AdDetaiModel.h"

@interface WebViewController : BaseViewController<UIWebViewDelegate,UIActionSheetDelegate>
@property(copy,nonatomic)NSString *adId;
@property(copy,nonatomic)NSString *type;
@property(copy,nonatomic)NSString *url;
@property(strong,nonatomic)AdDetaiModel *adtm;

-(id)initWithAdId:(NSString *)adId type:(NSString *)type url:(NSString *)url;
-(id)initWithUrl:(NSString*)url;

#pragma mark 获取广告详情数据后的处理
-(void)getAdDetailHandle:(AdDetaiModel *)adtm;

@end

