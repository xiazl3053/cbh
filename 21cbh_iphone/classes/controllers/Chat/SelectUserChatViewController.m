//
//  SelectUserChatViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-7-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "SelectUserChatViewController.h"
#import "ContactsViewController.h"

@interface SelectUserChatViewController (){

    UIView *_top;
}

@end

@implementation SelectUserChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor=[UIColor redColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    // Do any additional setup after loading the view.
}

-(void)initViews{
    [self initBar];
    [self initView];
    
  ;
}
-(void)initBar{
    UIView *top=[self Title:@"选择" returnType:1];
    _top=top;
    UIView *separator=[[UIView alloc]initWithFrame:CGRectMake(0, _top.bottom-1, 320, 1)];
    separator.backgroundColor=K808080;
    [self.view addSubview:separator];
}
-(void)initView{
    ContactsViewController *contact=[[ContactsViewController alloc]init];
    contact.view.frame=CGRectMake(0, _top.bottom, self.view.frame.size.width, self.view.frame.size.height);
  //  NSLog(@"rect=%@",NSStringFromCGRect(self.view.frame));
    [self addChildViewController:contact];
    [self.view addSubview:contact.view];
    

}

-(void)returnBack{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
