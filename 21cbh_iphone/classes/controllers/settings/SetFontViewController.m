//
//  SetFontViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "SetFontViewController.h"

@interface SetFontViewController (){
    NSMutableArray *_array;
    NSMutableArray *_views;
}

@end

@implementation SetFontViewController


- (void)viewDidLoad
{
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    _views=[NSMutableArray array];
    
    _array=[NSMutableArray array];
    NSMutableDictionary *dc1=[NSMutableDictionary dictionary];
    [dc1 setValue:@"小号字体" forKey:@"text"];
    [dc1 setValue:@"15" forKey:@"fontSize"];
    [_array addObject:dc1];
    NSMutableDictionary *dc2=[NSMutableDictionary dictionary];
    [dc2 setValue:@"中号字体" forKey:@"text"];
    [dc2 setValue:@"17" forKey:@"fontSize"];
    [_array addObject:dc2];
    NSMutableDictionary *dc3=[NSMutableDictionary dictionary];
    [dc3 setValue:@"大号字体" forKey:@"text"];
    [dc3 setValue:@"18" forKey:@"fontSize"];
    [_array addObject:dc3];
}

#pragma mark 初始化视图
-(void)initView{
    UIView *top=[self Title:@"字号大小" returnType:1];
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    for (int i=0; i<_array.count; i++) {
        SetFontView *sfv=[[SetFontView alloc] initWithDic:[_array objectAtIndex:i]];
        CGRect frame=sfv.frame;
        frame.origin.y=top.frame.origin.y+top.frame.size.height+sfv.frame.size.height*i;
        sfv.frame=frame;
        sfv.delegate=self;
        sfv.tag=i;
        [self.view addSubview:sfv];
        [_views addObject:sfv];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger fontSize=[[defaults objectForKey:kFontSize] intValue];
    SetFontView *sfv=[_views objectAtIndex:fontSize];
    sfv.iv.hidden=NO;
}

#pragma mark - ----------------SetFontView的代理方法-------------------
-(void)clickSetFontViewItem:(SetFontView *)sfv{
   // NSLog(@"点击了SetFontView");
    for (int i=0; i<_views.count; i++){
        SetFontView *sfv=[_views objectAtIndex:i];
        sfv.iv.hidden=YES;
    }
    
    sfv.iv.hidden=NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sfv.tag forKey:kFontSize];
    // 将数据同步到Preferences文件夹中
    [defaults synchronize];
}

@end
