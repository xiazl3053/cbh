//
//  NewsDetailDB.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewsDetailDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"

@interface NewsDetailDB(){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end

@implementation NewsDetailDB

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
    _tableName=@"newsDetail";
    NSString *className=@"NewsDetailDB";
    //检测是否需要删表
    [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, programId text,type text,articleId text,followNum text,title text,articUrl text,template text,picUrls text,sharePic text,descs text,addtime text,breif text);",_tableName];
    
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
-(void)insertNdm:(NewsDetailModel *)ndm{
    
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(programId,type,articleId,followNum,title,articUrl,template,picUrls,sharePic,descs,addtime,breif) values(?,?,?,?,?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *programId=[ndm.programId UTF8String];
        const char *type=[ndm.type UTF8String];
        const char *articleId=[ndm.articleId UTF8String];
        const char *followNum=[ndm.followNum UTF8String];
        const char *title=[ndm.title UTF8String];
        const char *articUrl=[ndm.articUrl UTF8String];
        const char *template=[ndm.template UTF8String];
        const char *sharePic=[ndm.sharePic UTF8String];
        const char *addtime=[ndm.addtime UTF8String];
        const char *breif=[ndm.breif UTF8String];
        
        NSString *s_picUrls=@"";
        if (ndm.picUrls&&ndm.picUrls.count>0) {
            for (int i=0; i<ndm.picUrls.count; i++) {
                NSString *s1=[ndm.picUrls objectAtIndex:i];
                // NSLog(@"s1:%@",s1);
                if (i!=ndm.picUrls.count-1) {
                    s_picUrls=[[s_picUrls stringByAppendingString:s1] stringByAppendingString:@"|"];
                }else{
                    s_picUrls=[s_picUrls stringByAppendingString:s1];
                }
                // NSLog(@"s_picUrls:%@",s_picUrls);
                
            }
        }
        const char *picUrls=[s_picUrls UTF8String];
        
        NSString *s_descs=@"";
        if (ndm.descs&&ndm.descs.count>0) {
            for (int i=0; i<ndm.descs.count; i++) {
                NSString *s1=[ndm.descs objectAtIndex:i];
                // NSLog(@"s1:%@",s1);
                if (i!=ndm.descs.count-1) {
                    s_descs=[[s_descs stringByAppendingString:s1] stringByAppendingString:@"|"];
                }else{
                    s_descs=[s_descs stringByAppendingString:s1];
                }
                // NSLog(@"s_picUrls:%@",s_picUrls);
                
            }
        }
        const char *descs=[s_descs UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, programId, -1, NULL);
        sqlite3_bind_text(stmt, 2, type, -1, NULL);
        sqlite3_bind_text(stmt, 3, articleId, -1, NULL);
        sqlite3_bind_text(stmt, 4, followNum, -1, NULL);
        sqlite3_bind_text(stmt, 5, title, -1, NULL);
        sqlite3_bind_text(stmt, 6, articUrl, -1, NULL);
        sqlite3_bind_text(stmt, 7, template, -1, NULL);
        sqlite3_bind_text(stmt, 8, picUrls, -1, NULL);
        sqlite3_bind_text(stmt, 9, sharePic, -1, NULL);
        sqlite3_bind_text(stmt, 10, descs, -1, NULL);
        sqlite3_bind_text(stmt, 11, addtime, -1, NULL);
        sqlite3_bind_text(stmt, 12, breif, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"插入数据失败！");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"新闻详情页插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deleteNdm:(NSString *)articleId{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (articleId='%@');",_tableName,articleId];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"删除articleId:%@数据成功！",articleId);
        } else {
            NSLog(@"删除数据失败！");
        }
    } else {
        NSLog(@"新闻详情页删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查询数据
-(NewsDetailModel *)getNdmWith:(NSString *)articleId{
    NewsDetailModel *ndm=[[NewsDetailModel alloc] init];
    //select * from pet where (birth>'1980' and species='dog') or species='bird'
    NSString *string=[NSString stringWithFormat:@"select * from %@ where articleId='%@' order by id desc;",_tableName,articleId];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            char *s1 = (char *)sqlite3_column_text(stmt, 1);
            NSString *programId=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            ndm.programId=programId;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            NSString *type=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            ndm.type=type;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            NSString *articleId=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            ndm.articleId=articleId;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            NSString *followNum=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            ndm.followNum=followNum;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            NSString *title=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            ndm.title=title;
            
            char *s6 = (char *)sqlite3_column_text(stmt, 6);
            NSString *articUrl=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            ndm.articUrl=articUrl;
            
            char *s7= (char *)sqlite3_column_text(stmt, 7);
            NSString *template=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            ndm.template=template;
            
            char *s8 = (char *)sqlite3_column_text(stmt, 8);
            NSString *picUrls=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            ndm.picUrls=[picUrls componentsSeparatedByString: @"|"];
            
            char *s9= (char *)sqlite3_column_text(stmt, 9);
            NSString *sharePic=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
            ndm.sharePic=sharePic;
            
            char *s10 = (char *)sqlite3_column_text(stmt, 10);
            NSString *descs=[[NSString alloc] initWithCString:s10 encoding:NSUTF8StringEncoding];
            ndm.descs=[descs componentsSeparatedByString: @"|"];
            
            char *s11= (char *)sqlite3_column_text(stmt, 11);
            NSString *addtime=[[NSString alloc] initWithCString:s11 encoding:NSUTF8StringEncoding];
            ndm.addtime=addtime;
            
            char *s12= (char *)sqlite3_column_text(stmt, 12);
            NSString *breif=[[NSString alloc] initWithCString:s12 encoding:NSUTF8StringEncoding];
            ndm.breif=breif;
        }
    }else {
        NSLog(@"查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return ndm;
}



@end
