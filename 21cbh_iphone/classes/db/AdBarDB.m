//
//  AdBarDB.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-5.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "AdBarDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"


@interface AdBarDB(){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end

@implementation AdBarDB

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
    _tableName=@"AdBar";
    NSString *className=@"AdBarDB";
    //检测是否需要删表
    [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, adId text);",_tableName];
    
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
-(void)insertWithAdBar:(AdBarModel *)adBar{
    
    //@"create table if not exists %@(id integer primary key autoincrement, programId text,picUrl text,desc text,type text,articleId text,specialId text,picsId text,videoId text,adId text,adUrl text,videoUrl text);"
    
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(adId) values(?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *adId=[adBar.adId UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, adId, -1, NULL);

        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"广告栏插入数据失败");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"广告栏插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deleteAdBar:(AdBarModel *)adBar{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (adId='%@');",_tableName,adBar.adId];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"删除adBar.adId:%@数据成功！",adBar.adId);
        } else {
            NSLog(@"删除数据失败！");
        }
    } else {
        NSLog(@"广告栏删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查看广告栏的广告是否存在
-(BOOL)isExistAdBar:(AdBarModel *)adBar{
    bool b=NO;
    NSString *string=[NSString stringWithFormat:@"select * from %@ where adId='%@' order by id desc;",_tableName,adBar.adId];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            b=YES;
            
        }
        
    }else {
        
        NSLog(@"广告栏查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return b;
}



@end
