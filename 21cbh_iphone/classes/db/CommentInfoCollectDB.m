//
//  PicsListDB.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-6.
//  Copyright (c) 2014年 ZX. All rights reserved.

#import "CommentInfoCollectDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"

@interface CommentInfoCollectDB(){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end

@implementation CommentInfoCollectDB

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
    _tableName=@"CommentInfoCollect";
    NSString *className=@"CommentInfoCollectDB";
    //检测是否需要删表
    [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];

    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, progarmID text,followID text,commentID text,commentUserHeadUrl text,commentUserNickName text,commentUserLocation text,commentTopNum text,commentContent text,commentTime text,commentTitle text);",_tableName];
    
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
-(void)insertCim:(CommentInfoModel *)cim{
    
    BOOL b=[self isExistCim:cim];
    if (b) {//如果有数据就不执行插入了
        return;
    }
    
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(progarmID,followID,commentID,commentUserHeadUrl,commentUserNickName,commentUserLocation,commentTopNum,commentContent,commentTime,commentTitle) values(?,?,?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *progarmID=[cim.progarmID UTF8String];
        const char *followID=[cim.followID UTF8String];
        const char *commentID=[cim.commentID UTF8String];
        const char *commentUserHeadUrl=[cim.commentUserHeadUrl UTF8String];
        const char *commentUserNickName=[cim.commentUserNickName UTF8String];
        const char *commentUserLocation=[cim.commentUserLocation UTF8String];
        const char *commentTopNum=[cim.commentTopNum UTF8String];
        const char *commentContent=[cim.commentContent UTF8String];
        const char *commentTime=[cim.commentTime UTF8String];
        const char *commentTitle=[cim.commentTitle UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, progarmID, -1, NULL);
        sqlite3_bind_text(stmt, 2, followID, -1, NULL);
        sqlite3_bind_text(stmt, 3, commentID, -1, NULL);
        sqlite3_bind_text(stmt, 4, commentUserHeadUrl, -1, NULL);
        sqlite3_bind_text(stmt, 5, commentUserNickName, -1, NULL);
        sqlite3_bind_text(stmt, 6, commentUserLocation, -1, NULL);
        sqlite3_bind_text(stmt, 7, commentTopNum, -1, NULL);
        sqlite3_bind_text(stmt, 8, commentContent, -1, NULL);
        sqlite3_bind_text(stmt, 9, commentTime, -1, NULL);
        sqlite3_bind_text(stmt, 10, commentTitle, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"评论收藏列表插入数据失败！");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"评论收藏列表插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deleteCim:(CommentInfoModel *)cim{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (progarmID='%@' and followID='%@' and commentID='%@');",_tableName,cim.progarmID,cim.followID,cim.commentID];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"评论收藏列表删除commentID:%@数据成功！",cim.commentID);
        } else {
            NSLog(@"评论收藏列表删除数据失败！");
        }
    } else {
        NSLog(@"评论收藏列表删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查询数据
-(NSMutableArray *)getCims{
    NSMutableArray *cims=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ order by id desc;",_tableName];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            CommentInfoModel *cim=[[CommentInfoModel alloc] init];
            char *s1 = (char *)sqlite3_column_text(stmt, 1);
            NSString *progarmID=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            cim.progarmID=progarmID;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            NSString *followID=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            cim.followID=followID;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            NSString *commentID=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            cim.commentID=commentID;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            NSString *commentUserHeadUrl=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            cim.commentUserHeadUrl=commentUserHeadUrl;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            NSString *commentUserNickName=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            cim.commentUserNickName=commentUserNickName;
            
            char *s6 = (char *)sqlite3_column_text(stmt, 6);
            NSString *commentUserLocation=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            cim.commentUserLocation=commentUserLocation;
            
            char *s7 = (char *)sqlite3_column_text(stmt, 7);
            NSString *commentTopNum=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            cim.commentTopNum=commentTopNum;
            
            char *s8 = (char *)sqlite3_column_text(stmt, 8);
            NSString *commentContent=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            cim.commentContent=commentContent;
            
            char *s9 = (char *)sqlite3_column_text(stmt, 9);
            NSString *commentTime=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
            cim.commentTime=commentTime;
            
            char *s10= (char *)sqlite3_column_text(stmt, 10);
            NSString *commentTitle=[[NSString alloc] initWithCString:s10 encoding:NSUTF8StringEncoding];
            cim.commentTitle=commentTitle;
            
            [cims addObject:cim];
            
        }
        
    }else {
        
        NSLog(@"评论收藏列表查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return cims;
}


#pragma mark 查看数据否存在
-(BOOL)isExistCim:(CommentInfoModel *)cim{
    bool b=NO;
    NSString *string=[NSString stringWithFormat:@"select * from %@ where progarmID='%@' and followID='%@' and commentID='%@' order by id desc;",_tableName,cim.progarmID,cim.followID,cim.commentID];
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
        
        NSLog(@"评论收藏列表查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return b;
}


@end
