//
//  AdBarView.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "AdBarView.h"
#import "UIImageView+WebCache.h"

#define kAdBarViewHeight 40

@interface AdBarView(){
    UIImageView *_imageView;
    NSString *_picUrl;
}

@end


@implementation AdBarView

- (id)initWithPicUrl:(NSString *)picUrl location_y:(CGFloat)location_y
{
    self = [super init];
    
    if (self) {
        UIScreen *MainScreen = [UIScreen mainScreen];
        CGSize size = [MainScreen bounds].size;
        CGRect frame=CGRectMake(0, location_y, size.width, kAdBarViewHeight);
        self.frame=frame;
        self.hidden=YES;
        self.backgroundColor=[UIColor clearColor];
        _picUrl=picUrl;
        //广告图片
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, kAdBarViewHeight)];
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
        _imageView=imageView;
        
        //取消按钮
        UIImage *img1=[UIImage imageNamed:@"ad_delete_btn"];
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-40, (self.frame.size.height-40)*0.5f, 40, 40)];
        [btn setImage:img1 forState:UIControlStateNormal];
        [btn setImage:img1 forState:UIControlStateHighlighted];
        [self addSubview:btn];
        [btn addTarget:self action:@selector(tapBtn) forControlEvents:UIControlEventTouchUpInside];
                
    }
    return self;
}

#pragma mark 设置广告图片
-(void)adBarSetPic{
    NSURL *url=[NSURL URLWithString:_picUrl];
    
    __block AdBarView *view=self;
        [_imageView setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            NSLog(@"执行了广告栏的图片加载");
            if (image) {
                view.hidden=NO;
                if (view.delegate&&[view.delegate respondsToSelector:@selector(finishImage)]) {
                    
                    [view.delegate finishImage];
                    
                }
            }
        }];
}


-(void)ivDidLoad{
    
}

-(void)tapImage:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(clickImage)]) {
        [self.delegate clickImage];
    }
    //[self removeFromSuperview];
}

-(void)tapBtn{
    
    if ([self.delegate respondsToSelector:@selector(clickBtn)]) {
        [self.delegate clickBtn];
    }
    [self removeFromSuperview];
}

@end
