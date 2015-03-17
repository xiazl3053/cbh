//
//  HeadSettingViewController.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface HeadSettingViewController : BaseViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

-(void)updateHeadImgBackDataWithNSDictionary:(NSDictionary *)dic andSuccess:(BOOL)b;

@end
