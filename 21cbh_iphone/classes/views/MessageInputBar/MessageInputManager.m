//
//  FaceManager.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MessageInputManager.h"

static MessageInputManager* sharedInstance_=nil;

@implementation MessageInputManager

+(MessageInputManager *)sharedInstance
{
    @synchronized(self){
        if(sharedInstance_ == nil){
           sharedInstance_ = [[MessageInputManager alloc] init];
        }
    }
    return sharedInstance_;
}

-(void)initFaceWithFrame:(CGRect)frame superView:(const UIView*)superView delegate:(id<FaceViewDelegate>)delegate
{
    if(!faceView_)
    {
        faceView_=[[FaceView alloc]initWithFrame:frame];
    }
    else
    {
        faceView_.frame=frame;
    }
    faceView_.delegate=delegate;
    [superView addSubview:faceView_];
}

-(void)initMoreMenuWithFrame:(CGRect)frame superView:(const UIView *)superView delegate:(id<MoreMenuViewDelegate>)delegate
{
    if(!moreMenuView_)
    {
        moreMenuView_=[[MoreMenuView alloc]initWithFrame:frame];
        MoreMenuItem *sharePicItem = [[MoreMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"pic_icon"]
                                                                                                title:@"照片"];
        MoreMenuItem *shareVideoItem = [[MoreMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"photo_icon"]
                                                                                                  title:@"拍照"];
        MoreMenuItem *shareLocItem = [[MoreMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"gupiao_icon"]
                                                                                                title:@"股票"];
        MoreMenuItem *shareVoipItem = [[MoreMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"news_icon"]
                                                                                                 title:@"资讯"];
        moreMenuView_.moreMenuItems = [NSArray arrayWithObjects:sharePicItem,shareVideoItem,shareLocItem,shareVoipItem, nil];
        [moreMenuView_ reloadData];
    }
    else
    {
        moreMenuView_.frame=frame;
    }
    moreMenuView_.delegate=delegate;
    [superView addSubview:moreMenuView_];
}

-(NSString *)emjioForKey:(NSString *)key
{
    if(faceView_&&faceView_.faceDictionary)
    {
        return [faceView_.faceDictionary objectForKey:key];
    }
    return nil;
}

-(void)updateFaceViewFrame:(CGRect)frame
{
    if(faceView_)
    {
        faceView_.hidden=NO;
        faceView_.frame=frame;
    }
}

-(void)updateMoreMenuViewFrame:(CGRect)frame
{
    if(moreMenuView_)
    {
        moreMenuView_.hidden=NO;
        moreMenuView_.frame=frame;
    }
}

-(void)clearDelegate
{
    faceView_.delegate=nil;
    moreMenuView_.delegate=nil;
}

@end
