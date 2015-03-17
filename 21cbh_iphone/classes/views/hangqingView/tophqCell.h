//
//  tophqCell.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "basehqCell.h"
#import "zhongheViewController.h"
@interface tophqCell : basehqCell
{
    UIButton *one;
    UIButton *tow;
    UIButton *three;
    UIImage *_stateImage;
    
}


// 更新数据
-(void)updateCell;
@end
