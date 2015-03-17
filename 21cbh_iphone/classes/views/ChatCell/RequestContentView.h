//
//  RequestContentView.h
//  21cbh_iphone
//
//  Created by Franky on 14-7-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@class RequestContentView;
@protocol RequestContentDelegate<NSObject>
@required
-(void)requestFinish:(RequestContentView*)requestView userInfo:(NSDictionary*)dic;

@end

@interface RequestContentView : UIView
{
    ASIHTTPRequest* currentRequest;
}

@property (nonatomic,assign) id<RequestContentDelegate> delegate;

#pragma 开始数据请求
-(void)startRequest;
#pragma 清空数据
-(void)cancelAndClean;

@end
