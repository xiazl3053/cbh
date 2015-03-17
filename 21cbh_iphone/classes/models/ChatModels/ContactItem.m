//
//  ContactItem.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-23.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ContactItem.h"
#import "ChineseToPinyin.h"

@interface ContactItem()
{
    NSString* pinyin_;
    NSString* xing_;
}

@end

@implementation ContactItem

@synthesize xing=xing_;
@synthesize pinyin=pinyin_;

-(NSString *)xing
{
    if(!xing_)
    {
        if(self.userName&&self.userName.length>0)
        {
             //xing_=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([self.userName characterAtIndex:0])]uppercaseString];
        }
        else
        {
            xing_=@"";
        }
    }
    return xing_;
}

-(NSString *)pinyin
{
    if(!pinyin_)
    {
        if(self.userName&&self.userName.length>0)
        {
            NSMutableString* pinyinResult=[NSMutableString string];
            for(int j=0;j<self.userName.length;j++)//遍历名字中的每个字
            {
                
//                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([self.userName characterAtIndex:j])]uppercaseString];//取出字中的开头字母并转为大写字母
//                [pinyinResult appendString:singlePinyinLetter];//取出名字的所有字的开头字母
            }
            pinyin_=pinyinResult;
        }
        else
        {
            pinyin_=@"";
        }
    }
    return pinyin_;
}

@end
