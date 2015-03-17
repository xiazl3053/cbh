//
//  PingLunHttpResponse.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PingLunHttpResponse.h"
#import "ASIFormDataRequest.h"
#import "NewsCommentViewController.h"
#import "NewsSpecialViewController.h"
#import "HeadSettingViewController.h"
#import "VersionCheckViewController.h"
#import "FeedBackViewController.h"
#import "MoreAppViewController.h"
#import "CommentViewController.h"
#import "CommentInfoModel.h"

#import "NewListModel.h"
#import "PicsListModel.h"
#import "NCMConstant.h"
#import "CommentThemeModel.h"
#import "MoreAppModel.h"
#import "MoreAppOtherInfoModel.h"


#import "UserModel.h"
#import "CommonOperation.h"
#import "ResponseJsonParseModel.h"


@implementation PingLunHttpResponse

#pragma mark -评论信息返回
-(void)commentListInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    NSLog(@"-----评论列表返回-------");
    NSString *str=[request responseString];
    NSDictionary *dic=[str JSONValue];
    if ([self isErrorWithJson:dic]) {
        
        @try {
            
            //获取整个数据
            NSDictionary *data=[dic objectForKey:@"data"];
            if (data) {
                //获取评论信息
                
                CommentThemeModel *theme=[[CommentThemeModel alloc]initWithNSDictionary:data];
              
                //获取hotFollows数据
                NSArray *hotFollows=[data objectForKey:@"hotFollows"];
                //获取Content信息
                NSMutableArray *hotData=[NSMutableArray array];
                
                for (NSDictionary *dic in hotFollows) {
                    
                    CommentInfoModel *model=[[CommentInfoModel alloc]initWithNSDictionary:dic];
                    
                    [hotData addObject:model];
                }
                
                //获取newFollows数据
                NSArray *newFollows=[data objectForKey:@"newFollows"];
                //获取Content信息
                NSMutableArray *newData=[NSMutableArray array];
                
                for (NSDictionary *dic in newFollows) {
                    
                    CommentInfoModel *model=[[CommentInfoModel alloc]initWithNSDictionary:dic];
                    
                    [newData addObject:model];
                    
                   // NSDate *date=[NSDate date];
                    
                   // NSLog(@"curdate=%f",[date timeIntervalSince1970]);
                }
                NSMutableArray *processData=[NSMutableArray arrayWithObjects:hotData,newData,nil];
                if (success) {
                    if (self.nc) {
                        // 更新评论数据
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.nc getCommentInfo:processData andTheme:theme isSuccess:YES];
                        });
                    }
                }
            }else{
                [self errorMsgPrase:dic];
               
                if (self.nc) {
                    // 更新评论数据
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.nc getCommentInfo:nil andTheme:nil isSuccess:NO];
                    });
                }
                    NSLog(@"专题无评论数据信息");
                    
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"----------评论信息返回错误--------");
        }
        @finally {
            
        }
        

    }
}

#pragma mark -专题信息返回
-(void)specialInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success error:(NSDictionary *)dic1{
    NSLog(@"-----专题列表返回-------");
    NSString *str=[request responseString];
    NSDictionary *dic=[str JSONValue];
    NSLog(@"专题列表返回:%@",str);
    if (success) {
        
        if ([self isErrorWithJson:dic]) {
            //获取整个数据
            NSDictionary *data=[dic objectForKey:@"data"];
            //获取list数据
            NSArray *list=[data objectForKey:@"list"];
            
            NewListModel *specialInfo=[[NewListModel alloc]init];
            specialInfo.title=[data objectForKey:@"specialTitle"];
            specialInfo.desc=[data objectForKey:@"specialGuide"];
            specialInfo.specialId=[data objectForKey:@"specialId"];
            specialInfo.adUrl=[data objectForKey:@"specialUrl"];//专题分享的3g页面链接
            
            ResponseJsonParseModel *json=[[ResponseJsonParseModel alloc]init];
            [json saveJson:str andFileName:specialInfo.specialId];
            //[json readJsonWithFileName:specialInfo.specialId];
            
            if ([data objectForKey:@"specialPicUrl"]) {
                specialInfo.picUrls=[NSArray arrayWithObject:[data objectForKey:@"specialPicUrl"]];
                if ([data objectForKey:@"sharePic"]) {//专题分享的微缩图
                    specialInfo.picUrls=[NSArray arrayWithObjects:[data objectForKey:@"specialPicUrl"],[data objectForKey:@"sharePic"],nil];
                }
            }
            
            NSMutableArray *specialData=[NSMutableArray array];
            for (NSDictionary *obj in list) {
                
                NSString *type=[obj objectForKey:@"grouptype"];
                int nIdex=[type integerValue];
                
                switch (nIdex) {
                    case 0:
                    {
                        NSMutableArray *news=[NSMutableArray array];
                        for (NSDictionary *item in [obj objectForKey:@"content"]) {
                            NewListModel *new=[[NewListModel alloc]initWithDict:item];
                            [news addObject:new];
                        }
                        NSMutableDictionary *newsDic=[NSMutableDictionary dictionary];
                        [newsDic setValue:[obj objectForKey:@"grouptype"] forKey:@"grouptype"];
                        [newsDic setValue:[obj objectForKey:@"groupName"] forKey:@"groupName"];
                        [newsDic setValue:news forKey:@"content"];
                        [specialData addObject:newsDic];
                    } break;
                    case 1:{
                        NSMutableArray *pics=[NSMutableArray array];
                        for (NSDictionary *item in [obj objectForKey:@"content"]) {
                            PicsListModel *pic=[[PicsListModel alloc]initWithDict:item];
                            [pics addObject:pic];
                        }
                        NSMutableDictionary *picsDic=[NSMutableDictionary dictionary];
                        [picsDic setValue:[obj objectForKey:@"grouptype"] forKey:@"grouptype"];
                        [picsDic setValue:[obj objectForKey:@"groupName"] forKey:@"groupName"];
                        [picsDic setValue:pics forKey:@"content"];
                        [specialData addObject:picsDic];
                    }break;
                        
                    default:
                        break;
                }
            }
                if (self.np) {
                    // 更新专题
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.np getSpecialBack:specialData andSpecialInfo:specialInfo isSuccess:YES errro:nil];
                    });}
        }else{
            [self errorMsgPrase:dic];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                switch ([[dic objectForKey:KServerBackErrorKey]integerValue]) {
                    case 2:
                    {
                        [self.np getSpecialBack:nil andSpecialInfo:nil isSuccess:NO errro:dic];
                    } break;
                    case 3:{
                        [CommonOperation goTOLogin];
                    }break;
                    default:
                        break;
                }
                
            });
        }
    }else{
            if (self.np) {
                // 更新评论数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.np getSpecialBack:nil andSpecialInfo:nil isSuccess:NO errro:dic1];
                });
        }else{
        }
    }
}

#pragma mark -点赞回复接口
-(void)commentDingInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    NSLog(@"-----评论点赞返回-------");
    NSString *str=[request responseString];
    NSDictionary *dic=[str JSONValue];
    if ([self isErrorWithJson:dic]) {
        NSDictionary *data=[dic objectForKey:@"data"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nc getCommmentDingInfo:data];
        });
    }else{
        [self errorMsgPrase:dic];
    }
}

#pragma mark -评论回复接口
-(void)commentFollowInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        NSLog(@"-----评论回复返回-------");
        NSString *str=[request responseString];
        NSLog(@"str=%@",str);
        NSDictionary *dic=[str JSONValue];
        if ([self isErrorWithJson:dic]&&dic) {
            NSDictionary *data=[dic objectForKey:@"data"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cv getCommmentFollowInfo:data isSuccess:YES];
            });
        }else if ([[dic objectForKey:KServerBackErrorKey]integerValue]==3){
            dispatch_async(dispatch_get_main_queue(), ^{
                [CommonOperation goTOLogin];
                 [self.cv getCommmentFollowInfo:nil isSuccess:NO];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self errorMsgPrase:dic];
                [self.cv getCommmentFollowInfo:nil isSuccess:NO];
            });
            
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cv getCommmentFollowInfo:nil isSuccess:NO];
        });
    }
}
#pragma mark -图像上传接口
-(void)settingHeadInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        NSLog(@"--------图像上传返回--------");
        NSString *str=[request responseString];
        NSLog(@"--------%@--------",str);
        NSDictionary *dic=[str JSONValue];
        if ([self isErrorWithJson:dic]) {
            if (self.hs) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *data=[dic objectForKey:@"data"];
                    // NSString *userUrl=[data objectForKey:@"figureUrl"];
                    [self.hs updateHeadImgBackDataWithNSDictionary:data andSuccess:YES];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self errorMsgPrase:dic];
                [self.hs updateHeadImgBackDataWithNSDictionary:nil andSuccess:NO];
            });
        }
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hs updateHeadImgBackDataWithNSDictionary:nil andSuccess:NO];
        });
    }
}

#pragma mark -appInfoBack
-(void)versionInfoBackData:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        NSString *str=[request responseString];
        NSDictionary *dic=[str JSONValue];
        if ([self isErrorWithJson:dic]) {
            if (self.vc) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.vc getAppleIDBackData:dic isSuccess:YES];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.vc getAppleIDBackData:nil isSuccess:NO];
            });
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.vc getAppleIDBackData:nil isSuccess:NO];
        });
    }
}

#pragma mark -反馈意见回调
-(void)feedBackInfoBackData:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        NSString *str=[request responseString];
        NSDictionary *dic=[str JSONValue];
        if ([self isErrorWithJson:dic]) {
            if (self.fb) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     NSDictionary *data=[dic objectForKey:@"data"];
                    [self.fb feedBackSubmitInfoBack:data isSuccess:YES];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self errorMsgPrase:dic];
                [self.fb feedBackSubmitInfoBack:nil isSuccess:NO];
            });
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fb feedBackSubmitInfoBack:nil isSuccess:NO];
        });
    }
}

#pragma mark -更多应用回调
-(void)moreAppInfoBackData:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        NSString *str=[request responseString];
        NSDictionary *dic=[str JSONValue];
        if ([self isErrorWithJson:dic]) {
            if (self.ma) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *data=[dic objectForKey:@"data"];
                    NSArray *list=[data objectForKey:@"list"];
                    NSMutableArray *backData=[NSMutableArray array];
                    for (NSDictionary *obj in list) {
                        MoreAppModel *info=[[MoreAppModel alloc]initWithNSDictionary:obj];
                        [backData addObject:info];
                    }
                    MoreAppOtherInfoModel *info=[[MoreAppOtherInfoModel alloc]initWithNSDictonary:data];
                    [self.ma moreAppQueryInfoBackData:backData and:info isSuccess:YES];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self errorMsgPrase:dic];
                [self.ma moreAppQueryInfoBackData:nil and:nil isSuccess:NO];
            });
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.ma moreAppQueryInfoBackData:nil and:nil isSuccess:NO];
        });
    }

}

#pragma mark -用户信息回调
//-(void)userinfoBackData:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
//    if (success) {
//        NSString *str=[request responseString];
//        NSDictionary *dic=[str JSONValue];
//        NSLog(@"dic====%@",dic);
//        if ([self isErrorWithJson:dic]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSDictionary *data=[dic objectForKey:@"data"];
//                EFriends *info=[[EFriends alloc]initWithNSDictionary:data];
//                [self.ui userinfoBackData:info isSuccess:YES];
//            });
//        }else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self errorMsgPrase:dic];
//                [self.ma moreAppQueryInfoBackData:nil and:nil isSuccess:NO];
//            });
//        }
//    }else{
//        dispatch_async(dispatch_get_main_queue(), ^{
//        });
//    }
//}

-(void)dealloc{
    // 释放对象
    self.nc = nil;
    self.np = nil;
    self.hs=nil;
    self.vc=nil;
    self.cv=nil;
    self.fb=nil;
    self.ma=nil;
}

#pragma mark -数据是存在错误
-(BOOL)isErrorWithJson:(NSDictionary *)dic{
    NSString *err=[dic objectForKey:@"errno"];
    return [err integerValue]==0?YES:NO;
    
}

#pragma mark -错误原因解析
-(void)errorMsgPrase:(NSDictionary *)dic{
    NSLog(@"errorMsg=%@",[dic objectForKey:@"msg"]);
}




@end
