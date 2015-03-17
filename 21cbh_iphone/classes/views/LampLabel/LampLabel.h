//
//  Lamp.h
//  Player
//
//  Created by qinghua on 14-12-18.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LampLabel : UILabel{
    
    float motionWidth;
}
@property (nonatomic)   float motionWidth;
-(void)stopAnimation;
-(void)startAnimation;

@end
