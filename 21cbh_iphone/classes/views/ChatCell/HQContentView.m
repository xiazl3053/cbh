//
//  HQContentView.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "HQContentView.h"
#import "CWPHttpRequest.h"
#import "NSDate+Custom.h"

@interface HQContentView()
{
    BOOL isRequesting;
    BOOL isRequested;
    BOOL isLocal;
    NSString* cKId;
    NSString* cKType;
    NSString* cKName;
}

@end

@implementation HQContentView

- (id)initWithFrame:(CGRect)frame kDic:(NSDictionary*)dic
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled=NO;
        self.backgroundColor=UIColorFromRGB(0xf0f0f0);
        
        NSString* timeStr=[dic objectForKey:@"KTime"];
        if(timeStr)
        {
            NSDate* time=[NSDate dateWithDateString:timeStr];
            NSTimeInterval interval=abs([time timeIntervalSinceDate:[NSDate date]]);
            if(interval<600)
            {
                isLocal=YES;
            }
        }
        
        cKId=[dic objectForKey:@"marketId"];
        cKType=[dic objectForKey:@"KType"];
        cKName=[dic objectForKey:@"marketName"];
        
        loadingLabel_=[[UILabel alloc] initWithFrame:CGRectMake(40, 35, 150, 30)];
        loadingLabel_.font=[UIFont systemFontOfSize:18];
        loadingLabel_.textColor=UIColorFromRGB(808080);
        loadingLabel_.backgroundColor=[UIColor clearColor];
        loadingLabel_.text=@"正在获取最新信息..";
        [self addSubview:loadingLabel_];
        
        titleLabel_=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, frame.size.width-10, 30)];
        titleLabel_.lineBreakMode=NSLineBreakByWordWrapping;
        titleLabel_.numberOfLines=2;
        titleLabel_.textAlignment = NSTextAlignmentLeft;
        titleLabel_.font=[UIFont systemFontOfSize:20];
        titleLabel_.textColor=[UIColor blackColor];
        titleLabel_.backgroundColor=[UIColor clearColor];
        NSString* title=[NSString stringWithFormat:@"%@(%@)",cKName,cKId];
        titleLabel_.text=title;
        [self addSubview:titleLabel_];
        
        newestLabel_=[[UILabel alloc] initWithFrame:CGRectMake(50, 35, 80, 30)];
        newestLabel_.font=[UIFont systemFontOfSize:22];
        newestLabel_.textColor=[UIColor redColor];
        newestLabel_.backgroundColor=[UIColor clearColor];
        [self addSubview:newestLabel_];
        
        changeRateLabel_=[[UILabel alloc] initWithFrame:CGRectMake(50, 70, 50, 20)];
        changeRateLabel_.font=[UIFont systemFontOfSize:14];
        changeRateLabel_.textColor=[UIColor greenColor];
        changeRateLabel_.backgroundColor=[UIColor clearColor];
        [self addSubview:changeRateLabel_];
        
        changeValueLabel_=[[UILabel alloc] initWithFrame:CGRectMake(100, 70, 50, 20)];
        changeValueLabel_.font=[UIFont systemFontOfSize:14];
        changeValueLabel_.textColor=[UIColor greenColor];
        changeValueLabel_.backgroundColor=[UIColor clearColor];
        [self addSubview:changeValueLabel_];
        
        if(isLocal)
        {
            isRequested=YES;
            newestLabel_.text=[dic objectForKey:@"newestValue"];
            changeRateLabel_.text=[dic objectForKey:@"changeRate"];
            changeValueLabel_.text=[dic objectForKey:@"changeValue"];
            loadingLabel_.hidden=YES;
        }
        
        UIImageView* imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_market.png"]];
        imageView.frame=CGRectMake(10, 40, 25, 25);
        [self addSubview:imageView];
    }
    return self;
}

-(void)startRequest
{
    if(!isRequesting&&!isRequested&&cKId&&cKType&&!isLocal)
    {
        isRequesting=YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            currentRequest=[CWPHttpRequest postStockInformationRequest:cKId markType:cKType completionBlock:^(NSDictionary *dic, BOOL isSuccess) {
                if(isSuccess)
                {
                    NSMutableDictionary* newDic=[NSMutableDictionary dictionaryWithDictionary:dic];
                    [newDic setObject:[NSDate currentDateTimeString] forKey:@"KTime"];
                    [newDic setObject:cKType forKey:@"KType"];
                    if(self.delegate&&[self.delegate respondsToSelector:@selector(requestFinish:userInfo:)])
                    {
                        [self.delegate requestFinish:self userInfo:newDic];
                    }
                    isRequested=YES;
                    titleLabel_.text=[dic objectForKey:@"marketName"];
                    newestLabel_.text=[dic objectForKey:@"newestValue"];
                    changeRateLabel_.text=[dic objectForKey:@"changeRate"];
                    changeValueLabel_.text=[dic objectForKey:@"changeValue"];
                    loadingLabel_.hidden=YES;
                }
                isRequesting=NO;
            }];
        
        });
    }
}

-(void)dealloc
{
    [self cancelAndClean];
}

@end
