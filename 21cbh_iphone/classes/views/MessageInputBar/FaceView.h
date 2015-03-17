//
//  FaceView.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FaceView;
@protocol FaceViewDelegate<NSObject>

-(void)itemClickEvent:(NSString*)content;
-(void)deleteClickEvent;
-(void)sendClickEvent;
@end

@interface FaceView : UIView<UIScrollViewDelegate>
{
    NSDictionary* faceDictionary_;
    NSArray* faceNameArray_;
    int pageNum;
    NSString* facePath_;
    
    UIScrollView* scrollView_;
    UIPageControl* pageControl_;
    
    UIButton* sendButton_;
}

@property (nonatomic,retain,readonly) NSDictionary* faceDictionary;
@property (nonatomic,assign) id<FaceViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

@end


