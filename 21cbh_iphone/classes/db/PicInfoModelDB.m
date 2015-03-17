//
//  PicInfoModelDB.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PicInfoModelDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"

@interface PicInfoModelDB(){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end

@implementation PicInfoModelDB

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
    _tableName=@"PicInfo";
    NSString *className=@"PicInfoModelDB";
    //检测是否需要删表
    [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, programId text,picsId text,title text,sharePic text,shareUrl text);",_tableName];
    
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
-(void)insertPim:(PicInfoModel *)pim{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(programId,picsId,title,sharePic,shareUrl) values(?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;

    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *programId=[pim.programId UTF8String];
        const char *picsId=[pim.picsId UTF8String];
        const char *title=[pim.title UTF8String];
        const char *sharePic=[pim.sharePic UTF8String];
        const char *shareUrl=[pim.shareUrl UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, programId, -1, NULL);
        sqlite3_bind_text(stmt, 2, picsId, -1, NULL);
        sqlite3_bind_text(stmt, 3, title, -1, NULL);
        sqlite3_bind_text(stmt, 4, sharePic, -1, NULL);
        sqlite3_bind_text(stmt, 5, shareUrl, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"图集信息插入数据失败！");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"图集信息插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}


#pragma mark 删除数据
-(void)deletePim:(PicInfoModel *)pim{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (programId='%@' and picsId='%@');",_tableName,pim.programId,pim.picsId];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"图集信息删除PicsId:%@数据成功！",pim.picsId);
        } else {
            NSLog(@"图集信息删除数据失败！");
        }
    } else {
        NSLog(@"图集信息删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}


#pragma mark 查询数据
-(NSMutableArray *)getPimWithProgramId:(NSString *)programId picsId:(NSString *)picsId{
    NSMutableArray *pims=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ where (programId='%@' and picsId='%@') order by id desc;",_tableName,programId,picsId];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            PicInfoModel *pim=[[PicInfoModel alloc] init];
            //picsId,type,title,followNum,picUrls,order,addtime
            pim.programId=programId;
            pim.picsId=picsId;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            NSString *title=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            pim.title=title;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            NSString *sharePic=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            pim.sharePic=sharePic;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            NSString *shareUrl=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            pim.shareUrl=shareUrl;
            
            [pims addObject:pim];
        }
        
    }else {
        
        NSLog(@"图集信息查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    
    return pims;
}



@end
