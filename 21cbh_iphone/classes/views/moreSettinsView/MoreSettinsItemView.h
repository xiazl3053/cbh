//
//  MoreSettinsItemView.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MoreSettinsItemViewDelegate;

@interface MoreSettinsItemView : UIView

@property(assign,nonatomic)id<MoreSettinsItemViewDelegate>delegate;

- (id)initWithArray:(NSMutableArray *)array;

@property(assign,nonatomic)BOOL canResponse;
@property(weak,nonatomic)UIImageView *inTag;//进入标志
@property(assign,nonatomic)UIView *line;

@end


@protocol MoreSettinsItemViewDelegate <NSObject>

-(void)clickMoreSettinsItem:(MoreSettinsItemView *)msiv;

@end