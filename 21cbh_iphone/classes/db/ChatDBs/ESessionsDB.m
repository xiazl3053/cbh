//
//  ESessionsDB.m
//  21cbh_iphone
//
//  Created by 21tech on 14-6-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ESessionsDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"
#import "ESessions.h"
#import "XMPPServer.h"

@interface ESessionsDB(){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end

static ESessionsDB *_instance;

@implementation ESessionsDB


+(ESessionsDB *)instance
{
    @synchronized(self){
        if(!_instance){
            _instance=[[ESessionsDB alloc]init];
        }
        return _instance;
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
    _tableName=@"ESessions";
    NSString *className=@"ESessionsDB";
    //检测是否需要删表
    [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(jid text primary key,myJID text,isTop integer,time text,isShiled integer,unReadCount integer,content text,sessionName text,session_type integer);",_tableName];
    
    const char *sql =[string UTF8String];
    
    char *error;
    // sqlite3_exec能执行一切SQL语句
    // insert into t_person(name, age) values('mj', 10);
//    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
//    
//    if (result == SQLITE_OK) {
//        //NSLog(@"创表成功!");
//    }else{
//        NSLog(@"创表错误：%s", error);
//    }
    BOOL retry;
    int result;
    do
    {
        retry=NO;
        result=sqlite3_exec(_db, sql, NULL, NULL, &error);
        if (SQLITE_BUSY == result || SQLITE_LOCKED == result) {
            retry = YES;
            usleep(20);
        }
        else if (SQLITE_OK != result) {
            NSLog(@"创表错误: %s %d",error,result);
        }
    }
    while (retry);
    
}

#pragma mark 插入数据
-(int)insertWithSession:(ESessions *)session{
    int rowid = 0;
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(jid,myJID,isTop,time,isShiled,unReadCount,content,sessionName,session_type) values(?,?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *jid=[session.jid UTF8String];
        const char *myJID=[session.myJID UTF8String];
        const char *isTop=[[NSString stringWithFormat:@"%d",session.isTop] UTF8String];
        const char *time=[[NSString stringWithFormat:@"%f",session.time] UTF8String];
        const char *isShiled=[[NSString stringWithFormat:@"%d",session.isShiled] UTF8String];
        const char *unReadCount=[[NSString stringWithFormat:@"%d",session.unReadCount] UTF8String];
        const char *content=session.content.UTF8String;
        const char *sessionName=session.sessionName.UTF8String;
        const char *session_type=[[NSString stringWithFormat:@"%d",session.session_type] UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, jid, -1, NULL);
        sqlite3_bind_text(stmt, 2, myJID, -1, NULL);
        sqlite3_bind_text(stmt, 3, isTop, -1, NULL);
        sqlite3_bind_text(stmt, 4, time, -1, NULL);
        sqlite3_bind_text(stmt, 5, isShiled, -1, NULL);
        sqlite3_bind_text(stmt, 6, unReadCount, -1, NULL);
        sqlite3_bind_text(stmt, 7, content, -1, NULL);
        sqlite3_bind_text(stmt, 8, sessionName, -1, NULL);
        sqlite3_bind_text(stmt, 9, session_type, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"插入数据失败！");
        } else {
            NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return rowid;
}

#pragma mark 更新数据
-(void)updateWithSession:(ESessions *)session
{
    NSString* str=[NSString stringWithFormat:@"update %@ set jid=?,myJID=?,isTop=?,time=?,isShiled=?,unReadCount=?,content=?,sessionName=?,session_type=? where jid='%@';",_tableName,session.jid];
    
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, nil)==SQLITE_OK)
    {
        const char *jid=[session.jid UTF8String];
        const char *myJID=[session.myJID UTF8String];
        const char *isTop=[[NSString stringWithFormat:@"%d",session.isTop] UTF8String];
        const char *time=[[NSString stringWithFormat:@"%f",session.time] UTF8String];
        const char *isShiled=[[NSString stringWithFormat:@"%d",session.isShiled] UTF8String];
        const char *unReadCount=[[NSString stringWithFormat:@"%d",session.unReadCount] UTF8String];
        const char *content=session.content.UTF8String;
        const char *sessionName=session.sessionName.UTF8String;
        const char *session_type=[[NSString stringWithFormat:@"%d",session.session_type] UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, jid, -1, NULL);
        sqlite3_bind_text(stmt, 2, myJID, -1, NULL);
        sqlite3_bind_text(stmt, 3, isTop, -1, NULL);
        sqlite3_bind_text(stmt, 4, time, -1, NULL);
        sqlite3_bind_text(stmt, 5, isShiled, -1, NULL);
        sqlite3_bind_text(stmt, 6, unReadCount, -1, NULL);
        sqlite3_bind_text(stmt, 7, content, -1, NULL);
        sqlite3_bind_text(stmt, 8, sessionName, -1, NULL);
        sqlite3_bind_text(stmt, 9, session_type, -1, NULL);

        
        if(sqlite3_step(stmt)!=SQLITE_DONE)
        {
            const char c = *sqlite3_errmsg(_db);
            NSLog(@"更新数据失败！%c",c);
        }
    }
    else
    {
        NSLog(@"更新数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}



#pragma mark 删除数据
-(void)deleteSession:(NSString *)jid{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (jid='%@');",_tableName,jid];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"删除jid:%@数据成功！",jid);
        } else {
            NSLog(@"删除数据失败！");
        }
    } else {
        NSLog(@"删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查询数据
-(NSMutableArray *)selectSessions{
    NSMutableArray *array=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ where myJID='%@' order by istop desc,time desc;",_tableName,KUserJID];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        // 如果返回值是ROW,代表读取到一行数据
        // NSLog(@"%d",sqlite3_step(stmt));
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
            
            ESessions *m=[[ESessions alloc] init];
            
            
            char *s1 = (char *)sqlite3_column_text(stmt, 0);
            NSString *jid=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            m.jid = jid;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 1);
            NSString *myJID=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            m.myJID = myJID;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 2);
            NSString *isTop=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            m.isTop = [isTop boolValue];
            
            char *s4 = (char *)sqlite3_column_text(stmt, 3);
            NSString *time=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            m.time = [time doubleValue];
            
            char *s5 = (char *)sqlite3_column_text(stmt, 4);
            if (!s5) {
                m.isShiled = NO;
            }else{
                NSString *isShiled=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
                m.isShiled = [isShiled boolValue];
            }
            
            char *s6 = (char *)sqlite3_column_text(stmt, 5);
            if (!s6) {
                m.unReadCount = 0;
            }else{
                NSString *unReadCount=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
                m.unReadCount = [unReadCount intValue];
            }
            
            char *s7 = (char *)sqlite3_column_text(stmt, 6);
            if (!s7) {
                s7=(char *)"";
            }
            NSString *content=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            m.content = content;
            
            char *s8 = (char *)sqlite3_column_text(stmt, 7);
            if (!s8) {
                s8=(char *)"";
            }
            NSString *sessionName=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            m.sessionName = sessionName;
            
            char *s9 = (char *)sqlite3_column_text(stmt, 8);
            if (!s9) {
                m.session_type = 1000;
            }else{
                NSString *isShiled=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
                m.session_type = [isShiled integerValue];
            }
            
            [array addObject:m];
            m = nil;
        }
    }else {
        NSLog(@"ESessionDB----查询数据的SQL语句语法有问题%d",result);
    }
    sqlite3_finalize(stmt);
    return array;
}


-(ESessions *)getSessionWithJid:(NSString *)jid{

    NSString *string=[NSString stringWithFormat:@"select * from %@ where jid='%@' order by istop desc,time desc;",_tableName,jid];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    
    ESessions *m=[[ESessions alloc] init];

    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        // 如果返回值是ROW,代表读取到一行数据
        // NSLog(@"%d",sqlite3_step(stmt));
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
            
            

            char *s1 = (char *)sqlite3_column_text(stmt, 0);
            NSString *jid=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            m.jid = jid;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 1);
            NSString *myJID=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            m.myJID = myJID;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 2);
            NSString *isTop=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            m.isTop = [isTop boolValue];
            
            char *s4 = (char *)sqlite3_column_text(stmt, 3);
            NSString *time=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            m.time = [time doubleValue];
            
            char *s5 = (char *)sqlite3_column_text(stmt, 4);
            if (!s5) {
                m.isShiled = NO;
            }else{
                NSString *isShiled=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
                m.isShiled = [isShiled boolValue];
            }
            
            char *s6 = (char *)sqlite3_column_text(stmt, 5);
            if (!s6) {
                m.unReadCount = 0;
            }else{
                NSString *unReadCount=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
                m.unReadCount = [unReadCount intValue];
            }
            
            char *s7 = (char *)sqlite3_column_text(stmt, 6);
            if (!s7) {
                s7=(char *)"";
            }
            NSString *content=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            m.content = content;
            
            char *s8 = (char *)sqlite3_column_text(stmt, 7);
            if (!s8) {
                s8=(char *)"";
            }
            NSString *sessionName=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            m.sessionName = sessionName;
            
            char *s9 = (char *)sqlite3_column_text(stmt, 8);
            if (!s9) {
                m.session_type = 1000;
            }else{
                NSString *isShiled=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
                m.session_type = [isShiled integerValue];
            }
        }
    }else {
        NSLog(@"ESessionDB----查询数据的SQL语句语法有问题%d",result);
    }
    sqlite3_finalize(stmt);

    return m;
}

#pragma mark 查询数据
-(NSMutableArray *)selectSessionsWithFriendJid:(NSString *)friends_jid{
    NSMutableArray *array=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ where myJID='%@' and jid='%@' order by time desc;",_tableName,[XMPPServer sharedServer].myJID.bare,friends_jid];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        // 如果返回值是ROW,代表读取到一行数据
        // NSLog(@"%d",sqlite3_step(stmt));
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
            
            ESessions *m=[[ESessions alloc] init];
            
            char *s1 = (char *)sqlite3_column_text(stmt, 0);
            NSString *jid=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            m.jid = jid;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 1);
            NSString *myJID=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            m.myJID = myJID;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 2);
            NSString *isTop=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            m.isTop = [isTop boolValue];
            
            char *s4 = (char *)sqlite3_column_text(stmt, 3);
            NSString *time=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            m.time = [time doubleValue];
            
            char *s5 = (char *)sqlite3_column_text(stmt, 4);
            if (!s5) {
                m.isShiled = NO;
            }else{
                NSString *isShiled=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
                m.isShiled = [isShiled boolValue];
            }
            
            char *s6 = (char *)sqlite3_column_text(stmt, 5);
            if (!s6) {
                m.unReadCount = 0;
            }else{
                NSString *unReadCount=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
                m.unReadCount = [unReadCount intValue];
            }
            
            char *s7 = (char *)sqlite3_column_text(stmt, 6);
            NSString *content=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            m.content = content;
            
            char *s8 = (char *)sqlite3_column_text(stmt, 7);
            NSString *sessionName=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            m.sessionName = sessionName;
            
            char *s9 = (char *)sqlite3_column_text(stmt, 8);
            if (!s9) {
                m.session_type = 1000;
            }else{
                NSString *isShiled=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
                m.session_type = [isShiled integerValue];
            }
            
            
            [array addObject:m];
            m = nil;
        }
    }else {
        NSLog(@"ESessionDB--------查询数据的SQL语句语法有问题%d",result);
    }
    sqlite3_finalize(stmt);
    return array;
}

#pragma mark -数据是否存在
-(BOOL)isExistFriends:(ESessions *)session{
    BOOL b=NO;
    NSString *string=[NSString stringWithFormat:@"select * from %@ where myJID='%@' and jid='%@' order by id desc;",_tableName,session.myJID,session.jid];
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
        
        NSLog(@"该session不存在！！！！");
    }
    sqlite3_finalize(stmt);
    return b;
}

@end
