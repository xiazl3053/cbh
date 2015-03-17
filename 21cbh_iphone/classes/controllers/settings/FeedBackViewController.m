//
//  FeedBackViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "FeedBackViewController.h"
#import "PingLunHttpRequest.h"
#import "NoticeOperation.h"
#import "NCMConstant.h"
#import "NSString+strlength.h"

#define kMarginWidth 15
#define kTextHeight 140
#define kComentContentLength 3



@interface FeedBackViewController (){

    UIView *_top;
    UILabel *_placeHolder;
    UITextView *_feedBack;
    UIButton *_submit;
    UIView *_separator;
}

@end

@implementation FeedBackViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
}

#pragma mark -初始化Views
-(void)initViews{
    [self initNavigationBar];
    [self initTextView];
    [self initStyle];
}
#pragma mark -初始化initNavigationBar
-(void)initNavigationBar{
    UIView *top=[self Title:@"意见反馈" returnType:1];
    _top=top;
    
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(240, 8, 66, 28)];
    //[btn setTitle:@"发送" forState:UIControlStateNormal];
    //[btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
//    [btn setImage:[UIImage imageNamed:@"FeedBack_Done_normal.png"] forState:UIControlStateNormal];
//    [btn setImage:[UIImage imageNamed:@"FeedBack_Done_hlight.png"] forState:UIControlStateHighlighted];
    
    [btn setTitle:@"发送" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:kFontName size:KBtnFontSize]];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self action:@selector(submitfeedbackInfo:) forControlEvents:UIControlEventTouchUpInside];
    _submit=btn;
    
    [top addSubview:btn];

}

#pragma mark -style
-(void)initStyle{
    switch (KAppStyle) {
        case APPSTYLE_TYPE_WHITE:{
            self.view.backgroundColor=KBgWitheColor;
            [_submit setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
            [_submit setTitleColor:KBtnHighlightStateColor forState:UIControlStateHighlighted];
            _submit.layer.borderColor=UIColorFromRGB(0xcccccc).CGColor;
            _submit.layer.borderWidth=1.0f;
            _submit.layer.masksToBounds=YES;
            _submit.backgroundColor=UIColorFromRGB(0xffffff);
            _feedBack.backgroundColor=UIColorFromRGB(0Xffffff);
            _placeHolder.textColor=UIColorFromRGB(0Xacacac);
            [_feedBack setTextColor:UIColorFromRGB(0x000000)];
        }break;
        case APPSTYLE_TYPE_BLACK:{
            self.view.backgroundColor=kBgcolor;
            [_feedBack setTextColor:[UIColor whiteColor]];
        }break;
            
        default:
            break;
    }
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [_feedBack becomeFirstResponder];
}

#pragma mark -初始化initTextView
-(void)initTextView{

    UITextView *feedBack=[[UITextView alloc]initWithFrame:CGRectMake(kMarginWidth, _top.frame.origin.y+_top.frame.size.height+15, self.view.frame.size.width-kMarginWidth*2, kTextHeight)];
    feedBack.delegate=self;
    feedBack.font=[UIFont fontWithName:kFontName size:KFeedBackTextViewTextFontSize];
     _feedBack=feedBack;
    
    UILabel *placeHolder=[[UILabel alloc]initWithFrame:CGRectMake(5, 5, 200, 20)];
    placeHolder.text=@"请输入您的宝贵意见";
    [placeHolder setBackgroundColor:[UIColor clearColor]];
    placeHolder.font=[UIFont fontWithName:kFontName size:KFeedbackPlaceholderLabelFontSize];
    [feedBack addSubview:placeHolder];
    _placeHolder=placeHolder;
    [self.view addSubview:feedBack];
}
#pragma mark TextView代理方法
-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length>0) {
        _placeHolder.hidden=YES;
    }else{
        _placeHolder.hidden=NO;
    }
    if ([NSString convertToInt:_feedBack.text]>=kComentContentLength) {
         [_submit setHighlighted:YES];
    }else{
        [_submit setHighlighted:NO];
    }

}
#pragma mark -数据回调
-(void)feedBackSubmitInfoBack:(NSDictionary *)dic isSuccess:(BOOL)success{
     NoticeOperation *notice=[[NoticeOperation alloc]init];
    if (success) {
        if ([[dic objectForKey:@"result"]integerValue]==0) {
            NSLog(@"dic===%@",dic);
            //_feedBack.text=@"";
            [_feedBack resignFirstResponder];
            [notice showAlertWithMsg:KNoticeFeedbackSuccessTitle imageName:KNoticeFeedBackSuccessIcon toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
            [self performSelector:@selector(popVc) withObject:self afterDelay:2];
            
        }else{
            NSLog(@"dic===%@",dic);
            [notice showAlertWithMsg:[NSString stringWithFormat:@"%@",[dic objectForKey:@"resultInfo"]] imageName:nil toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        }
    }else{
        [notice showAlertWithMsg:KNoticeFeedbackFailTitle imageName:KNoticeFeedbackFailIcon toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        [_submit setHighlighted:YES];
    }
}
#pragma mark -提交反馈信息
-(void)submitfeedbackInfo:(UIButton *)btn{
    if ([NSString convertToInt:_feedBack.text]>=kComentContentLength) {
        PingLunHttpRequest *sumbit=[[PingLunHttpRequest alloc]init];
        [sumbit sendUserFeedBack:self andContent:_feedBack.text];
    }else{
         NoticeOperation *notice=[[NoticeOperation alloc]init];
     [notice showAlertWithMsg:KNoticeContentLengthFailTitle imageName:KNoticeContentLengthFailIcon toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
    }
}


#pragma mark -跳出控制器
-(void)popVc{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -delloc
-(void)dealloc{
    NSLog(@"----------Feedback-------Delloc");
    _top=nil;
    _placeHolder=nil;
    _submit=nil;
    _feedBack=nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
