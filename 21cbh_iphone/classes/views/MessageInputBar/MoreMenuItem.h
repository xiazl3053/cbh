//
//  MoreMenuItem.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoreMenuItem : NSObject

@property (nonatomic, strong) UIImage *normalIconImage;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title;

@end
