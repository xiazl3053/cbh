//
//  CWPCycleView.h
//  21cbh_iphone
//
//  Created by Franky on 14-4-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopPicModel.h"

@interface CWPCycleView : UIView

-(void)fillDataWithModel:(TopPicModel*)model;
-(void)cleanData;

@end
