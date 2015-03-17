//
//  HeadSettingViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "HeadSettingViewController.h"
#import "NCMConstant.h"
#import "PingLunHttpRequest.h"
#import "UserModel.h"
#import "UIImageView+WebCache.h"
#import "CommonOperation.h"
#import "NoticeOperation.h"
#import "UIImage+SizeZoom.h"

#define KUpFileMaxSize 1024

#define KButtonWidth 61


@interface HeadSettingViewController (){
    UIView *_topSepartor;
    UIImageView *_headImage;
    UIButton *_camera;
    UIButton *_photo;
    UIView *_line;

}
@property (nonatomic,strong) PingLunHttpRequest *request;

@end

@implementation HeadSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initParams];
	[self initViews];
    [self initStyle];
}

-(void)initParams{

    UIView *top=[self Title:@"设置头像" returnType:2];
    UIView *separator=[[UIView alloc]initWithFrame:CGRectMake(0, top.bottom-1, 320, 1)];
    _topSepartor=separator;
    [self.view addSubview:separator];
    

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    UserModel *user=[UserModel um];
    [_headImage setImageWithURL:[NSURL URLWithString:user.picUrl] placeholderImage:[UIImage imageNamed:@"settings_head"]];
}

-(void)initViews{
    
    UserModel *user=[UserModel um];
    
    //图像
    UIImageView *img=[[UIImageView alloc]init];
    img.frame=CGRectMake((self.view.frame.size.width-90)*.5, 20+44+28, 90, 90);
    [img setImageWithURL:[NSURL URLWithString:user.picUrl] placeholderImage:[UIImage imageNamed:@"settings_head"]];
    [self.view addSubview:img];
    _headImage=img;
    
    //分隔线
    UIView *line=[[UIView alloc]init];
    line.frame=CGRectMake((self.view.frame.size.width-202)*.5, img.bottom+28, 202, 0.5);
    _line=line;
    [self.view addSubview:line];
    
    //文字
    UILabel *lable=[[UILabel alloc]init];
    lable.frame=CGRectMake((self.view.frame.size.width-200)*.5, line.bottom+13, 200, 20);
    lable.text=@"上传方式";
    lable.textAlignment=NSTextAlignmentCenter;
    lable.font=[UIFont systemFontOfSize:11];
    lable.textColor=UIColorFromRGB(0x636363);
    [self.view addSubview:lable];
    
    //相机
    UIButton *btn1=[[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-KButtonWidth*2-20)*.5, lable.bottom+20, KButtonWidth, KButtonWidth)];
   // [btn1 setTitle:@"camera" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(initCamera) forControlEvents:UIControlEventTouchUpInside];
   // [btn1 setBackgroundImage:[UIImage imageNamed:@"camera_normal.png"] forState:UIControlStateNormal];
    _camera=btn1;
    
    //照片
    UIButton *btn2=[[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-KButtonWidth)*.5+40, lable.bottom+20, KButtonWidth,KButtonWidth)];
   // [btn2 setTitle:@"photo" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(initPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
    //[btn2 setBackgroundImage:[UIImage imageNamed:@"photo_normal.png"] forState:UIControlStateNormal];
    _photo=btn2;
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
}

#pragma mark -style
-(void)initStyle{
    switch (KAppStyle) {
        case APPSTYLE_TYPE_WHITE:{
            self.view.backgroundColor=KBgWitheColor;
            _topSepartor.backgroundColor=UIColorFromRGB(0x8d8d8d);
            _line.backgroundColor=UIColorFromRGB(0X959595);
//            _headImage.layer.masksToBounds=YES;
//            _headImage.layer.cornerRadius=10.0;
            _headImage.layer.borderColor=UIColorFromRGB(0Xcccccc).CGColor;
            _headImage.layer.borderWidth=1.0;
            [_camera setBackgroundImage:[UIImage imageNamed:@"camera_white_select.png"] forState:UIControlStateNormal];
            [_photo setBackgroundImage:[UIImage imageNamed:@"photo_white_select.png"] forState:UIControlStateNormal];
        }break;
        case APPSTYLE_TYPE_BLACK:{
            self.view.backgroundColor=kBgcolor;
            _topSepartor.backgroundColor=UIColorFromRGB(0x808080);
            _line.backgroundColor=UIColorFromRGB(0X808080);
            _headImage.layer.borderColor=UIColorFromRGB(0Xcccccc).CGColor;
            _headImage.layer.borderWidth=1.0;
            [_camera setBackgroundImage:[UIImage imageNamed:@"camera_select.png"] forState:UIControlStateNormal];
            [_photo setBackgroundImage:[UIImage imageNamed:@"photo_select.png"] forState:UIControlStateNormal];
        }break;
            
        default:
            break;
    }

}

-(void)initCamera{
    //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
            picker.delegate = self;
            picker.allowsEditing = YES;//设置可编辑
            picker.sourceType = sourceType;
            
            [self presentViewController:picker animated:YES completion:^{
                
            }];//进入照相界面
        }else{
            NSLog(@"相机不可用");
        }
    //sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
    //sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //图片库
    //sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; //保存的相片
   

}

-(void)initPhotoLibrary{

    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = YES;
    [self presentViewController:pickerImage animated:YES completion:^{
        
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击相册中的图片后触发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self compressWithImage:[info objectForKey:UIImagePickerControllerEditedImage]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//点击cancel 调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"cancel=%@",picker);
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}


#pragma mark -图片尺寸设置
-(void )compressWithImage:(UIImage *)image{
    //限制尺寸
    UIImage *sizeZoom=[image transformWidth:320 height:320];
    NSLog(@"image.width=%f,image.height=%f",image.size.width,image.size.height);
    //压缩图片
    NSData *imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(sizeZoom, 0.5)];
    NSString *path=[KDataCacheDocument stringByAppendingPathComponent:@"temp.png"];
    //存储图片
    if ([imageData writeToFile:path atomically:YES]) {
        NSLog(@"save success");
    }else{
        NSLog(@"save failure");
    }
    //获取图片
    NSFileManager *file=[NSFileManager defaultManager];
    NSDictionary *dic =[file attributesOfItemAtPath:path error:Nil];
    NSString *fileSize= [dic objectForKey:NSFileSize];
    if ([fileSize floatValue]/1024>KUpFileMaxSize) {
        NSLog(@"图片太大,file.Size====%fKB",[fileSize floatValue]/1024);
    }else{
        NSLog(@"file.Size====%fKB,path=%@",[fileSize floatValue]/1024,path);
        [self setUserFigureImage];
    }
}

#pragma mark -上传完成后回调
-(void)updateHeadImgBackDataWithNSDictionary:(NSDictionary *)dic andSuccess:(BOOL)b{
    NoticeOperation *notice=[[NoticeOperation alloc]init];
    if (b) {
        NSString *userUrl=[dic objectForKey:@"figureUrl"];
        [self setUserHeadWithUrl:userUrl];
        [notice showAlertWithMsg:@"上传成功" imageName:@"NewsComment_CollectSuccee" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
    }else{
        [notice showAlertWithMsg:@"上传失败" imageName:@"NewsComment_CollectSuccee" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
    }
}

#pragma mark -上传用户图像
-(void)setUserFigureImage{
    NSString *path=[KDataCacheDocument stringByAppendingPathComponent:@"temp.png"];
    self.request=[[PingLunHttpRequest alloc]init];
    [_request updateUserFigrueWith:self andFigurePath:path];
}

#pragma mark -设置用户图像
-(void)setUserHeadWithUrl:(NSString *)url{
    UserModel *user= [UserModel um];
    user.picUrl=url;
    [CommonOperation writeUmToLoacal:user];
    [_headImage setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"settings_head"]];
}


-(void)dealloc{
    NSLog(@"-----------headSetting---------delloc");
    self.request=nil;
    _headImage=nil;
    _topSepartor=nil;
    _camera=nil;
    _photo=nil;
    _line=nil;
}

@end
