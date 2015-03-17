//
//  ListHearderView.h
//  QQListTest
//
//  Created by 周晓 on 14-1-3.
//  Copyright (c) 2014年 shenjx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  ListHearderViewDelegate;
@interface ListHearderView : UIView
@property(assign,nonatomic)bool canDo;//如果点下去滑动就不响应点击事件
@property (nonatomic, assign) id<ListHearderViewDelegate> delegate;
@end

@protocol ListHearderViewDelegate <NSObject>
- (void)clickListHearderView:(ListHearderView *)view;
@end