//
//  selfMaketMessageDB.m
//  21cbh_iphone
//
//  Created by Franky on 14-4-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "selfMarketMessageDB.h"
#import "NSString+File.h"
#import <sqlite3.h>

@interface selfMarketMessageDB()
{
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}
@end

static selfMarketMessageDB* _instance;

@implementation selfMarketMessageDB

+(selfMarketMessageDB *)instance
{
    @synchronized(self){
        if(!_instance){
            _instance=[[selfMarketMessageDB alloc]init];
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

- (void)createTables {
    //设置表名
    _tableName=@"marketMessage";
    
    NSString* vcodeInPlist = (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Application Version"];
    NSString* vcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"marketMessageDB Version"];
    if (vcode==nil || [vcode intValue]<[vcodeInPlist intValue]) {
        NSString *str=[NSString stringWithFormat:@"drop table if exists %@",_tableName];
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, NULL)==SQLITE_OK)
        {
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                NSLog(@"删除旧版数据库marketMessage表失败");
            } else {
                NSLog(@"检测到数据库表marketMessage陈旧,删除成功后重建");
            }
            [[NSUserDefaults standardUserDefaults] setObject:vcodeInPlist forKey:@"marketMessageDB Version"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            NSLog(@"删除旧版数据库marketMessage表语句错误");
        }
        sqlite3_finalize(stmt);
    }
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, msgId text,userId text,type text,title text,date text,time text,marketId text,marketName text,marketType text,isRead text,newsId text,programId text);",_tableName];
    
    const char *sql =[string UTF8String];
    
    char *error;

    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    
    if (result == SQLITE_OK) {
        //NSLog(@"创表成功!");
    }else{
        NSLog(@"marketMessage创表错误：%s", error);
    }
}

-(void)insertMessage:(selfMarketMessageModel *)model andUserId:(NSString*)userId
{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(msgId,userId,type,title,date,time,marketId,marketName,marketType,isRead,newsId,programId) values(?,?,?,?,?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *msgId=[model.msgId UTF8String];
        const char *uId=userId.UTF8String;
        const char *type=[model.type UTF8String];
        const char *title=[model.title UTF8String];
        const char *date=[model.date UTF8String];
        const char *time=[model.time UTF8String];
        const char *marketId=[model.marketId UTF8String];
        const char *marketName=[model.marketName UTF8String];
        const char *marketType=[model.marketType UTF8String];
        const char *isRead=[model.isRead UTF8String];
        const char *newsId=[model.newsId UTF8String];
        const char *programId=[model.programId UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, msgId, -1, NULL);
        sqlite3_bind_text(stmt, 2, uId, -1, NULL);
        sqlite3_bind_text(stmt, 3, type, -1, NULL);
        sqlite3_bind_text(stmt, 4, title, -1, NULL);
        sqlite3_bind_text(stmt, 5, date, -1, NULL);
        sqlite3_bind_text(stmt, 6, time, -1, NULL);
        sqlite3_bind_text(stmt, 7, marketId, -1, NULL);
        sqlite3_bind_text(stmt, 8, marketName, -1, NULL);
        sqlite3_bind_text(stmt, 9, marketType, -1, NULL);
        sqlite3_bind_text(stmt, 10, isRead, -1, NULL);
        sqlite3_bind_text(stmt, 11, newsId, -1, NULL);
        sqlite3_bind_text(stmt, 12, programId, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"marketMessage插入数据失败！");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"marketMessage插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 如果不存在就插入数据
-(void)insertIfNotExist:(selfMarketMessageModel*)model andUserId:(NSString*)userId
{
    if(![self isExistMessage:model andUserId:userId]){
        [self insertMessage:model andUserId:userId];
    }
}

#pragma mark 如果不存在就插入数据
-(void)insertIfNotExistWithDic:(NSDictionary*)dic isRead:(BOOL)flag andUserId:userId
{
    selfMarketMessageModel* model=[[selfMarketMessageModel alloc]init];
    model.msgId=[dic objectForKey:@"pushId"];
    model.type =[dic objectForKey:@"type"];
    model.isRead=flag?@"1":@"0";
    switch (model.type.intValue) {
        case 2:
            break;
        case 3:
            break;
        case 4:
            break;
        case 5:
            break;
        case 7://个股详情
        case 8://公告
            model.marketId=[dic objectForKey:@"kId"];
            model.marketType=[dic objectForKey:@"kType"];
            break;
        default://新闻页
            model.programId=[dic objectForKey:@"programId"];
            break;
    }
    [self insertIfNotExist:model andUserId:userId];
}

#pragma mark 查询数据是否存在
-(BOOL)isExistMessage:(selfMarketMessageModel*)model andUserId:(NSString*)userId
{
    BOOL isExist = NO;
    NSString *str=[NSString stringWithFormat:@"select * from %@ where msgId='%@' and userId='%@';",_tableName,model.msgId,userId];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, NULL)==SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW){
            isExist=YES;
        }
    }
    sqlite3_finalize(stmt);
    return isExist;
}

#pragma mark 查询数据是否已读
-(BOOL)isReadMessage:(selfMarketMessageModel *)model andUserId:(NSString*)userId
{
    BOOL isRead=NO;
    NSString *str=[NSString stringWithFormat:@"select isRead from %@ where msgId='%@' and userId='%@';",_tableName,model.msgId,userId];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, NULL)==SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW){
            char *s1 = (char *)sqlite3_column_text(stmt, 0);
            NSString *result=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            if(![result isEqualToString:@"0"]){
                isRead=YES;
            }
        }
    }
    return isRead;
    sqlite3_finalize(stmt);
}

-(void)readMessage:(selfMarketMessageModel *)model andUserId:(NSString *)userId
{
    model.isRead=@"1";
    NSString* str=[NSString stringWithFormat:@"update %@ set isRead=? where msgId='%@' and userId='%@';",_tableName,model.msgId,userId];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, model.isRead.UTF8String, -1, nil);
        
        if(sqlite3_step(stmt)!=SQLITE_DONE)
        {
            NSLog(@"marketMessage更新数据失败！");
        }
    }
    else
    {
        NSLog(@"marketMessage更新数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

-(void)deleteMessage:(selfMarketMessageModel *)model andUserId:(NSString *)userId
{
    NSString *string=[NSString stringWithFormat:@"delete from %@ where msgId='%@' and userId='%@';",_tableName,model.msgId,userId];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;

    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"marketMessage删除msgId:%@数据成功！",model.msgId);
        } else {
            NSLog(@"marketMessage删除数据失败！");
        }
    } else {
        NSLog(@"marketMessage删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

-(int)getUnReadofMessageWithUserId:(NSString *)userId
{
    char* error=NULL;
    char** result;
    int row=0;
    int column=0;
    NSString* sql=[NSString stringWithFormat:@"select * from %@ where isRead='0' and userId='%@'",_tableName,userId];
    sqlite3_get_table(_db, sql.UTF8String, &result, &row, &column, &error);
    if(error){
        return 0;
    }
    sqlite3_free_table(result);
    return row;
}

#pragma mark 清空所有未读数量
-(void)cleanAllUnReadMessageWithUserId:(NSString *)userId
{
    NSString* str=[NSString stringWithFormat:@"update %@ set isRead=? where userId='%@';",_tableName,userId];
    
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, nil)==SQLITE_OK)
    {
        NSString* str=@"1";
        sqlite3_bind_text(stmt, 1, str.UTF8String, -1, nil);
        
        if(sqlite3_step(stmt)!=SQLITE_DONE)
        {
            NSLog(@"marketMessage更新数据失败！");
        }
    }
    else
    {
        NSLog(@"marketMessage更新数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

@end
