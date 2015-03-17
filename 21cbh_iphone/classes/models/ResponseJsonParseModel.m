//
//  ResponseJsonParseModel.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ResponseJsonParseModel.h"
#import "ASIFormDataRequest.h"
#import "NewListModel.h"
#import "PicsListModel.h"
#import "NCMConstant.h"
#import "NewsSpecialViewController.h"

@implementation ResponseJsonParseModel

-(BOOL)loadLocalSpecialWithCacheVC:(NewsSpecialViewController *)vc andSepcialID:(NSString *)specialID{
    
    NSString *Json_path=[KDataCacheDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",Ksepcial,specialID]];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    
    if ([fileManage fileExistsAtPath:Json_path]) {
        NSData *data1=[NSData dataWithContentsOfFile:Json_path];
        if (data1==nil) {
            return NO;
        }
        id JsonObject=[NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"从本地获取数据＝＝＝%@",JsonObject);
        
        //获取整个数据
        NSDictionary *data=[JsonObject objectForKey:@"data"];
        //获取list数据
        NSArray *list=[data objectForKey:@"list"];
        NewListModel *specialInfo=[[NewListModel alloc]init];
        specialInfo.title=[data objectForKey:@"specialTitle"];
        specialInfo.desc=[data objectForKey:@"specialGuide"];
        specialInfo.adUrl=[data objectForKey:@"specialUrl"];//专题分享的3g页面链接
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
        [vc getSpecialBack:specialData andSpecialInfo:specialInfo isSuccess:YES errro:nil];
        return YES;
    }else{
        NSLog(@"------NewsSPecial-------无本地数据");
        return NO;
    } 
}

#pragma mark -存储Json
-(void)saveJson:(NSString *)data andFileName:(NSString *)name{
    // 将Json存进本地文件夹
    NSString *Json_path=[KDataCacheDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",Ksepcial,name]];
    //写入文件
    BOOL success= [data writeToFile:Json_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (success) {
        NSLog(@"-----存入Json成功-----");
    }else{
        NSLog(@"-----存入Json失败-----");
    }
}

#pragma mark -读取Json
-(void)readJsonWithFileName:(NSString *)name{
    NSLog(@"-------读取Josn--------");
    //Json文件路径
    NSString *Json_path=[KDataCacheDocument stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",Ksepcial,name]];
    //Json数据
    NSData *data=[NSData dataWithContentsOfFile:Json_path];
    if (data) {
        id JsonObject=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"JsonObject===%@",JsonObject);
    }else{
        NSLog(@"no data");
    }
}


@end
