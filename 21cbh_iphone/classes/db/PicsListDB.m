//
//  PicsListDB.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//  该表的操作用于图集列表
#import "PicsListDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"

@interface PicsListDB(){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end

@implementation PicsListDB

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
    _tableName=@"PicsList";
    NSString *className=@"PicsListDB";
    //检测是否需要删表
    [[CommonOperation getId] checkTableUpdateWithTableName:_tableName className:className db:_db];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, programId text,picsId text,type text,title text,followNum text,picUrls text,order1 text,addtime text);",_tableName];
    
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
-(void)insertPlm:(PicsListModel *)plm programId:(NSString *)programId{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(programId,picsId,type,title,followNum,picUrls,order1,addtime) values(?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *programId1=[programId UTF8String];
        const char *picsId=[plm.picsId UTF8String];
        const char *type=[plm.type UTF8String];
        const char *title=[plm.title UTF8String];
        const char *followNum=[plm.followNum UTF8String];
        const char *order=[plm.order UTF8String];
        const char *addtime=[plm.addtime UTF8String];
        
        NSString *s_picUrls=@"";
        if (plm.picUrls&&plm.picUrls.count>0) {
            for(int i=0; i<plm.picUrls.count; i++) {
                NSString *s1=[plm.picUrls objectAtIndex:i];
                // NSLog(@"s1:%@",s1);
                if (i!=plm.picUrls.count-1) {
                    s_picUrls=[[s_picUrls stringByAppendingString:s1] stringByAppendingString:@"|"];
                }else{
                    s_picUrls=[s_picUrls stringByAppendingString:s1];
                }
                
            }
        }
        const char *picUrls=[s_picUrls UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, programId1, -1, NULL);
        sqlite3_bind_text(stmt, 2, picsId, -1, NULL);
        sqlite3_bind_text(stmt, 3, type, -1, NULL);
        sqlite3_bind_text(stmt, 4, title, -1, NULL);
        sqlite3_bind_text(stmt, 5, followNum, -1, NULL);
        sqlite3_bind_text(stmt, 6, picUrls, -1, NULL);
        sqlite3_bind_text(stmt, 7, order, -1, NULL);
        sqlite3_bind_text(stmt, 8, addtime, -1, NULL);
        
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"图集列表插入数据失败！");
        } else {
            //NSLog(@"插入数据成功！");
        }
    } else {
        NSLog(@"图集列表插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deletePlmsWithProgramId:(NSString *)programId{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (programId='%@');",_tableName,programId];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"图集列表删除programId:%@数据成功！",programId);
        } else {
            NSLog(@"图集列表删除数据失败！");
        }
    } else {
        NSLog(@"图集列表删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查询数据
-(NSMutableArray *)getPlmsWithProgramId:(NSString *)programId{
    NSMutableArray *plms=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ where programId='%@' order by id desc;",_tableName,programId];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            PicsListModel *plm=[[PicsListModel alloc] init];
            //picsId,type,title,followNum,picUrls,order,addtime
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            NSString *picsId=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            plm.picsId=picsId;
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            NSString *type=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            plm.type=type;
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            NSString *title=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            plm.title=title;
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            NSString *followNum=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            plm.followNum=followNum;
            
            char *s6 = (char *)sqlite3_column_text(stmt, 6);
            NSString *picUrls=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            plm.picUrls=[picUrls componentsSeparatedByString: @"|"];
            
            char *s7 = (char *)sqlite3_column_text(stmt, 7);
            NSString *order=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            plm.order=order;
            
            char *s8 = (char *)sqlite3_column_text(stmt, 8);
            NSString *addtime=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            plm.addtime=addtime;
            
            [plms addObject:plm];
            
        }
        
    }else {
        
        NSLog(@"图集列表查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return plms;
}

@end
