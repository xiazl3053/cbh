//
//  ERoomsDB.m
//  21cbh_iphone
//
//  Created by qinghua on 14-8-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ERoomsDB.h"
#import <sqlite3.h>
#import "NSString+File.h"
#import "CommonOperation.h"
#import "ERoom.h"

static ERoomsDB *instance;

@interface ERoomsDB (){
    
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
    
}
@end

@implementation ERoomsDB

+(ERoomsDB *)sharedInstance
{
    @synchronized(self){
        if(!instance){
            instance=[[ERoomsDB alloc]init];
        }
        return instance;
    }
}


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
    _tableName=@"ERooms";
    NSString *className=@"ERoomsDB";
    //检测是否需要删表
   // [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(room_jid text primary key, myJID text,room_name text,room_desc text,room_icon text,room_isShield integer);",_tableName];
    
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
-(void)insertWithRoom:(ERoom *)room{
    room.icon=[NSString stringWithFormat:@"%@",@"http://www.baidu.com"];
    //    //已存在
    if ([self isExistRoom:room]) {
            return ;
        }
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(room_jid,myJID,room_name,room_desc,room_icon,room_isShield) values(?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *myJID=[room.myJID UTF8String];
        const char *room_jid=[room.jid UTF8String];
        const char *room_name=[room.name UTF8String];
        const char *room_desc=[room.desc UTF8String];
        const char *room_icon=[room.icon UTF8String];
        const char *room_isShield=[[NSString stringWithFormat:@"%d",room.isShield]UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, room_jid, -1, NULL);
        sqlite3_bind_text(stmt, 2, myJID, -1, NULL);
        sqlite3_bind_text(stmt, 3, room_name, -1, NULL);
        sqlite3_bind_text(stmt, 4, room_desc, -1, NULL);
        sqlite3_bind_text(stmt, 5, room_icon, -1, NULL);
        sqlite3_bind_text(stmt, 6, room_isShield, -1, NULL);
        
        
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"插入好友数据失败！");
        } else {
            NSLog(@"插入好友数据成功！");
        }
    } else {
        NSLog(@"插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deleteWithRoom:(ERoom *)room{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (myJID='%@' and room_jid='%@');",_tableName,room.myJID,room.jid];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"删除friends_jid:%@数据成功！",room.jid);
        } else {
            NSLog(@"删除数据失败！");
        }
    } else {
        NSLog(@"删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 更新数据
-(void)updateWithRoom:(ERoom *)room{
        
        NSString* str=[NSString stringWithFormat:@"update %@ set room_jid=?,myJID=?,room_name=?,room_desc=?,room_icon=?,room_isShield=? where room_jid='%@';",_tableName,room.jid];
        
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, NULL)==SQLITE_OK)
        {
            const char *room_jid=[room.jid UTF8String];
            const char *myJID=[room.myJID UTF8String];
            const char *room_name=[room.name UTF8String];
            const char *room_desc=[room.desc UTF8String];
            const char *room_icon=[room.icon UTF8String];
            const char *room_isShield=[[NSString stringWithFormat:@"%d",room.isShield]UTF8String];
            
            // 第2个int类型的参数用来指定第几列，从1开始
            sqlite3_bind_text(stmt, 1, room_jid, -1, NULL);
            sqlite3_bind_text(stmt, 2, myJID, -1, NULL);
            sqlite3_bind_text(stmt, 3, room_name, -1, NULL);
            sqlite3_bind_text(stmt, 4, room_desc, -1, NULL);
            sqlite3_bind_text(stmt, 5, room_icon, -1, NULL);
            sqlite3_bind_text(stmt, 6, room_isShield, -1, NULL);
            
            if(sqlite3_step(stmt)!=SQLITE_DONE)
            {
                NSLog(@"更新数据失败！");
            }
        }
        else
        {
            NSLog(@"更新数据的SQL语句语法有问题");
        }
        
        sqlite3_finalize(stmt);
}
    
    
#pragma mark -好友是否存在
-(BOOL)isExistRoom:(ERoom *)room{
        BOOL b=NO;
        NSString *string=[NSString stringWithFormat:@"select * from %@ where myJID='%@' and room_jid='%@' order by id desc;",_tableName,room.myJID,room.jid];
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
            
            NSLog(@"该群不存在！！！！");
        }
        sqlite3_finalize(stmt);
        return b;
    }
    
#pragma mark -查询好友信息
-(ERoom *)getRoomWithJID:(NSString *)roomJid{
        NSString *string=[NSString stringWithFormat:@"select * from %@ where room_jid='%@' order by room_jid desc;",_tableName,roomJid];
        const char *sql = [string UTF8String];
        
        sqlite3_stmt *stmt;
        
        ERoom *f=nil;
        // sqlite3_prepare_v2做一些插入数据的准备
        // 主要是检查SQL语句的语法问题
        int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
        // 说明语句没有语法问题
        if (result == SQLITE_OK) {
            // 如果返回值是ROW,代表读取到一行数据
            while (sqlite3_step(stmt) == SQLITE_ROW){
                
                f=[[ERoom alloc] init];
                
                char *s1 = (char *)sqlite3_column_text(stmt, 0);
                NSString *friends_jID=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
                f.jid = friends_jID;
                
                char *s2 = (char *)sqlite3_column_text(stmt, 1);
                NSString *myJID=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
                f.myJID = myJID;
                
                
                char *s3 = (char *)sqlite3_column_text(stmt, 2);
                NSString *name=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
                f.name = name;
                
                char *s4 = (char *)sqlite3_column_text(stmt, 3);
                NSString *desc=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
                f.desc = desc;
                
                char *s5 = (char *)sqlite3_column_text(stmt, 4);
                NSString *icon=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
                f.icon = icon;
                
                char *s6 = (char *)sqlite3_column_text(stmt, 5);
                NSString *isShield=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
                f.isShield = [isShield intValue];
                
            }
        }else {
            NSLog(@"ERoomDB------查询数据的SQL语句语法有问题");
        }
        sqlite3_finalize(stmt);
        
        return f;
    }
    
#pragma mark 查询数据
-(NSMutableArray *)getRoomsWithMyJID:(NSString *)myJID{
        NSMutableArray *array=[NSMutableArray array];
        NSString *string=[NSString stringWithFormat:@"select * from %@ where myJID='%@' order by room_jid desc;",_tableName,myJID];
        const char *sql = [string UTF8String];
        
        sqlite3_stmt *stmt;
        // sqlite3_prepare_v2做一些插入数据的准备
        // 主要是检查SQL语句的语法问题
        int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
        // 说明语句没有语法问题
        if (result == SQLITE_OK) {
            // 如果返回值是ROW,代表读取到一行数据
            while (sqlite3_step(stmt) == SQLITE_ROW){
                
                ERoom *f=[[ERoom alloc] init];
                
                char *s1 = (char *)sqlite3_column_text(stmt, 0);
                NSString *friends_jID=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
                f.jid = friends_jID;
                
                char *s2 = (char *)sqlite3_column_text(stmt, 1);
                NSString *myJID=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
                f.myJID = myJID;
                
                char *s3 = (char *)sqlite3_column_text(stmt, 2);
                NSString *name=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
                f.name = name;
                
                char *s4 = (char *)sqlite3_column_text(stmt, 3);
                NSString *desc=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
                f.desc = desc;
                
                char *s5 = (char *)sqlite3_column_text(stmt, 4);
                NSString *icon=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
                f.icon = icon;
                
                char *s6 = (char *)sqlite3_column_text(stmt, 5);
                NSString *isShield=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
                f.isShield = [isShield intValue];
                
                [array addObject:f];
            }
        }else {
            NSLog(@"-------ERoomsDB-----查询数据的SQL语句语法有问题");
        }
        sqlite3_finalize(stmt);
        return array;
    }
    



@end
