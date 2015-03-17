//
//  TopPicDB.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "TopPicDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"

@interface TopPicDB(){
    
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
    
}

@end

@implementation TopPicDB

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
    _tableName=@"TopPic";
    NSString *className=@"TopPicDB";
    //检测是否需要删表
    [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, programId text,picUrl text,desc text,type text,articleId text,specialId text,picsId text,videoId text,adId text,adUrl text,videoUrl text,addtime text);",_tableName];
    
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
-(void)insertTpm:(TopPicModel *)tpm programId:(NSString *)programId{
    
    //@"create table if not exists %@(id integer primary key autoincrement, programId text,picUrl text,desc text,type text,articleId text,specialId text,picsId text,videoId text,adId text,adUrl text,videoUrl text);"
    
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(programId,picUrl,desc,type,articleId,specialId,picsId,videoId,adId,adUrl,videoUrl,addtime) values(?,?,?,?,?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *programId1=[programId UTF8String];
        const char *picUrl=[tpm.picUrl UTF8String];
        const char *desc=[tpm.desc UTF8String];
        const char *type=[tpm.type UTF8String];
        const char *articleId=[tpm.articleId UTF8String];
        const char *specialId=[tpm.specialId UTF8String];
        const char *picsId=[tpm.picsId UTF8String];
        const char *videoId=[tpm.videoId UTF8String];
        const char *adId=[tpm.adId UTF8String];
        const char *adUrl=[tpm.adUrl UTF8String];
        const char *videoUrl=[tpm.videoUrl UTF8String];
        const char *addtime=[tpm.addtime UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, programId1, -1, NULL);
        sqlite3_bind_text(stmt, 2, picUrl, -1, NULL);
        sqlite3_bind_text(stmt, 3, desc, -1, NULL);
        sqlite3_bind_text(stmt, 4, type, -1, NULL);
        sqlite3_bind_text(stmt, 5, articleId, -1, NULL);
        sqlite3_bind_text(stmt, 6, specialId, -1, NULL);
        sqlite3_bind_text(stmt, 7, picsId, -1, NULL);
        sqlite3_bind_text(stmt, 8, videoId, -1, NULL);
        sqlite3_bind_text(stmt, 9, adId, -1, NULL);
        sqlite3_bind_text(stmt, 10, adUrl, -1, NULL);
        sqlite3_bind_text(stmt, 11, videoUrl, -1, NULL);
        sqlite3_bind_text(stmt, 12, addtime, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"插入数据失败！");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"头图插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deleteTpmWithProgramId:(NSString *)programId{
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
            NSLog(@"头图删除programId:%@数据成功！",programId);
        } else {
            NSLog(@"头图删除数据失败！");
        }
    } else {
        NSLog(@"头图删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查询数据
-(NSMutableArray *)getTopPicsWithProgramId:(NSString *)programId{
    NSMutableArray *tpms=[NSMutableArray array];
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
            
            TopPicModel *tpm=[[TopPicModel alloc] init];
            
           
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            NSString *picUrl=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            tpm.picUrl=picUrl;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            NSString *desc=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            tpm.desc=desc;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            NSString *type=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            tpm.type=type;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            NSString *articleId=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            tpm.articleId=articleId;
            
            char *s6 = (char *)sqlite3_column_text(stmt, 6);
            NSString *specialId=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            tpm.specialId=specialId;
            
            char *s7 = (char *)sqlite3_column_text(stmt, 7);
            NSString *picsId=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            tpm.picsId=picsId;
            
            char *s8 = (char *)sqlite3_column_text(stmt, 8);
            NSString *videoId=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            tpm.videoId=videoId;
            
            char *s9 = (char *)sqlite3_column_text(stmt, 9);
            NSString *adId=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
            tpm.adId=adId;
            
            char *s10 = (char *)sqlite3_column_text(stmt, 10);
            NSString *adUrl=[[NSString alloc] initWithCString:s10 encoding:NSUTF8StringEncoding];
            tpm.adUrl=adUrl;
            
            char *s11 = (char *)sqlite3_column_text(stmt, 11);
            NSString *videoUrl=[[NSString alloc] initWithCString:s11 encoding:NSUTF8StringEncoding];
            tpm.videoUrl=videoUrl;
            
            char *s12 = (char *)sqlite3_column_text(stmt, 12);
            NSString *addtime=[[NSString alloc] initWithCString:s12 encoding:NSUTF8StringEncoding];
            tpm.addtime=addtime;
            
            [tpms addObject:tpm];
            
        }
        
    }else {
        
        NSLog(@"查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return tpms;
}





@end
