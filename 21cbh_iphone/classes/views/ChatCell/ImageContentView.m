//
//  ImageContentView.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ImageContentView.h"
#import "UIImageView+WebCache.h"
#import "CWPHttpRequest.h"
#import "UIImageView+WebCache.h"

@interface ImageContentView()
{
    NSString* imageUrl_;
    UIImageView* imageView_;
    UIView* grayView_;
    UILabel* perLabel_;
    
    NSDictionary* largeDic_;
    NSDictionary* smallDic_;
    
    BOOL isUpload;
}
@end

@implementation ImageContentView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView_=[[UIImageView alloc] initWithFrame:frame];
        imageView_.contentMode=UIViewContentModeScaleAspectFill;
        imageView_.clipsToBounds=YES;
        [self addSubview:imageView_];
        
        grayView_=[[UIView alloc] initWithFrame:frame];
        grayView_.backgroundColor=[UIColor grayColor];
        grayView_.alpha=0.5;
        grayView_.hidden=YES;
        [self addSubview:grayView_];
        
        perLabel_=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(imageView_.frame)-20,CGRectGetMidY(imageView_.frame)-10, 50, 20)];
        perLabel_.font=[UIFont systemFontOfSize:15];
        perLabel_.textColor=[UIColor blackColor];
        perLabel_.hidden=YES;
        [self addSubview:perLabel_];
    }
    return self;
}

#pragma mark - 接收方获取图片信息调用
- (id)initDownLoadWithFrame:(CGRect)frame imageDic:(NSDictionary*)dic
{
    self = [self initWithFrame:frame];
    if (self) {
        largeDic_=[dic objectForKey:@"pictue_large"];
        smallDic_=[dic objectForKey:@"pictue_small"];
    }
    return self;
}

#pragma mark - 发送方上传图片调用
- (id)initUpLoadWithFrame:(CGRect)frame imageUrl:(NSString*)url
{
    self = [self initWithFrame:frame];
    if (self) {
        isUpload=YES;
        imageUrl_=url;
        imageView_.image=[UIImage imageWithContentsOfFile:imageUrl_];
    }
    return self;
}

-(void)startRequest
{
    if(isUpload)
    {
        if(imageView_.image&&imageUrl_&&imageUrl_.length>0)
        {
            grayView_.hidden=NO;
            perLabel_.hidden=NO;
            __block float sum=0;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                currentRequest=[CWPHttpRequest postPictureRequest:imageUrl_
                                                    progressBlock:^(unsigned long long size, unsigned long long total)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        sum=sum+(float)size;
                                        float num=sum/(float)total*100;
                                        perLabel_.text=[NSString stringWithFormat:@"%0.f%%",num];
                                        NSLog(@"%f/%llu",sum,total);
                                    });
                                }
                                                  completionBlock:^(NSDictionary *dic, BOOL isSuccess)
                                {
                                    if(isSuccess)
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if(self.delegate&&[self.delegate respondsToSelector:@selector(requestFinish:userInfo:)])
                                            {
                                                [self.delegate requestFinish:self userInfo:dic];
                                            }
                                            grayView_.hidden=YES;
                                            perLabel_.hidden=YES;
                                        });
                                    }
                                }];
            });
        }
    }
    else
    {
        NSString* smallUrl=[smallDic_ objectForKey:@"url"];
        
        __weak __block ImageContentView* wself=self;
        [imageView_ setImageWithURL:[NSURL URLWithString:smallUrl] placeholderImage:[UIImage imageNamed:@"newList_defaultPic1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             if(wself.delegate&&[wself.delegate respondsToSelector:@selector(requestFinish:userInfo:)])
             {
                 [wself.delegate requestFinish:wself userInfo:nil];
             }
         }];
    }
}

-(void)dealloc
{
    self.delegate=nil;
    [self cancelAndClean];
}

@end
