//
//  ContentTableViewCell.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "OHAttributedLabel.h"
#import "NewsContentView.h"
#import "ImageContentView.h"
#import "HQContentView.h"

static const int kImageUL=811;//图片上传Tag
static const int kImageDL=812;//图片下载Tag
static const int kHQDL=813;//行情下载Tag

@interface ChatTableViewCell()<OHAttributedLabelDelegate,RequestContentDelegate>
{
    UIImageView* headImageView_;
    UIImageView* contentBgImageView_;
    UIActivityIndicatorView* loadView_;
    UIButton* timeout_;
    UILabel* systemLabel_;
    UILabel* userNameLabel_;
    NewsContentView* newsView_;
    RequestContentView* requestContentView_;
    OHAttributedLabel* contentLabel_;
}

@end

@implementation ChatTableViewCell

@synthesize delegate=delegate_;

+(int)currentCellHeight:(MessageItemAdaptor *)adaptor
{
    return adaptor.height+(adaptor.isHideTime?0:KTopMargin);
}

//过滤表情字符
+ (NSString *)replaceFaceText:(NSString *)text
{
    NSMutableString* retString = [[NSMutableString alloc] initWithString:text];
    return retString;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImageView_=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        UITapGestureRecognizer* tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(UserImageClick:)];
        headImageView_.userInteractionEnabled=YES;
        [headImageView_ addGestureRecognizer:tap];
        [self.contentView addSubview:headImageView_];
        
        userNameLabel_=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 20)];
        userNameLabel_.textColor=[UIColor whiteColor];
        userNameLabel_.font=[UIFont systemFontOfSize:12];
        userNameLabel_.textAlignment=NSTextAlignmentCenter;
        
        contentBgImageView_=[[UIImageView alloc]initWithFrame:CGRectZero];
        contentBgImageView_.userInteractionEnabled=YES;
        UITapGestureRecognizer* tapRecognizer =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [contentBgImageView_ addGestureRecognizer:tapRecognizer];
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [contentBgImageView_ addGestureRecognizer:longPressRecognizer];
        [self.contentView addSubview:contentBgImageView_];
        
        contentLabel_ = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
        contentLabel_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        contentLabel_.centerVertically = YES;
        contentLabel_.automaticallyAddLinksForType = 0;//NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber;
        contentLabel_.onlyCatchTouchesOnLinks=NO;
        contentLabel_.delegate = self;
        [self.contentView addSubview:contentLabel_];
        
        loadView_=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        timeout_=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeout_icon.png"]];
        loadView_.color=[UIColor grayColor];
        timeout_=[UIButton buttonWithType:UIButtonTypeCustom];
        [timeout_ setBackgroundImage:[UIImage imageNamed:@"timeout_icon.png"] forState:UIControlStateNormal];
        [timeout_ addTarget:self action:@selector(TimeOutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)fillWithData:(MessageItemAdaptor*)adaptor
{
    [super fillWithData:adaptor];
    
    if(adaptor_.isSys)
    {
        systemLabel_=[[UILabel alloc]init];
        systemLabel_.textColor=[UIColor whiteColor];
        systemLabel_.font=[UIFont systemFontOfSize:14];
        systemLabel_.textAlignment=NSTextAlignmentCenter;
        systemLabel_.numberOfLines=0;
        systemLabel_.lineBreakMode=NSLineBreakByWordWrapping|NSLineBreakByCharWrapping;
        //systemLabel_.backgroundColor=UIColorFromRGB(0x262626);
        systemLabel_.layer.cornerRadius=5;
        systemLabel_.layer.backgroundColor=[UIColor grayColor].CGColor;//UIColorFromRGB(0x262626).CGColor;
        systemLabel_.alpha=0.5;
        systemLabel_.text=adaptor_.msgContent;
        [self.contentView addSubview:systemLabel_];
        return;
    }
    CGSize contentSize=adaptor_.contentSize;
    if(adaptor_.msgType==TextMessage)
    {
        contentLabel_.attributedText=adaptor_.currentContentAttributedString;
        if(adaptor_.emjios.count>0)
        {
            [contentLabel_ setImages:adaptor_.emjios];
        }
    }
    else if(adaptor_.msgType==ImageMessgae)
    {
        if(!requestContentView_){
            if(adaptor_.picUrls)
            {
                if(adaptor_.isSelf)
                {
                    NSString* url;
                    NSDictionary* imgDic=[adaptor_.picUrls objectForKey:DSelfUpLoadImg];
                    if(imgDic){
                        url=[imgDic objectForKey:@"url"];
                    }
                    requestContentView_=[[ImageContentView alloc] initUpLoadWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)
                                                                       imageUrl:url];
                    requestContentView_.tag=kImageUL;
                    requestContentView_.delegate=self;
                    [contentBgImageView_ addSubview:requestContentView_];
                    if(!adaptor_.isSend&&url){
                        [requestContentView_ startRequest];
                    }
                }
                else
                {
                    requestContentView_=[[ImageContentView alloc] initDownLoadWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)
                                                                       imageDic:adaptor_.picUrls];
                    requestContentView_.tag=kImageDL;
                    requestContentView_.delegate=self;
                    [contentBgImageView_ addSubview:requestContentView_];
                    [requestContentView_ startRequest];
                }
            }
        }
        
    }
    else if (adaptor_.msgType==NewsMessage||adaptor_.msgType==SpecialMessage||adaptor_.msgType==PicsMessage)
    {
        if(!newsView_){
            newsView_=[[NewsContentView alloc]initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
            [contentBgImageView_ addSubview:newsView_];
        }
        NewListModel* model=[[NewListModel alloc]init];
        model.title=adaptor_.msgContent;
        model.desc=adaptor_.description;
        if(adaptor_.picUrls)
        {
            model.picUrls=[adaptor_.picUrls objectForKey:DNewsLogoImg];
        }
        [newsView_ fillWithData:model];
    }
    else if (adaptor_.msgType==HQMessage)
    {
        if(!requestContentView_)
        {
            NSDictionary* dic=[adaptor_ getCurrentIdDic];
            requestContentView_=[[HQContentView alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height) kDic:dic];
            requestContentView_.tag=kHQDL;
            requestContentView_.delegate=self;
            [contentBgImageView_ addSubview:requestContentView_];
            [requestContentView_ startRequest];
        }
    }
    
    if(adaptor_.isSelf)
    {
        contentBgImageView_.image=[[UIImage imageNamed:@"message_bg_self.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:25];
        
        if(adaptor_.isTimeOut)
        {
            [self.contentView addSubview:timeout_];
        }
        else if(!adaptor_.isSend)
        {
            [self.contentView addSubview:loadView_];
            [self updateStauts:adaptor_.isSend];
        }
    }
    else
    {
        headImageView_.hidden=NO;
        [headImageView_ setImageWithURL:[NSURL URLWithString:adaptor_.headUrl] placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        contentBgImageView_.image=[[UIImage imageNamed:@"message_bg_other.png"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        if(adaptor_.isGroup)
        {
            userNameLabel_.text=adaptor_.userName;
            [self.contentView addSubview:userNameLabel_];
        }
    }
}

-(void)updateStauts:(BOOL)hidden
{
    if(loadView_){
        hidden?[loadView_ stopAnimating]:[loadView_ startAnimating];
        loadView_.hidden=hidden;
    }
}

-(void)cleanData
{
    [super cleanData];
    adaptor_=nil;
    if (systemLabel_) {
        [systemLabel_ removeFromSuperview];
        systemLabel_=nil;
    }
    headImageView_.hidden=YES;
    contentLabel_.attributedText=nil;
    contentBgImageView_.image=nil;
    if(requestContentView_){
        [requestContentView_ cancelAndClean];
        [requestContentView_ removeFromSuperview];
        requestContentView_=nil;
    }
    if(userNameLabel_){
        [userNameLabel_ removeFromSuperview];
    }
    if(loadView_){
        [loadView_ removeFromSuperview];
    }
    if(timeout_){
        [timeout_ removeFromSuperview];
    }
    if(newsView_){
        [newsView_ removeFromSuperview];
        newsView_=nil;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL isSystem=adaptor_.isSys;
    BOOL isSelf=adaptor_.isSelf;
    
    CGPoint point=CGPointZero;
    point.y=adaptor_.isHideTime?0:KTopMargin;
    CGSize contentSize=adaptor_.contentSize;
    
    int nameMargin=adaptor_.isGroup?20:0;
    
    if (isSystem)
    {
//        [systemLabel_ sizeToFit];
//        systemLabel_.frame=CGRectMake((320-systemLabel_.width-10)/2, point.y+10, systemLabel_.width+10, 25);
        systemLabel_.frame=CGRectMake((320-contentSize.width-10)/2, point.y+10, contentSize.width+10, contentSize.height+5);
        return;
    }
    
    if(adaptor_.msgType==TextMessage)
    {
        if(isSelf)
        {
            point.x=self.frame.size.width-contentSize.width;
            contentLabel_.frame=CGRectMake(point.x-18, point.y+10+10, contentSize.width, contentSize.height);
            contentBgImageView_.frame=CGRectMake(point.x-30, point.y+10, contentSize.width+28, contentSize.height+20);
            point.x-=60;
        }
        else
        {
            point.x=5;
            contentLabel_.frame=CGRectMake(point.x+59, point.y+10+10+nameMargin, contentSize.width, contentSize.height);
            contentBgImageView_.frame=CGRectMake(point.x+42, point.y+10+nameMargin, contentSize.width+28, contentSize.height+20);
        }
    }
    else if(adaptor_.msgType==ImageMessgae)
    {
        if(isSelf)
        {
            point.x=self.frame.size.width-contentSize.width-10;
            requestContentView_.frame=CGRectMake(1, 1, contentSize.width, contentSize.height);
            contentBgImageView_.frame=CGRectMake(point.x, point.y+10, contentSize.width+8, contentSize.height+2);
            point.x-=30;
        }
        else
        {
            point.x=5;
            requestContentView_.frame=CGRectMake(7, 1, contentSize.width, contentSize.height);
            contentBgImageView_.frame=CGRectMake(point.x+42, point.y+10+nameMargin, contentSize.width+8, contentSize.height+2);
        }
    }
    else if (adaptor_.msgType==NewsMessage||adaptor_.msgType==SpecialMessage||adaptor_.msgType==PicsMessage)
    {
        if(isSelf)
        {
            point.x=self.frame.size.width-adaptor_.width;
            newsView_.frame=CGRectMake(1, 1, contentSize.width, contentSize.height);
            contentBgImageView_.frame=CGRectMake(point.x, point.y+10, contentSize.width+8, contentSize.height+2);
            point.x-=30;
        }
        else
        {
            point.x=5;
            newsView_.frame=CGRectMake(7, 1, contentSize.width, contentSize.height);
            contentBgImageView_.frame=CGRectMake(point.x+42, point.y+10+nameMargin, contentSize.width+8, contentSize.height+2);
        }
    }
    else if (adaptor_.msgType==HQMessage)
    {
        if(isSelf)
        {
            point.x=self.frame.size.width-adaptor_.width;
            requestContentView_.frame=CGRectMake(1, 1, contentSize.width, contentSize.height);
            contentBgImageView_.frame=CGRectMake(point.x, point.y+10, contentSize.width+8, contentSize.height+2);
            point.x-=30;
        }
        else
        {
            point.x=5;
            requestContentView_.frame=CGRectMake(7, 1, contentSize.width, contentSize.height);
            contentBgImageView_.frame=CGRectMake(point.x+42, point.y+10+nameMargin, contentSize.width+8, contentSize.height+2);
        }
    }
    
    if(isSelf)
    {
        loadView_.frame=CGRectMake(point.x, CGRectGetMidY(contentBgImageView_.frame)-10, 20, 20);
        timeout_.frame=CGRectMake(point.x, CGRectGetMidY(contentBgImageView_.frame)-10, 20, 20);
    }
    else
    {
        headImageView_.frame=CGRectMake(point.x, point.y+10, 40, 40);
        if(adaptor_.isGroup)
        {
            [userNameLabel_ sizeToFit];
            CGRect rect=userNameLabel_.frame;
            rect.origin.x=point.x+45;
            rect.origin.y=point.y+10;
            userNameLabel_.frame=rect;
        }
    }
}

//-(BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//
//-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    if(action==@selector(copyAction:)||action==@selector(deleteAction:))
//    {
//        return YES;
//    }
//    return NO;
//}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
//        CGPoint point=[recognizer locationInView:self];
//        if(delegate_&&[delegate_ respondsToSelector:@selector(didLongPress:cellRect:showPoint:)])
//        {
//            [delegate_ didLongPress:adaptor_ cellRect:self.frame showPoint:CGPointMake(contentBgImageView_.center.x, point.y)];
//        }
        //[self becomeFirstResponder];
//        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制"action:@selector(copyAction:)];
//        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(deleteAction:)];
//        UIMenuController *menu = [UIMenuController sharedMenuController];
//        [menu setMenuItems:[NSArray arrayWithObjects:copy, delete, nil]];
//        [menu setTargetRect:contentBgImageView_.frame inView:self];
//        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)copyAction:(id)sender
{
    if(delegate_&&[delegate_ respondsToSelector:@selector(didCopyMsg:)])
    {
        [delegate_ didCopyMsg:adaptor_];
    }
}

- (void)deleteAction:(id)sender
{
    if(delegate_&&[delegate_ respondsToSelector:@selector(didDeleteMsg:)])
    {
        [delegate_ didDeleteMsg:adaptor_];
    }
}

-(void)handleTap:(UITapGestureRecognizer*)recognizer
{
    if(adaptor_.msgType==ImageMessgae)
    {
        if(delegate_&&[delegate_ respondsToSelector:@selector(didClickedMsgImage:)])
        {
            [delegate_ didClickedMsgImage:adaptor_];
        }
    }
    else if(adaptor_.msgType==NewsMessage||adaptor_.msgType==SpecialMessage||adaptor_.msgType==PicsMessage)
    {
        NSDictionary* dic=[adaptor_ getCurrentIdDic];
        NSString* pId=[dic objectForKey:mProgramId];
        NSString* aId=[dic objectForKey:mArticleId];
        if(delegate_&&[delegate_ respondsToSelector:@selector(didClickedNews:articleId:type:)])
        {
            [delegate_ didClickedNews:pId articleId:aId type:adaptor_.msgType];
        }
    }
    else if (adaptor_.msgType==HQMessage)
    {
        NSDictionary* dic=[adaptor_ getCurrentIdDic];
        NSString* kId=[dic objectForKey:@"marketId"];
        NSString* kType=[dic objectForKey:@"KType"];
        if(delegate_&&[delegate_ respondsToSelector:@selector(didClickedHQ:kType:)])
        {
            [delegate_ didClickedHQ:kId kType:kType];
        }
    }
    else
    {
        if(delegate_&&[delegate_ respondsToSelector:@selector(didClickNomarl:)])
        {
            [delegate_ didClickNomarl:adaptor_];
        }
    }
}

-(void)UserImageClick:(id)sender
{
    if(delegate_&&[delegate_ respondsToSelector:@selector(didClickedUserImage:)])
    {
        [delegate_ didClickedUserImage:adaptor_];
    }
}

-(void)TimeOutBtnClick:(id)sender
{
    if(delegate_&&[delegate_ respondsToSelector:@selector(didClickedReSend:)])
    {
        [delegate_ didClickedReSend:adaptor_];
    }
}

#pragma mark - ------------OHAttributedLabelDelegate 的代理方法----------------

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    if(delegate_&&[delegate_ respondsToSelector:@selector(didClickedURL:)])
    {
        [delegate_ didClickedURL:linkInfo];
    }
    return NO;
}

#pragma mark - ------------RequestContentDelegate 的代理方法----------------

-(void)requestFinish:(RequestContentView *)requestView userInfo:(NSDictionary *)dic
{
    int tag=requestView.tag;
    if(tag==kImageUL)
    {
        [adaptor_ updateMessageWithUploadImg:dic finished:^(EMessages *msg) {
            if(delegate_&&[delegate_ respondsToSelector:@selector(didUpLoadImgComplete:)])
            {
                [delegate_ didUpLoadImgComplete:msg];
            }
        }];
    }
    else if (tag==kHQDL)
    {
        [adaptor_ updateMEssageWithHQValue:dic finished:^(EMessages *msg) {
            if(delegate_&&[delegate_ respondsToSelector:@selector(didUpdateHQ:)])
            {
                [delegate_ didUpdateHQ:msg];
            }
        }];
    }
}

@end
