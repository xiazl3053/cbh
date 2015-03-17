//
//  MainEngine.h
//  21cbh_iphone
//
//  Created by Franky on 14-5-7.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushNotificationHandler.h"

@interface MainEngine : NSObject<PushNotificationHandlerDelegate>

-(id)initWithMain:(UIViewController*)viewController;

@end
