//
//  CommentViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentViewController.h"
#import "CommonOperation.h"
#import "PingLunHttpRequest.h"
#import "OperationAlertView.h"
#import "NCMConstant.h"
#import "NoticeOperation.h"
#import "UserModel.h"
#import "NSString+strlength.h"

#define kContentViewHeight 170
#define kComentContentLength 1

@interface CommentViewController (){
    UIView *_contentView;
    UITextView *_textView;
    UIButton *_yes_btn;
    UIView *_alertView;
    BOOL _isFrist;
    int _progarmID;
    int _articleID;
    int _picsID;
    int _followID;
}

@property (nonatomic,strong) PingLunHttpRequest *request;
@property (nonatomic,strong) NoticeOperation *notice;
@property (nonatomic,strong) CommonOperation *co;

@end

@implementation CommentViewController


-(id)initWithProgarmID:(NSString *)progarm andArticleID:(NSString *)article andPicsID:(NSString *)pics andFollowID:(NSString *)follow{
    
    if (self=[super init]) {
        _progarmID=[progarm integerValue];
        _articleID=[article integerValue];
        _picsID=[pics integerValue];
        _followID=[follow integerValue];
        self.co = [[CommonOperation alloc] init];
        
    }
    
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
    
    [self initAlertView];
    
    [self initNotificationKeyBoard];
}

-(void)viewDidAppear:(BOOL)animated{
     [_textView becomeFirstResponder];
}


-(void)initAlertView{
    self.notice=[[NoticeOperation alloc]init];

}

#pragma mark -注册键盘监听
-(void)initNotificationKeyBoard{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
}

#pragma mark -键盘高度变化
-(void)keyBoardFrameChange:(NSNotification *)info{
    NSDictionary *dic= info.userInfo;
    NSLog(@"%@",dic);
    CGRect rect = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float duration=[[dic objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    int curve=[[dic objectForKey:UIKeyboardAnimationCurveUserInfoKey]intValue];
    CGRect temp=_contentView.frame;
    [UIView setAnimationCurve:curve];
    [UIView animateWithDuration:duration animations:^{
           _contentView.frame=CGRectMake(0, rect.origin.y-kContentViewHeight, temp.size.width, kContentViewHeight);
    }];
}

#pragma mark -键盘弹出
-(void)keyBoardWillShow:(NSNotification *)info{
    NSDictionary *dic= info.userInfo;
    NSLog(@"%@",dic);
    CGRect rect = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"rect=%@",NSStringFromCGRect(rect));
    float duration=[[dic objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    int curve=[[dic objectForKey:UIKeyboardAnimationCurveUserInfoKey]intValue];

    CGRect temp=_contentView.frame;
    [UIView setAnimationCurve:curve];
    [UIView animateWithDuration:duration animations:^{
        _contentView.frame=CGRectMake(0, rect.origin.y-kContentViewHeight, temp.size.width, kContentViewHeight);
    }];

}

//#pragma mark -键盘隐藏
//-(void)keyBoardWillHide:(NSNotification *)info{
//    NSDictionary *dic= info.userInfo;
//    NSLog(@"%@",dic);
//    CGRect temp=_contentView.frame;
//        _contentView.frame=CGRectMake(0, self.view.frame.size.height, temp.size.width, kContentViewHeight);
//}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // 取出set中的那个UItouch对象
    UITouch *touch = [touches anyObject];
    // 获取触摸点在_contentView上的位置
    CGPoint point = [touch locationInView:_contentView];
    CGFloat x=point.x;
    CGFloat y=point.y;
    if (0<x<_contentView.frame.size.width&&y>0) {//点击到了_contentview的区域
        NSLog(@"点击_contentView");
        return;
    }
    
    //退出设置
    [self exitComment:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 初始化变量
-(void)initParams{
    self.request=[[PingLunHttpRequest alloc]init];
    _isFrist=YES;
}
#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    
    UIScreen *screen=[UIScreen mainScreen];
    UIView *contentView=[[UIView alloc]initWithFrame:CGRectMake(0, screen.bounds.size.height, self.view.frame.size.width, kContentViewHeight)];
    contentView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    [self.view addSubview:contentView];
    _contentView=contentView;
    
    UIView *top=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
    [_contentView addSubview:top];
    
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    line.backgroundColor=UIColorFromRGB(0x808080);
    [top addSubview:line];
    
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake((top.frame.size.width-100)*0.5f,0, 100, 40)];
    lable.textAlignment=NSTextAlignmentCenter;
    lable.font=[UIFont fontWithName:kFontName size:KCommentSendViewTitleFontSize];
    lable.textColor=UIColorFromRGB(0x808080);
    lable.text=@"我要评论";
    lable.backgroundColor=[UIColor clearColor];
    [top addSubview:lable];
    
    UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-290)*0.5f, 40, 290, 100)];
    textView.font=[UIFont fontWithName:kFontName size:KCommentSendViewContentFontSize];
    textView.textColor=UIColorFromRGB(0x808080);
    textView.textAlignment=NSTextAlignmentLeft;
//    textFiled.layer.borderWidth = 0.5;
//    textFiled.layer.borderColor=[UIColorFromRGB(0x555555) CGColor];
    textView.delegate=self;
    [top addSubview:textView];
    _textView=textView;
    [_textView becomeFirstResponder];
    [self queryCommentContent];
    
    UIImage *img=[UIImage imageNamed:@"comment_no"];
    UIButton *no_btn=[[UIButton alloc] initWithFrame:CGRectMake(15-img.size.width*0.5f, (40-img.size.height*2)*0.5f, img.size.width*3, img.size.height*2)];
//    [no_btn setImage:img forState:UIControlStateNormal];
//    [no_btn setImage:img forState:UIControlStateHighlighted];
    [no_btn setTitle:@"取消" forState:UIControlStateNormal];
    [no_btn setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];
    [no_btn.titleLabel setFont:[UIFont fontWithName:kFontName size:KBtnFontSize]];
    [no_btn addTarget:self action:@selector(exitComment:) forControlEvents:UIControlEventTouchUpInside];
    no_btn.tag=100;
    [top addSubview:no_btn];
    
    
    img=[UIImage imageNamed:@"comment_yes"];
    UIButton *yes_btn=[[UIButton alloc] initWithFrame:CGRectMake(top.frame.size.width-20-img.size.width*2+img.size.width*0.5f, (40-img.size.height*2)*0.5f, img.size.width*2, img.size.height*2)];
//    [yes_btn setImage:img forState:UIControlStateNormal];
//    [yes_btn setImage:img forState:UIControlStateHighlighted];
    [yes_btn setTitle:@"发送" forState:UIControlStateNormal];
    [yes_btn setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];
    [yes_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateHighlighted];
    [yes_btn.titleLabel setFont:[UIFont fontWithName:kFontName size:KBtnFontSize]];
    [yes_btn addTarget:self action:@selector(exitCommentAndSendComment:) forControlEvents:UIControlEventTouchUpInside];
    yes_btn.tag=101;
    [top addSubview:yes_btn];
    _yes_btn=yes_btn;
    
}

#pragma mark 退出设置
-(void)exitComment:(UIButton *)btn{
    [_textView resignFirstResponder];
    
    [UIView animateWithDuration:0.25f animations:^{//设置面板退下
        CGRect frame=_contentView.frame;
        frame.origin.y+=kContentViewHeight;
        _contentView.frame=frame;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25f animations:^{//界面渐隐
            self.view.alpha=0;
            
        } completion:^(BOOL finished){
            if (btn) {
                switch (btn.tag) {
                    case 101:
                        [self.ndv getComment:_textView.text];
                        break;
                        
                    default:
                        
                        break;
                }
            }
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
        }];
        
        
    }];
}

-(void)exitCommentAndSendComment:(UIButton *)btn{
    
    NSLog(@"_textView.text==%@,length=%i",_textView.text,_textView.text.length);
    if ([NSString convertToInt:_textView.text]<kComentContentLength) {
        _alertView=[_notice showAlertWithMsg:KNoticeContentLengthFailTitle imageName:KNoticeContentLengthFailIcon toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    NSString *token=[self.co getToken];
    if (token) {
            [self.request sendCommenFollowCMV:self andProgarm:_progarmID andArticleID:_articleID andPicsID:_picsID andFollowID:_followID andContent:_textView.text];
            _alertView=[_notice showAlertWithMsg:KNoticeSendCommentBeingTitle imageName:KNoticeSendCommentBeingIcon toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
    }else{
        [CommonOperation goTOLogin];
    }
}

#pragma mark - ------------------UITextView的代理方法------------------
- (void)textViewDidChange:(UITextView *)textView {
   // UIImage *img=nil;
    if ([NSString convertToInt:_textView.text]>=kComentContentLength) {
        //img=[UIImage imageNamed:@"comment_yes_selected"];
        [_yes_btn setHighlighted:YES];
    }else{
        //img=[UIImage imageNamed:@"comment_yes"];
      //  _yes_btn.userInteractionEnabled=NO;
        [_yes_btn setHighlighted:NO];
    }
    [self saveCommentContent];
//    [_yes_btn setImage:img forState:UIControlStateNormal];
//    [_yes_btn setImage:img forState:UIControlStateHighlighted];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{

    [self textViewDidChange:textView];

}
    
#pragma mark -评论回复接口
-(void)getCommmentFollowInfo:(NSDictionary *)dic isSuccess:(BOOL)b{
    if (b) {
        
        NSString *result=[dic objectForKey:@"result"];
        NSString *resultInfo=[dic objectForKey:@"resultInfo"];
        NSString *userLocation=[dic objectForKey:@"userLocation"];
        [self.delegate sendSuccessWithContent:_textView.text andUserLocaton:userLocation];
        NSLog(@"result=%@,resultInfo＝%@",result,resultInfo);
        [_notice hideAlertView:_alertView fromView:self.view msg:KNoticeSendCommentSuccessTitle imageName:KNoticeSendCommentSuccessIcon];
        _textView.text=@"";
        [self saveCommentContent];
        [self exitComment:nil];
    }else{
         [_notice hideAlertView:_alertView fromView:self.view msg:KNoticeSendCommentFailTitle imageName:KNoticeSendCommentFailIcon];
        [_yes_btn setHighlighted:YES];
    }
}


-(void)queryCommentContent{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    _textView.text=[defaults objectForKey:@"commentContent"];
}

-(void)saveCommentContent{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *commentContent=_textView.text;
    [defaults setObject:commentContent forKey:@"commentContent"];
    [defaults synchronize];
}

-(void)dealloc{
    NSLog(@"---------commentview-------dealloc");
    self.request=nil;
    self.notice=nil;
    self.co=nil;
    _contentView=nil;
    _yes_btn=nil;
    _alertView=nil;
    _textView=nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];

}




@end
