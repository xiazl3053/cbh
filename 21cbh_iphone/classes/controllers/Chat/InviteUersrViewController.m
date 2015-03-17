//
//  InviteUersrViewController.m
//  21cbh_iphone
//
//  Created by Franky on 14-9-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "InviteUersrViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "ContactItem.h"
#import "UserModel.h"

@interface InviteUersrViewController ()<MFMessageComposeViewControllerDelegate,UIActionSheetDelegate>
{
    ContactItem* currentItem_;
}

@end

@implementation InviteUersrViewController

-(id)initWithContact:(ContactItem *)item
{
    if(self=[super init]){
        currentItem_=item;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    [self initView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)initView
{
    UIView* topView=[self Title:@"邀请好友" returnType:1];
    UIView *topLine=[[UIView alloc] initWithFrame:CGRectMake(0,topView.frame.size.height-0.5f, topView.frame.size.width,0.5f)];
    topLine.backgroundColor=K808080;
    [topView addSubview:topLine];
    
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(50, topView.bottom+10, 200, 30)];
    name.font=[UIFont fontWithName:kFontName size:17.0];
    name.text=currentItem_.userName;
    name.textColor=[UIColor blackColor];
    [self.view addSubview:name];
    
    UILabel *phone=[[UILabel alloc]initWithFrame:CGRectMake(50, topView.bottom+40, 200, 30)];
    phone.font=[UIFont fontWithName:kFontName size:17.0];
    phone.text=[NSString stringWithFormat:@"电话：%@",[currentItem_.phoneArray objectAtIndex:0]];
    phone.textColor=[UIColor blackColor];
    [self.view addSubview:phone];
    
    UIButton *add=[[UIButton alloc] initWithFrame:CGRectMake(10, topView.bottom+80, 300, 43)];
    [add addTarget:self action:@selector(sendEessage:) forControlEvents:UIControlEventTouchUpInside];
    [add setBackgroundColor:UIColorFromRGB(0xee5909)];
    [add setTitle:@"发送邀请" forState:UIControlStateNormal];
    [add setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [add.layer setMasksToBounds:YES];
    [add.layer setCornerRadius:2.0];
    [self.view addSubview:add];
}

-(void)sendEessage:(id)sender
{
    int count=currentItem_.phoneArray.count;
    if(count==1)
    {
        [self gotoSendMessage:[currentItem_.phoneArray objectAtIndex:0]];
    }
    else if(count>1)
    {
        UIActionSheet* actionSheet=[[UIActionSheet alloc] init];
        actionSheet.delegate=self;
        actionSheet.title=@"选择一个号码发送邀请";
        for (NSString* phone in currentItem_.phoneArray)
        {
            [actionSheet addButtonWithTitle:phone];
        }
        [actionSheet addButtonWithTitle:@"取消"];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        
        [actionSheet showInView:self.view];
    }
}

-(void)gotoSendMessage:(NSString*)phone
{
    MFMessageComposeViewController* controller = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        controller.body=[NSString stringWithFormat:@"21世纪网客户端除了可以看投资资讯，还可以聊天，挺好用的，推荐你用一下。下载地址：http://www.21cbh.com/apps/download2/。记得安装后搜索\"%@\"加我",[UserModel um].nickName];
        NSScanner* numberScanner = [NSScanner scannerWithString:phone];
        [numberScanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
        NSCharacterSet* charactersToSkip = [NSCharacterSet characterSetWithCharactersInString:@","];
        NSString* substring = @"";
        NSMutableArray *substrings = [NSMutableArray array];
        while (![numberScanner isAtEnd]) {
            [numberScanner scanUpToCharactersFromSet:charactersToSkip intoString:&substring];
            [numberScanner scanCharactersFromSet:charactersToSkip intoString:NULL];
            NSLog(@"%@", substring);
            [substrings addObject:substring];
        }
        
        controller.recipients = substrings;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - ------------MFMessageComposeViewControllerDelegate 的代理方法------------

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ------------UIActionSheetDelegate 的代理方法----------------

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(currentItem_.phoneArray.count>buttonIndex)
    {
        NSString* phone=[currentItem_.phoneArray objectAtIndex:buttonIndex];
        [self gotoSendMessage:phone];
    }
}

@end
