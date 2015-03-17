//
//  EFriendsDB.m
//  21cbh_iphone
//
//  Created by 21tech on 14-6-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "EFriendsDB.h"
#import <sqlite3.h>
#import "NSString+File.h"
#import "CommonOperation.h"
#import "EFriends.h"


#define  KUserIconPrefix @"http://image.baidu.com/detail/newindex?col=摄影&tag=唯美&pn=5&pid=11668233980&aid=401471796&user_id=992488454&setid=1126&sort=0&from=1"

static EFriendsDB *instance;

@interface EFriendsDB (){

    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;

}
@end

@implementation EFriendsDB


+(EFriendsDB *)sharedEFriends
{
    @synchronized(self){
        if(!instance){
            instance=[[EFriendsDB alloc]init];
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
    _tableName=@"EFriends";
   // NSString *className=@"EFriendsDB";
    //检测是否需要删表
   // [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(friends_jid text primary key,myJID text,friends_name text,friends_nickName text,friends_iconUrl text,friends_isShield integer,friends_isTop integer,friends_isFriend integer,friends_reMark text);",_tableName];
    
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
-(void)insertWithFriend:(EFriends *)friend{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(friends_jid,myJID,friends_name,friends_nickName,friends_iconUrl,friends_isShield,friends_isTop,friends_isFriend,friends_reMark) values(?,?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *myJID=[friend.myJID UTF8String];
        const char *friends_jid=[friend.jid UTF8String];
        const char *friends_name=[friend.userName UTF8String];
        const char *friends_nickName=[friend.nickName UTF8String];
        const char *friends_iconUrl=[friend.iconUrl UTF8String];
        const char *friends_isShield=[[NSString stringWithFormat:@"%d",friend.isShield] UTF8String];
        const char *friends_isTop=[[NSString stringWithFormat:@"%d",friend.isTop] UTF8String];
        const char *friends_isFriend=[[NSString stringWithFormat:@"%d",friend.isFriend] UTF8String];
      //  const char *friends_reMark=[friend.remark UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, friends_jid, -1, NULL);
        sqlite3_bind_text(stmt, 2, myJID, -1, NULL);
        sqlite3_bind_text(stmt, 3, friends_name, -1, NULL);
        sqlite3_bind_text(stmt, 4, friends_nickName, -1, NULL);
        sqlite3_bind_text(stmt, 5, friends_iconUrl, -1, NULL);
        sqlite3_bind_text(stmt, 6, friends_isShield, -1, NULL);
        sqlite3_bind_text(stmt, 7, friends_isTop, -1, NULL);
        sqlite3_bind_text(stmt, 8, friends_isFriend, -1, NULL);
       // sqlite3_bind_text(stmt, 9, friends_reMark, -1, NULL);
        
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"EFriendsDB----插入好友数据失败！");
        } else {
            NSLog(@"EFriendsDB----插入好友数据成功！");
        }
    } else {
        NSLog(@"EFriendsDB----插入好友数据的SQL语句语法有问题");
    }
    
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deleteWithFriend:(EFriends *)friend{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (myJID='%@' and friends_jid='%@');",_tableName,friend.myJID,friend.jid];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"EFriendsDB----删除friends_jid:%@数据成功！",friend.jid);
        } else {
            NSLog(@"EFriendsDB----删除数据失败！");
        }
    } else {
        NSLog(@"EFriendsDB------删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 更新数据
-(void)updateWithFriend:(EFriends *)friend
{
    NSString* str=[NSString stringWithFormat:@"update %@ set friends_jid=?,myJID=?,friends_name=?,friends_nickName=?,friends_iconUrl=?,friends_isShield=?,friends_isTop=?,friends_isFriend=?,friends_reMark=? where friends_jid='%@';",_tableName,friend.jid];
    
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, NULL)==SQLITE_OK)
    {
        const char *myJID=[friend.myJID UTF8String];
        const char *friends_jid=[friend.jid UTF8String];
        const char *friends_name=[friend.userName UTF8String];
        const char *friends_nickName=[friend.nickName UTF8String];
        const char *friends_iconUrl=[friend.iconUrl UTF8String];
        const char *friends_isShield=[[NSString stringWithFormat:@"%d",friend.isShield] UTF8String];
        const char *friends_isTop=[[NSString stringWithFormat:@"%d",friend.isTop] UTF8String];
        const char *friends_isFriend=[[NSString stringWithFormat:@"%d",friend.isFriend] UTF8String];
       // const char *friends_reMark=[friend.remark UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, friends_jid, -1, NULL);
        sqlite3_bind_text(stmt, 2, myJID, -1, NULL);
        sqlite3_bind_text(stmt, 3, friends_name, -1, NULL);
        sqlite3_bind_text(stmt, 4, friends_nickName, -1, NULL);
        sqlite3_bind_text(stmt, 5, friends_iconUrl, -1, NULL);
        sqlite3_bind_text(stmt, 6, friends_isShield, -1, NULL);
        sqlite3_bind_text(stmt, 7, friends_isTop, -1, NULL);
        sqlite3_bind_text(stmt, 8, friends_isFriend, -1, NULL);
      //  sqlite3_bind_text(stmt, 9, friends_reMark, -1, NULL);
        
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"EFriendsDB----更新好友数据失败！");
        } else {
            NSLog(@"EFriendsDB----更新好友数据成功！");
        }
    }
    else
    {
        NSLog(@"EFriendsDB------更新数据的SQL语句语法有问题");
    }    
    sqlite3_finalize(stmt);
}

#pragma mark -好友是否存在
-(BOOL)isExistFriends:(EFriends *)friend{
    BOOL b=NO;
        NSString *string=[NSString stringWithFormat:@"select * from %@ where myJID='%@' and friends_jid='%@';",_tableName,friend.myJID,friend.jid];
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
        
        NSLog(@"该好友不存在！！！！");
    }
    sqlite3_finalize(stmt);
    return b;
}

#pragma mark -查询好友信息
-(EFriends *)getFriendsWithJID:(NSString*)JID{
    NSString *string=[NSString stringWithFormat:@"select * from %@ where friends_jid='%@' order by friends_jid desc;",_tableName,JID];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    
    EFriends *f=[[EFriends alloc] init];
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            char *s1 = (char *)sqlite3_column_text(stmt, 0);
            NSString *friends_jID=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            f.jid = friends_jID;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 1);
            NSString *myJID=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            f.myJID = myJID;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 2);
            NSString *friends_userName=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            f.userName = friends_userName;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 3);
            NSString *friends_nickName=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            f.nickName = friends_nickName;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 4);
            NSString *friends_iconUrl=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            f.iconUrl = friends_iconUrl;
            
            char *s6 = (char *)sqlite3_column_text(stmt, 5);
            NSString *friends_isShield=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            f.isShield = [friends_isShield intValue];
            
            char *s7 = (char *)sqlite3_column_text(stmt, 6);
            NSString *friends_isTop=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            f.isTop = [friends_isTop intValue];
            
            char *s8 = (char *)sqlite3_column_text(stmt, 7);
            NSString *friends_isFriend=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            f.isFriend = [friends_isFriend intValue];
            
//            char *s9 = (char *)sqlite3_column_text(stmt, 8);
//            NSString *friends_reMark=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
//            f.remark = friends_reMark;
            
        }
    }else {
        NSLog(@"EFriendsDB------查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    
    return f;
}

#pragma mark 查询数据
-(NSMutableArray *)getFriendsWithMyJID:(NSString*)myJID{
    NSMutableArray *array=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ where myJID='%@' and friends_isFriend='%d';",_tableName,myJID,1];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            EFriends *f=[[EFriends alloc] init];
        
            char *s1 = (char *)sqlite3_column_text(stmt, 0);
            NSString *friends_jID=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            f.jid = friends_jID;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 1);
            NSString *myJID=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            f.myJID = myJID;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 2);
            NSString *friends_userName=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            f.userName = friends_userName;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 3);
            NSString *friends_nickName=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            f.nickName = friends_nickName;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 4);
            NSString *friends_iconUrl=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            f.iconUrl = friends_iconUrl;
            
            char *s6 = (char *)sqlite3_column_text(stmt, 5);
            NSString *friends_isShield=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            f.isShield = [friends_isShield intValue];
            
            char *s7 = (char *)sqlite3_column_text(stmt, 6);
            NSString *friends_isTop=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            f.isTop = [friends_isTop intValue];
            
            char *s8 = (char *)sqlite3_column_text(stmt, 7);
            NSString *friends_isFriend=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            f.isFriend = [friends_isFriend intValue];
            
            
//            char *s9 = (char *)sqlite3_column_text(stmt, 8);
//            NSString *friends_reMark=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
//            f.remark = friends_reMark;
            
        
            [array addObject:f];
        }
    }else {
        NSLog(@"EFriendsDB------查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return array;
}


@end
