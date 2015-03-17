//
//  EGroupsDB.m
//  21cbh_iphone
//
//  Created by qinghua on 14-8-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ERoomMemberDB.h"
#import <sqlite3.h>
#import "NSString+File.h"
#import "CommonOperation.h"
#import "EFriends.h"
#import "ERoomMemberModel.h"
#import "XMPPServer.h"

@interface ERoomMemberDB (){
    
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
    
}
@end

@implementation ERoomMemberDB

static ERoomMemberDB *instance;


+(ERoomMemberDB *)sharedInstance
{
    @synchronized(self){
        if(!instance){
            instance=[[ERoomMemberDB alloc]init];
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
    _tableName=@"ERoomMembers";
    NSString *className=@"ERoomMemberDB";
    //检测是否需要删表
    //[[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(friends_jid text,roomJID text ,myJID text,friends_name text,friends_nickName text,friends_iconUrl text,primary key(friends_jid,roomJID));",_tableName];
    
    const char *sql =[string UTF8String];
    
    char *error;
    // sqlite3_exec能执行一切SQL语句
    // insert into t_person(name, age) values('mj', 10);
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    
    if (result == SQLITE_OK) {
        NSLog(@"------ERoomMemberDB---创表成功!");
    }else{
        NSLog(@"------ERoomMemberDB---创表错误：%s", error);
    }
}

#pragma mark 插入数据
-(void)insertWithMember:(ERoomMemberModel *)member{

    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(friends_jid,roomJID,myJID,friends_name,friends_nickName,friends_iconUrl) values(?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);

    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        
        const char *friends_jid=[member.member.jid UTF8String];
        const char *roomJID=[member.roomJid UTF8String];
        const char *myJID=[member.member.myJID UTF8String];
        const char *friends_name=[member.member.userName UTF8String];
        const char *friends_nickName=[member.member.nickName UTF8String];
        const char *friends_iconUrl=[member.member.iconUrl UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        
        sqlite3_bind_text(stmt, 1, friends_jid, -1, NULL);
        sqlite3_bind_text(stmt, 2, roomJID, -1, NULL);
        sqlite3_bind_text(stmt, 3, myJID, -1, NULL);
        sqlite3_bind_text(stmt, 4, friends_name, -1, NULL);
        sqlite3_bind_text(stmt, 5, friends_nickName, -1, NULL);
        sqlite3_bind_text(stmt, 6, friends_iconUrl, -1, NULL);
        
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"------ERoomMemberDB---插入群成员数据失败！");
            NSLog(@"sqlite3_step(stmt) =%i",sqlite3_step(stmt));
        } else {
            NSLog(@"------ERoomMemberDB---插入群成员数据成功！");
        }
    } else {
        NSLog(@"--------ERoomMemberDB------插入数据的SQL语句语法有问题");
    }
    
    
    sqlite3_finalize(stmt);
}


-(void)insertWithMemberList:(NSArray *)memberList{
    
    NSMutableString *string=[NSMutableString stringWithFormat:@"insert into %@(friends_jid,roomJID,myJID,friends_name,friends_nickName,friends_iconUrl)",_tableName];

    for (int i=0; i<memberList.count-1; i++) {
        
        ERoomMemberModel *obj=[memberList objectAtIndex:i];
       
        NSString *str=[NSString stringWithFormat:@" select '%@','%@','%@','%@','%@','%@' UNION ALL ",obj.member.jid,obj.roomJid,obj.member.myJID,obj.member.userName,obj.member.nickName,obj.member.iconUrl];
        
        [string appendString:str];
    
    }
    
    ERoomMemberModel *last=[memberList lastObject];
    
    NSString *str=[NSString stringWithFormat:@" select '%@','%@','%@','%@','%@','%@' ",last.member.jid,last.roomJid,last.member.myJID,last.member.userName,last.member.nickName,last.member.iconUrl];
    
    
    [string appendString:str];
    
    //sql插入语句
//    NSString *string=[NSString stringWithFormat:@"insert into %@(friends_jid,roomJID,myJID,friends_name,friends_nickName,friends_iconUrl) values(?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        
//        const char *friends_jid=[member.member.jid UTF8String];
//        const char *roomJID=[member.roomJid UTF8String];
//        const char *myJID=[member.member.myJID UTF8String];
//        const char *friends_name=[member.member.userName UTF8String];
//        const char *friends_nickName=[member.member.nickName UTF8String];
//        const char *friends_iconUrl=[member.member.iconUrl UTF8String];
//        
//        // 第2个int类型的参数用来指定第几列，从1开始
//        
//        sqlite3_bind_text(stmt, 1, friends_jid, -1, NULL);
//        sqlite3_bind_text(stmt, 2, roomJID, -1, NULL);
//        sqlite3_bind_text(stmt, 3, myJID, -1, NULL);
//        sqlite3_bind_text(stmt, 4, friends_name, -1, NULL);
//        sqlite3_bind_text(stmt, 5, friends_nickName, -1, NULL);
//        sqlite3_bind_text(stmt, 6, friends_iconUrl, -1, NULL);
        
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"------ERoomMemberDB---插入群成员数据失败！");
            NSLog(@"sqlite3_step(stmt) =%i",sqlite3_step(stmt));
        } else {
            NSLog(@"------ERoomMemberDB---插入群成员数据成功！");
        }
    } else {
        NSLog(@"--------ERoomMemberDB------插入数据的SQL语句语法有问题");
    }
    
    
    sqlite3_finalize(stmt);
    

}

#pragma mark 查询数据
-(NSMutableArray *)getGroupMemberWithRoomJid:(NSString*)jid{
    NSMutableArray *array=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ where myJID='%@' and roomJID='%@' order by roomJID desc;",_tableName,KUserJID,jid];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            ERoomMemberModel *f=[[ERoomMemberModel alloc] init];
            f.member=[[EFriends alloc]init];
            
            
            
            char *s1 = (char *)sqlite3_column_text(stmt, 0);
            NSString *friends_jID=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            f.member.jid = friends_jID;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 1);
            NSString *roomJid=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            f.roomJid = roomJid;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 2);
            NSString *myJID=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            f.member.myJID = myJID;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 3);
            NSString *friends_userName=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            f.member.userName = friends_userName;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 4);
            NSString *friends_nickName=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            f.member.nickName = friends_nickName;
            
            char *s6 = (char *)sqlite3_column_text(stmt, 5);
            NSString *friends_iconUrl=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            f.member.iconUrl = friends_iconUrl;
            
            [array addObject:f];
        }
    }else {
        NSLog(@"----ERoomMemberDB----查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return array;
}



#pragma mark 更新数据
-(void)updateWithFriend:(ERoomMemberModel *)group
{
    NSString* str=[NSString stringWithFormat:@"update %@ set friends_jid=?,roomJID=?,myJID=?,friends_name=?,friends_nickName=?,friends_iconUrl=? where friends_jid='%@' and roomJID='%@';",_tableName,group.member.jid,group.roomJid];
    
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, NULL)==SQLITE_OK)
    {
        const char *friends_jid=[group.member.jid UTF8String];
        const char *roomJID=[group.roomJid UTF8String];
        const char *myJID=[group.member.myJID UTF8String];
        const char *friends_name=[group.member.userName UTF8String];
        const char *friends_nickName=[group.member.nickName UTF8String];
        const char *friends_iconUrl=[group.member.iconUrl UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        
        sqlite3_bind_text(stmt, 1, friends_jid, -1, NULL);
        sqlite3_bind_text(stmt, 2, roomJID, -1, NULL);
        sqlite3_bind_text(stmt, 3, myJID, -1, NULL);
        sqlite3_bind_text(stmt, 4, friends_name, -1, NULL);
        sqlite3_bind_text(stmt, 5, friends_nickName, -1, NULL);
        sqlite3_bind_text(stmt, 6, friends_iconUrl, -1, NULL);
        
        if(sqlite3_step(stmt)!=SQLITE_DONE)
        {
            NSLog(@"更新群成员数据失败！");
        }else{
            NSLog(@"更新群成员数据成功！");
        }
    }
    else
    {
        NSLog(@"ERoomMemberDB------更新数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}



#pragma mark -好友是否存在
-(BOOL)isExistMember:(EFriends *)friends andRoomJid:(NSString *)roomJid{

        BOOL b=NO;
        NSString *string=[NSString stringWithFormat:@"select * from %@ where roomJID='%@' and friends_jid='%@' order by friends_jid desc;",_tableName,roomJid,friends.jid];
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
            
            NSLog(@"该好友不存在该群中--%@",roomJid);
        }
        sqlite3_finalize(stmt);
    
        return b;
}

@end
