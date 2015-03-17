//
//  PushCenterViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"
#import "TopBar.h"

@interface PushCenterViewController : BaseViewController<TopBarDelegate>

#pragma mark (0:资讯推送  1:行情推送)
-(id)initWithCurrentIndex:(int)currentIndex;

@end
