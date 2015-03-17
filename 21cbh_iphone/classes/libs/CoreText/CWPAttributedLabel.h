//
//  CWPAttributedLabel.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "OHAttributedLabel.h"

@interface CWPAttributedLabel : OHAttributedLabel
{
    NSMutableArray* images_;//Coretext中空出的绘制图片的空格的位置，大小等属性
    NSMutableArray* imgInfoDicArray_;
}

-(void)setAttString:(NSAttributedString *)string withImages:(NSMutableArray*)imgs;

@end
