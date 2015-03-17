//
//  NewListDB.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewListDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"

@interface NewListDB(){
    
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end

@implementation NewListDB

-(id)init
{
    if(self=[super init]){
        [self openDB];
    }
    return self;
}

-(void)dealloc
{
    [self closeDB];
}

#pragma mark 打开数据库
- (void)openDB {
    // 数据库文件路径
    NSString *filename = [kdbName documentsAppend];
    
    // 如果数据库不存在，就会创建一个
    int result = sqlite3_open([filename UTF8String], &_db);
    if (result == SQLITE_OK) {
        //NSLog(@"打开数据库成功!");
        //创建表
        [self createTables];
    }else{
        NSLog(@"打开数据库失败!");
    }
}

#pragma mark 关闭数据库
-(void)closeDB{
    // 关闭数据库
    sqlite3_close(_db);
    
    //NSLog(@"关闭了数据库!");
}

#pragma mark 创建表
- (void)createTables {
    //设置表名
    _tableName=@"newsList";
    NSString *className=@"NewListDB";
    //检测是否需要删表
    [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, programId text,type text,articleId text,picsId text,specialId text,videoId text,adId text,picUrls text,title text,desc text,followNum text,adUrl text,videoUrl text,order1 text,addtime text);",_tableName];
    
    const char *sql =[string UTF8String];
    
    char *error;
    // sqlite3_exec能执行一切SQL语句
    // insert into t_person(name, age) values('mj', 10);
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    
    if (result == SQLITE_OK) {
        //NSLog(@"创表成功!");
    }else{
        NSLog(@"创表错误：%s", error);
    }
}

#pragma mark 插入数据
-(void)insertNlm:(NewListModel *)nlm programId:(NSString *)programId{
    
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(programId,type,articleId,picsId,specialId,videoId,adId,picUrls,title,desc,followNum,adUrl,videoUrl,order1,addtime) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *programId1=[programId UTF8String];
        const char *type=[nlm.type UTF8String];
        const char *articleId=[nlm.articleId UTF8String];
        const char *picsId=[nlm.picsId UTF8String];
        const char *specialId=[nlm.specialId UTF8String];
        const char *videoId=[nlm.videoId UTF8String];
        const char *adId=[nlm.adId UTF8String];
        const char *title=[nlm.title UTF8String];
        const char *desc=[nlm.desc UTF8String];
        const char *followNum=[nlm.followNum UTF8String];
        const char *adUrl=[nlm.adUrl UTF8String];
        const char *videoUrl=[nlm.videoUrl UTF8String];
        const char *order=[nlm.order UTF8String];
        const char *addtime=[nlm.addtime UTF8String];
        
        NSString *s_picUrls=@"";
        if (nlm.picUrls&&nlm.picUrls.count>0) {
            for (int i=0; i<nlm.picUrls.count; i++) {
                NSString *s1=[nlm.picUrls objectAtIndex:i];
                // NSLog(@"s1:%@",s1);
                if (i!=nlm.picUrls.count-1) {
                    s_picUrls=[[s_picUrls stringByAppendingString:s1] stringByAppendingString:@"|"];
                }else{
                    s_picUrls=[s_picUrls stringByAppendingString:s1];
                }
                // NSLog(@"s_picUrls:%@",s_picUrls);
                
            }
        }
        const char *picUrls=[s_picUrls UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, programId1, -1, NULL);
        sqlite3_bind_text(stmt, 2, type, -1, NULL);
        sqlite3_bind_text(stmt, 3, articleId, -1, NULL);
        sqlite3_bind_text(stmt, 4, picsId, -1, NULL);
        sqlite3_bind_text(stmt, 5, specialId, -1, NULL);
        sqlite3_bind_text(stmt, 6, videoId, -1, NULL);
        sqlite3_bind_text(stmt, 7, adId, -1, NULL);
        sqlite3_bind_text(stmt, 8, picUrls, -1, NULL);
        sqlite3_bind_text(stmt, 9, title, -1, NULL);
        sqlite3_bind_text(stmt, 10, desc, -1, NULL);
        sqlite3_bind_text(stmt, 11, followNum, -1, NULL);
        sqlite3_bind_text(stmt, 12, adUrl, -1, NULL);
        sqlite3_bind_text(stmt, 13, videoUrl, -1, NULL);
        sqlite3_bind_text(stmt, 14, order, -1, NULL);
        sqlite3_bind_text(stmt, 15, addtime, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"新闻列表插入数据失败！");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"新闻列表插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 更新数据
-(void)updateNlm:(NewListModel *)nlm programId:(NSString *)programId
{
    NSString* str=[NSString stringWithFormat:@"update %@ set type=?,picsId=?,specialId=?,videoId=?,adId=?,picUrls=?,title=?,desc=?,followNum=?,adUrl=?,videoUrl=?,order1=?,addtime=? where articleId='%@' and programId='%@';",_tableName,nlm.articleId,programId];
    
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, nil)==SQLITE_OK)
    {
        NSString *s_picUrls=@"";
        if (nlm.picUrls&&nlm.picUrls.count>0) {
            for (int i=0; i<nlm.picUrls.count; i++) {
                NSString *s1=[nlm.picUrls objectAtIndex:i];
                // NSLog(@"s1:%@",s1);
                if (i!=nlm.picUrls.count-1) {
                    s_picUrls=[[s_picUrls stringByAppendingString:s1] stringByAppendingString:@"|"];
                }else{
                    s_picUrls=[s_picUrls stringByAppendingString:s1];
                }
            }
        }
        sqlite3_bind_text(stmt, 1, nlm.type.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 2, nlm.picsId.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 3, nlm.specialId.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 4, nlm.videoId.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 5, nlm.adId.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 6, s_picUrls.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 7, nlm.title.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 8, nlm.desc.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 9, nlm.followNum.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 10, nlm.adUrl.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 11, nlm.videoUrl.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 12, nlm.order.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 13, nlm.addtime.UTF8String, -1, nil);
        
        if(sqlite3_step(stmt)!=SQLITE_DONE)
        {
            NSLog(@"新闻列表更新数据失败！");
        }
    }
    else
    {
        NSLog(@"新闻列表更新数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 更新或插入数据
-(void)updateOrInsert:(NewListModel*)nlm programId:(NSString *)programId
{
    BOOL isExist = NO;
    NSString *str=[NSString stringWithFormat:@"select * from %@ where articleId='%@' and programId='%@' order by id desc;",_tableName,nlm.articleId,programId];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, NULL)==SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW){
            isExist=YES;
        }
    }
    
    if(isExist){
        [self updateNlm:nlm programId:programId];
    }else{
        [self insertNlm:nlm programId:programId];
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deleteNdmWithProgramId:(NSString *)programId{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (programId='%@');",_tableName,programId];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"新闻列表删除programId:%@数据成功！",programId);
        } else {
            NSLog(@"新闻列表删除数据失败！");
        }
    } else {
        NSLog(@"新闻列表删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查询数据
-(NSMutableArray *)getNewListWithProgramId:(NSString *)programId{
    NSMutableArray *nlms=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ where programId='%@' order by id desc;",_tableName,programId];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
           
            NewListModel *nlm=[[NewListModel alloc] init];
            
            nlm.programId=programId;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            NSString *type=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            nlm.type=type;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            NSString *articleId=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            nlm.articleId=articleId;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            NSString *picsId=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            nlm.picsId=picsId;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            NSString *specialId=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            nlm.specialId=specialId;
            
            char *s6 = (char *)sqlite3_column_text(stmt, 6);
            NSString *videoId=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            nlm.videoId=videoId;
            
            char *s7 = (char *)sqlite3_column_text(stmt, 7);
            NSString *adId=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            nlm.adId=adId;
            
            char *s8 = (char *)sqlite3_column_text(stmt, 8);
            NSString *picUrls=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            nlm.picUrls=[picUrls componentsSeparatedByString: @"|"];

            char *s9 = (char *)sqlite3_column_text(stmt, 9);
            NSString *title=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
            nlm.title=title;
            
            char *s10 = (char *)sqlite3_column_text(stmt, 10);
            NSString *desc=[[NSString alloc] initWithCString:s10 encoding:NSUTF8StringEncoding];
            nlm.desc=desc;
            
            char *s11 = (char *)sqlite3_column_text(stmt, 11);
            NSString *followNum=[[NSString alloc] initWithCString:s11 encoding:NSUTF8StringEncoding];
            nlm.followNum=followNum;
            
            char *s12 = (char *)sqlite3_column_text(stmt, 12);
            NSString *adUrl=[[NSString alloc] initWithCString:s12 encoding:NSUTF8StringEncoding];
            nlm.adUrl=adUrl;
            
            char *s13 = (char *)sqlite3_column_text(stmt, 13);
            NSString *videoUrl=[[NSString alloc] initWithCString:s13 encoding:NSUTF8StringEncoding];
            nlm.videoUrl=videoUrl;
            
            char *s14 = (char *)sqlite3_column_text(stmt, 14);
            NSString *order=[[NSString alloc] initWithCString:s14 encoding:NSUTF8StringEncoding];
            nlm.order=order;
            
            char *s15 = (char *)sqlite3_column_text(stmt, 15);
            NSString *addtime=[[NSString alloc] initWithCString:s15 encoding:NSUTF8StringEncoding];
            nlm.addtime=addtime;
            
            [nlms addObject:nlm];
        }
    }else {
        NSLog(@"查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return nlms;
}


@end
