//
//  PicDetailDB.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PicDetailDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"

@interface PicDetailDB(){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end

@implementation PicDetailDB

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
    _tableName=@"PicDetail";
    NSString *className=@"PicDetailDB";
    //检测是否需要删表
    [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, hostPicsId text,desc text,picUrls text);",_tableName];
    
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
-(void)insertPdm:(PicDetailModel *)pdm hostPicsId:(NSString *)hostPicsId{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(hostPicsId,desc,picUrls) values(?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *hostPicsId1=[hostPicsId UTF8String];
        const char *desc=[pdm.desc UTF8String];
        
        NSString *s_picUrls=@"";
        if (pdm.picUrls&&pdm.picUrls.count>0) {
            for(int i=0; i<pdm.picUrls.count; i++) {
                NSString *s1=[pdm.picUrls objectAtIndex:i];
                // NSLog(@"s1:%@",s1);
                if (i!=pdm.picUrls.count-1) {
                    s_picUrls=[[s_picUrls stringByAppendingString:s1] stringByAppendingString:@"|"];
                }else{
                    s_picUrls=[s_picUrls stringByAppendingString:s1];
                }
                
            }
        }
        const char *picUrls=[s_picUrls UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, hostPicsId1, -1, NULL);
        sqlite3_bind_text(stmt, 2, desc, -1, NULL);
        sqlite3_bind_text(stmt, 3, picUrls, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"图集详情插入数据失败！");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"图集详情插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deletePdmWithHostPicsId:(NSString *)hostPicsId{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (hostPicsId='%@');",_tableName,hostPicsId];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"图集详情删除hostPicsId:%@数据成功！",hostPicsId);
        } else {
            NSLog(@"图集详情删除数据失败！");
        }
    } else {
        NSLog(@"图集详情删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查询数据
-(NSMutableArray *)getPdmsWithHostPicsId:(NSString *)hostPicsId{
    NSMutableArray *pdms=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ where hostPicsId='%@' order by id desc;",_tableName,hostPicsId];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            PicDetailModel *pdm=[[PicDetailModel alloc] init];
            //picsId,type,title,followNum,picUrls,order,addtime
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            NSString *desc=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            pdm.desc=desc;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            NSString *picUrls=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            pdm.picUrls=[picUrls componentsSeparatedByString: @"|"];
            
            [pdms addObject:pdm];
        }
        
    }else {
        
        NSLog(@"图集详情查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return pdms;
}

@end
