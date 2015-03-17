//
//  DownLoadViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-5.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface DownLoadViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

-(id)initWithVoiceList:(NSMutableArray *)array;


@end
