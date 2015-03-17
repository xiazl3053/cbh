//
//  SetFontView.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetFontViewDelegate;

@interface SetFontView : UIView

@property(assign,nonatomic)id<SetFontViewDelegate>delegate;

- (id)initWithDic:(NSMutableDictionary *)dic;

@property(weak,nonatomic)UIImageView *iv;

@end

@protocol SetFontViewDelegate <NSObject>

-(void)clickSetFontViewItem:(SetFontView *)sfv;

@end