//
//  ContentTableViewCell.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CWPTableViewCell.h"

@protocol ChatTableViewCellDelegate;

@interface ChatTableViewCell : CWPTableViewCell

@property (nonatomic, assign) id<ChatTableViewCellDelegate> delegate;
-(void)updateStauts:(BOOL)hidden;

@end

@protocol ChatTableViewCellDelegate <NSObject>
@optional
#pragma mark 图片上传成功后回调
-(void)didUpLoadImgComplete:(EMessages*)msg;
#pragma mark 行情信息下载成功后回调
-(void)didUpdateHQ:(EMessages*)msg;
#pragma mark 图片点击回调
-(void)didClickedMsgImage:(MessageItemAdaptor*)item;
#pragma mark 头像点击回调
-(void)didClickedUserImage:(MessageItemAdaptor*)item;
#pragma mark 新闻点击回调
-(void)didClickedNews:(NSString*)programId articleId:(NSString*)articleId type:(MessageType)type;
#pragma mark 股票点击回调
-(void)didClickedHQ:(NSString*)kId kType:(NSString*)kType;
#pragma mark 重新发送回调
-(void)didClickedReSend:(MessageItemAdaptor*)item;
-(void)didClickNomarl:(MessageItemAdaptor*)item;
#pragma mark cell长按回调
-(void)didLongPress:(MessageItemAdaptor*)item cellRect:(CGRect)rect showPoint:(CGPoint)point;
#pragma 以下备用
-(void)didCopyMsg:(MessageItemAdaptor*)item;
-(void)didDeleteMsg:(MessageItemAdaptor*)item;
-(void)didClickedURL:(NSTextCheckingResult *)linkInfo;
@end