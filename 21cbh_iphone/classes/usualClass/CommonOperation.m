//
//  CommonOperation.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommonOperation.h"
#import "DES3Util.h"
#import "MD5.h"
#import "GTMBase64.h"
#import <sys/param.h>
#import <sys/mount.h>


#define KImageDirName @"image"//图片文件夹名字

static CommonOperation *_co;

@implementation CommonOperation

+(CommonOperation *)getId{
    if (_co) {
        return _co;
    }
    _co=[[CommonOperation alloc] init];
    return _co;
}

#pragma mark 获取网络连接状态
-(BOOL)getNetStatus{
    BOOL b=YES;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            b=NO;
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            break;
    }
    
    return b;
}

#pragma mark 提示信息
-(void)showAlert:(NSString *)info{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:info delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark 获取屏幕宽度和高度
-(CGSize)getScreenSize{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    CGFloat scale = [MainScreen scale];
    CGFloat screenWidth = size.width * scale;//屏幕宽度
    CGFloat screenHeight = size.height * scale;//屏幕高度
    size.width=screenWidth;
    size.height=screenHeight;
    return size;
}

#pragma mark 获取最佳尺寸类型参数
-(NSString *)getScreenType{
    CGSize size=[self getScreenSize];
    
    if (size.height==480) {
        return [NSString stringWithFormat:@"0"];
    }else if(size.height==960){
        return [NSString stringWithFormat:@"1"];
    }else if(size.height==1136){
        return [NSString stringWithFormat:@"2"];
    }
    
    return [NSString stringWithFormat:@"2"];
}


#pragma mark 获取版本号
-(NSString *)getVersion{
    //版本号
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* version =[infoDict objectForKey:@"CFBundleVersion"];
    return version;
}


#pragma mark 设置token
-(void)setToken:(NSString *)token{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"token"];
    [defaults synchronize];
}

#pragma mark 获取token
-(NSString *)getToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token=[defaults objectForKey:@"token"];
    return token;
}

#pragma mark 设置appleToken
-(void)setAppleToken:(NSString *)appleToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:appleToken forKey:@"appleToken"];
    [defaults synchronize];
}

#pragma mark 获取appleToken
-(NSString *)getAppleToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appleToken=[defaults objectForKey:@"appleToken"];
    return appleToken;
}


#pragma mark 检验账号昵称的合法性
-(BOOL)isValidateName:(NSString *)name {
    
    NSString *nameRegex = @"^[A-Za-z0-9-_\\x{4e00}-\\x{9fa5}]{2,20}$";
    
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    
    return [nameTest evaluateWithObject:name];
    
}


#pragma mark 检验密码的合法性
-(BOOL)isValidatePassword:(NSString *)password {
    
    NSString *passwordRegex = @"^[\\w-_~`!@#$%^&*()+={}\\[\\]|:;\"'<>?,\\./\\\\]{6,16}$";
    
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    
    return [passwordTest evaluateWithObject:password];
    
}

#pragma mark 检验邮箱的合法性
-(BOOL)isValidateEmail:(NSString *)email {
    
    NSString *emailRegex = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
    
}

#pragma 手机号码验证
-(BOOL) isValidateMobile:(NSString *)mobileNum
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobileNum];
}

#pragma mark 跳转到登陆页
+(void)goTOLogin{
    dispatch_async(dispatch_get_main_queue(), ^{
        LoginViewController *lvc=[[LoginViewController alloc] init];
        UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:lvc];
        lvc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
        [[[CommonOperation getId] getCurrectNavigationController] presentViewController:nc animated:YES completion:nil];
        //清楚过期的账户信息
        [[CommonOperation getId] loginout];
    });
}

#pragma mark 跳转到手机绑定页
+(void)goToBindPhone{
    dispatch_async(dispatch_get_main_queue(), ^{
        BindingMobileViewController *bmv=[[BindingMobileViewController alloc] init];
        UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:bmv];
        bmv.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
        [[[CommonOperation getId] getCurrectNavigationController] presentViewController:nc animated:YES completion:nil];
    });
}

#pragma mark 跳转到联系人页
+(void)goToContacts{
    dispatch_async(dispatch_get_main_queue(), ^{
        SelectUserChatViewController *scv=[[SelectUserChatViewController alloc] init];
        UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:scv];
        scv.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
        [[[CommonOperation getId] getCurrectNavigationController] presentViewController:nc animated:YES completion:nil];
    });
}

#pragma mark 跳转到聊天主页
+(void)goToChatViewWithModel:(NewListModel *)nlm{
    dispatch_async(dispatch_get_main_queue(), ^{
        ChatViewController *cc = [[ChatViewController alloc] initWithModel:nlm];
        [[[CommonOperation getId] getMain].navigationController pushViewController:cc animated:YES];
    });
}

#pragma mark 将用户信息写进本地
+(void)writeUmToLoacal:(UserModel *)um{
    // 将账号写入沙盒
    FileOperation *fo=[[FileOperation alloc] init];
    NSString *userDir=[fo getFileDirWithFileDirName:kUserDir];
    NSString *userFile=[userDir stringByAppendingPathComponent:kUserFile];
    [NSKeyedArchiver archiveRootObject:um toFile:userFile];
}

#pragma mark 清除用户信息
+(void)clearUm{
    UserModel *um=[UserModel um];
    [um clearData];
    [CommonOperation writeUmToLoacal:um];
}

#pragma mark 获取UUID(自写的标识)
-(NSString *)getUUID{
    
    NSString *identifierNumber=[ZXUserDataManager readIdentifierNumber];
    
    if (!identifierNumber) {
        
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        
        CFStringRef uuidstring = CFUUIDCreateString(NULL, uuid);
        
        identifierNumber = [NSString stringWithFormat:@"%@",uuidstring];
        
        //存储到keychain
        [ZXUserDataManager saveIdentifierNumber:identifierNumber];
        
        CFRelease(uuidstring);
        
        CFRelease(uuid);
        
    }
    
    return identifierNumber;
}

#pragma mark 获取时间戳
-(NSString *)getAddtime{
    NSString *s=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSArray *array=[s componentsSeparatedByString:@"."];
    NSString *addtime=[array objectAtIndex:0];
    return addtime;
}


#pragma mark 具体跳转操作(公共方法)
-(void)gotoViewController:(UIViewController*)controller
{
    UIViewController* nav=[[CommonOperation getId] getCurrectNavigationController];
    if([nav isKindOfClass:[UINavigationController class]]){
        if(nav.presentedViewController){
            [nav dismissViewControllerAnimated:NO completion:nil];
        }
        [((UINavigationController*)nav) pushViewController:controller animated:YES];
    }
    else{
        [nav presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark 获取当前UINavigationController
- (UIViewController*)getCurrectNavigationController {
    UIViewController *result;
    
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    if ([nextResponder isKindOfClass:[UINavigationController class]])
    {
        result = nextResponder;
    }
    else if([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
    {
        result = topWindow.rootViewController;
    }
    else
    {
        NSLog(@"找不到根页面");
    }
    return result;
}


#pragma mark 获取main
-(MainViewController *)getMain{
    MainViewController *main=((AppDelegate*)([UIApplication sharedApplication].delegate)).main;
    return main;
}

#pragma mark 设置lable的行距
-(void)setIntervalWithTextView:(UITextView *)textView text:(NSString *)text font:(UIFont *)font lineSpace:(CGFloat)lineSpace color:(UIColor *)color{
    
    NSMutableParagraphStyle * myStyle = [[NSMutableParagraphStyle alloc] init];
    
    [myStyle setLineSpacing:lineSpace];
    
    NSDictionary *dict=@{NSFontAttributeName:font,NSParagraphStyleAttributeName:myStyle,NSForegroundColorAttributeName :color};
    
    NSAttributedString *att=[[NSAttributedString alloc]initWithString:text attributes:dict];
    
    textView.attributedText=att;
}

#pragma mark 时间戳转换成时间
-(NSString *)addtimeTurnToTimeString:(NSString *)addtime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[addtime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

-(NSString *)addtimeTurnToTimeString2:(NSString *)addtime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[addtime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

#pragma mark 第三方授权成功后存储用户信息
-(void)savedata:(NSString *)nickName andShareType:(int)type{
    
    NSMutableArray *authList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
    
    if (authList == nil)
    {
        authList = [[NSMutableArray alloc]init];
        NSArray *shareTypes = [ShareSDK connectedPlatformTypes];
        for (int i = 0; i < [shareTypes count]; i++)
        {
            NSNumber *typeNum = [shareTypes objectAtIndex:i];
            ShareType type = [typeNum integerValue];
            if (type == ShareTypeSinaWeibo||type == ShareTypeQQSpace|| type == ShareTypeEvernote)
            {
                [authList addObject:[NSMutableDictionary dictionaryWithObject:[shareTypes objectAtIndex:i]
                                                                              forKey:@"type"]];
            }
        }
    }
    
    //改变用户信息
    for (int i = 0; i < [authList count]; i++)
    {
        NSDictionary *item = [authList objectAtIndex:i];
        if ([[item objectForKey:@"type"]integerValue]==type) {
            [item setValue:nickName forKeyPath:@"username"];
        }
    }
    [authList writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
}


#pragma 检测是否删表
-(void)checkTableUpdateWithTableName:(NSString *)tableName className:(NSString *)className db:(sqlite3 *)db{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DBList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *version1=[data objectForKey:className];
    NSString *version2 = [[NSUserDefaults standardUserDefaults] objectForKey:className];
    
    if (!version2||![version2 isEqual:version1]) {//需要删除旧表
        NSString *str=[NSString stringWithFormat:@"drop table if exists %@",tableName];
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(db, str.UTF8String, -1, &stmt, NULL)==SQLITE_OK)
        {
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                NSLog(@"删除旧版数据库%@表失败",className);
            } else {
                NSLog(@"检测到数据库表%@陈旧,删除成功后重建",className);
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:version1 forKey:className];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            NSLog(@"删除旧版数据库%@表语句错误",className);
        }
        sqlite3_finalize(stmt);
    }
}

#pragma 检测是否删数据库
-(void)checkTableDeleteWithClassName:(NSString *)className path:(NSString*)path//EMessagesDB
{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DBList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *version1=[data objectForKey:className];
    NSString *version2 = [[NSUserDefaults standardUserDefaults] objectForKey:className];
    
    if (!version2||![version2 isEqual:version1]) {//需要删除旧数据库
        [[FileOperation getId] deleteFolderWithPath:path];
        [[NSUserDefaults standardUserDefaults] setObject:version1 forKey:className];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(BOOL)addCoumnWithTableName:(NSString *)tableName className:(NSString *)className columnName:(NSString*)columnName typeData:(NSString*)typeData db:(sqlite3 *)db
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DBList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *version1=[data objectForKey:className];
    NSString *version2 = [[NSUserDefaults standardUserDefaults] objectForKey:className];
    BOOL flag=NO;
    
    if (!version2||![version2 isEqual:version1]) {//需要更新旧表
        NSString *str=[NSString stringWithFormat:@"alter table %@ add %@ %@",tableName,columnName,typeData];
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(db, str.UTF8String, -1, &stmt, NULL)==SQLITE_OK)
        {
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                NSLog(@"更新旧版数据库%@表失败",className);
                flag=NO;
            } else {
                NSLog(@"检测到数据库表%@陈旧,更新成功",className);
                flag=YES;
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:version1 forKey:className];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            NSLog(@"更新旧版数据库%@表语句错误",className);
            flag=NO;
        }
        sqlite3_finalize(stmt);
    }
    return flag;
}

#pragma mark 生成唯一GUID
+(NSString*)stringWithGUID{
    CFUUIDRef guidObj = CFUUIDCreate(nil);
    //create a new GUID
    //get the string representation of the GUID
    NSString *guidString = [NSString stringWithFormat:@"%@",CFBridgingRelease(CFUUIDCreateString(nil, guidObj))];
    CFRelease(guidObj);
    return guidString;
}

#pragma mark 清缓存
-(void)clearCach{
    //清除所有缓存图片
    [[SDImageCache sharedImageCache] clearDisk];
    //清除html文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileDir = [paths[0] stringByAppendingPathComponent:@"21cbh/html"];
    [[FileOperation getId] deleteFileWithfileDir:fileDir fileType:@"html"];
}


#pragma mark 自动检查清除用户的缓存数据
-(void)automaticClearCach{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *fileDir = [paths[0] stringByAppendingPathComponent:@"21cbh/html"];
        float size=[[FileOperation getId] folderSizeAtPath:fileDir];
        NSLog(@"用户目前的缓存数据大小为:%fM",size);
        if (size>50) {//超过50m就自动清除掉
            [self clearCach];
            NSLog(@"用户数据大于50M,自动清除完毕!");
        }
    });
}

#pragma mark 注销请求
-(void)logout{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    [hmgr loginOut];
}

#pragma mark 退出登陆
-(void)loginout{
    //注销请求
    [[CommonOperation getId]  logout];
    //设置token为nil
    [[CommonOperation getId] setToken:nil];
    //清除账号信息
    [CommonOperation clearUm];
    //发送注销账号通知
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotifcationKeyForLogout object:nil userInfo:nil];
}

#pragma mark 注册苹果推送服务
-(void)registerApplePush{
    //注册苹果推送
    [((AppDelegate*)([UIApplication sharedApplication].delegate)) registerApplePush];
}



#pragma mark 获取屏幕的高度
-(CGFloat)getScreenHeight{
    
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize Size = [MainScreen bounds].size;
    CGFloat scale = [MainScreen scale];
    //CGFloat screenWidth = Size.width * scale;//屏幕宽度
    CGFloat screenHeight = Size.height * scale;//屏幕高度
    NSLog(@"%f",screenHeight);
    return screenHeight;
}



#pragma mark 加密
-(NSString *)encryptHttp:(NSMutableDictionary *)dic{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    //获取当前时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]+12*60*60;  //  *1000 是精确到毫秒，不乘就是精确到秒
    NSString *expired_date = [NSString stringWithFormat:@"%f", a]; //转为字符型
    [dic setValue:expired_date forKey:@"expired_date"];
    
    //转成json字符串
    NSString *data = [writer stringWithObject:dic];
    //3des加密
    NSString *encrypt_data=[DES3Util encrypt:data];
    //MD5加密验证字符串
    NSString *verify=[[[MD5 alloc] init] md5:[[KAppKey stringByAppendingString:KSkey] stringByAppendingString:encrypt_data]];
    
    NSMutableDictionary *dic2=[NSMutableDictionary dictionary];
    [dic2 setValue:KAppKey forKey:@"app_key"];
    [dic2 setValue:encrypt_data forKey:@"encrypt_data"];
    [dic2 setValue:verify forKey:@"verify"];
    
    //base64加密
    NSString *post_data=[GTMBase64 base64StringBystring:[writer stringWithObject:dic2]];
    
    return post_data;
}

#pragma mark 获取手机存储空间
-(NSString *) freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("private/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return [NSString stringWithFormat:@"%.1f" ,(float)freespace/1024/1024];
}


@end
