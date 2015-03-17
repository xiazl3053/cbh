//
//  DES3Util.h
//  lx100-gz
//
//  Created by  ¡¯∑Â on 12-10-10.
//  Copyright 2012 http://blog.csdn.net/lyq8479. All rights reserved.
//


#import <Foundation/Foundation.h>




@interface DES3Util : NSObject {
    
    
}



+ (NSString*)encrypt:(NSString*)plainText;



+ (NSString*)decrypt:(NSString*)encryptText;


@end