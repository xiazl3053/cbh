//
//  VoiceListRecordDB.m
//  21cbh_iphone
//
//  Created by qinghua on 15-1-6.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "VoiceListRecordDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"
#import "VoiceListModel.h"

static VoiceListRecordDB *instance=nil;

@interface VoiceListRecordDB (){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end

@implementation VoiceListRecordDB

+(VoiceListRecordDB *)sharedInstance
{
    @synchronized(self){
        if(!instance){
            instance=[[VoiceListRecordDB alloc]init];
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
    _tableName=@"VoiceListRecord";
    NSString *className=@"VoiceListRecordDB";
    //检测是否需要删表
    //[[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    //创表
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement,programId text,articleId text,duration text,title text,voiceUrl text,size text,order1 text,addtime text);",_tableName];
    
    const char *sql =[string UTF8String];
    
    char *error;
    // sqlite3_exec能执行一切SQL语句
    // insert into t_person(name, age) values('mj', 10);
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    
    if (result == SQLITE_OK) {
        //NSLog(@"创表成功!");
    }else{
        NSLog(@"Voice列表记录创表错误：%s", error);
    }
}

#pragma mark 插入数据
-(void)insertWithVoiceModel:(VoiceListModel *)model{
    
    bool b=[self isExistVoiceModel:model];
    if (b) {//有数据的话就不插入了
        return;
    }
    
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(programId,articleId,duration,title,voiceUrl,size,order1,addtime) values(?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *programId=[model.programId UTF8String];
        const char *articleId=[model.articleId UTF8String];
        const char *duration=[model.duration UTF8String];
        const char *title=[model.title UTF8String];
        const char *voiceUrl=[model.voiceUrl UTF8String];
        const char *size=[model.size UTF8String];
        const char *order=[model.order UTF8String];
        const char *addtime=[model.addtime UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, programId, -1, NULL);
        sqlite3_bind_text(stmt, 2, articleId, -1, NULL);
        sqlite3_bind_text(stmt, 3, duration, -1, NULL);
        sqlite3_bind_text(stmt, 4, title, -1, NULL);
        sqlite3_bind_text(stmt, 5, voiceUrl, -1, NULL);
        sqlite3_bind_text(stmt, 6, size, -1, NULL);
        sqlite3_bind_text(stmt, 7, order, -1, NULL);
        sqlite3_bind_text(stmt, 8, addtime, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"Voice列表记录插入数据失败！");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"Voice列表记录插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deleteAll{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@;",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"Voice列表记录删除数据成功！");
        } else {
            NSLog(@"Voice列表记录删除数据失败！");
        }
    } else {
        NSLog(@"Voice列表记录删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查看数据是否存在
-(BOOL)isExistVoiceModel:(VoiceListModel *)model{
    bool b=NO;
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"select * from %@ where programId='%@' and articleId='%@' order by id desc;",_tableName,model.programId,model.articleId];
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
        NSLog(@"Voice列表记录查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return b;
}

#pragma mark 查询数据
-(NSMutableArray *)getVoiceList{
    NSMutableArray *list=[NSMutableArray array];
//    NSString *string=[NSString stringWithFormat:@"select * from %@ order by id desc limit 10;",_tableName];//查询前十条
     NSString *string=[NSString stringWithFormat:@"select * from %@ order by id desc;",_tableName];//查询前十条
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            
            VoiceListModel *model=[[VoiceListModel alloc] init];
            
            char *s1 = (char *)sqlite3_column_text(stmt, 1);
            NSString *programId=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            model.programId=programId;
            
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            NSString *articleId=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            model.articleId=articleId;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            NSString *duration=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            model.duration=duration;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            NSString *title=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            model.title=title;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            NSString *voiceUrl=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            model.voiceUrl=voiceUrl;
            
            char *s6 = (char *)sqlite3_column_text(stmt, 6);
            NSString *size=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            model.size=size;
            
            char *s7 = (char *)sqlite3_column_text(stmt, 7);
            NSString *order=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            model.order=order;
            
            char *s8 = (char *)sqlite3_column_text(stmt, 8);
            NSString *addtime=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            model.addtime=addtime;
            
            [list addObject:model];
            
        }
        
    }else {
        
        NSLog(@"Voice查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return list;
}


@end
