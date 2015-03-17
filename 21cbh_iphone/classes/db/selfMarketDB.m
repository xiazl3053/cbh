//
//  selfMarketDB.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "selfMarketDB.h"
#import "NSString+File.h"
#import "DCommon.h"
#import <sqlite3.h>
#import "UserModel.h"
@interface selfMarketDB(){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}


@end

@implementation selfMarketDB

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
    NSString *filename = [DCommon documentsAppend:kselfMarketDBName];
    
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
    _tableName=@"selfMarket";
    // 创建表 marketId 股票Id marketName 股票名称  marketType 0=大盘 1=沪股 2=深股 userId 用户Id time 本地存储时间 isSyn 是否已同步服务器 heightPrice 股价涨到 lowPrice 股价跌到 changeRate 日涨跌幅超 isNotice 公告提醒 isNews 研报提醒
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, marketId text, marketName text, marketType text, userId text, timestamp text, issyn text,heightPrice text,lowPrice text,todayChangeRate text,isNotice text,isNews text);",_tableName];
    
    const char *sql =[string UTF8String];
    
    char *error;
    // sqlite3_exec能执行一切SQL语句
    // insert into t_person(name, age) values('mj', 10);
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    
    if (result == SQLITE_OK) {
        NSLog(@"创表成功!");
    }else{
        NSLog(@"创表错误：%s", error);
    }
}

#pragma mark 插入数据
// type为类型 0=大盘 1=沪股 2=深股
-(void)insertWithSelfMarket:(selfMarketModel *)selfMarket{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@ (marketId,marketName,marketType,userId,timestamp,issyn,heightPrice,lowPrice,todayChangeRate,isNotice,isNews) values (?,?,?,?,?,?,?,?,?,?,?);",_tableName];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *marketId=[selfMarket.marketId UTF8String];
        const char *marketName=[selfMarket.marketName UTF8String];
        const char *marketType=[selfMarket.marketType UTF8String];
        const char *userId=[selfMarket.userId UTF8String];
        const char *time= [selfMarket.timestamp UTF8String];
        const char *isSyn=[selfMarket.isSyn UTF8String];
        const char *heightPrice=[selfMarket.heightPrice UTF8String];
        const char *lowPrice=[selfMarket.lowPrice UTF8String];
        const char *todayChangeRate=[selfMarket.todayChangeRate UTF8String];
        const char *isNotice=[selfMarket.isNotice UTF8String];
        const char *isNews=[selfMarket.isNews UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, marketId, -1, NULL);
        sqlite3_bind_text(stmt, 2, marketName, -1, NULL);
        sqlite3_bind_text(stmt, 3, marketType, -1, NULL);
        sqlite3_bind_text(stmt, 4, userId, -1, NULL);
        sqlite3_bind_text(stmt, 5, time, -1, NULL);
        sqlite3_bind_text(stmt, 6, isSyn, -1, NULL);
        sqlite3_bind_text(stmt, 7, heightPrice, -1, NULL);
        sqlite3_bind_text(stmt, 8, lowPrice, -1, NULL);
        sqlite3_bind_text(stmt, 9, todayChangeRate, -1, NULL);
        sqlite3_bind_text(stmt, 10, isNotice, -1, NULL);
        sqlite3_bind_text(stmt, 11, isNews, -1, NULL);
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"自选股插入数据失败");
        } else {
            NSLog(@"插入数据成功");
        }
    } else {
        NSLog(@"自选股插入数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 更新自选股中的提醒信息
-(void)updateRemindWithSelfMarket:(selfMarketModel *)selfMarket{
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"update %@ set heightPrice=?,lowPrice=?,todayChangeRate=?,isNotice=?,isNews=? where marketId='%@' and marketType='%@' and userId='';",_tableName,selfMarket.marketId,selfMarket.marketType];
    UserModel *user = [UserModel um];
    if (user.userId>0) {
        string=[NSString stringWithFormat:@"update %@ set heightPrice=?,lowPrice=?,todayChangeRate=?,isNotice=?,isNews=? where marketId='%@' and marketType='%@' and userId='%@';",_tableName,selfMarket.marketId,selfMarket.marketType,user.userId];
    }
    user = nil;
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *heightPrice=[selfMarket.heightPrice UTF8String];
        const char *lowPrice=[selfMarket.lowPrice UTF8String];
        const char *todayChangeRate=[selfMarket.todayChangeRate UTF8String];
        const char *isNotice=[selfMarket.isNotice UTF8String];
        const char *isNews=[selfMarket.isNews UTF8String];
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, heightPrice, -1, NULL);
        sqlite3_bind_text(stmt, 2, lowPrice, -1, NULL);
        sqlite3_bind_text(stmt, 3, todayChangeRate, -1, NULL);
        sqlite3_bind_text(stmt, 4, isNotice, -1, NULL);
        sqlite3_bind_text(stmt, 5, isNews, -1, NULL);
        // 执行sql语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"自选股更新提醒数据失败");
        } else {
            NSLog(@"更新提醒数据成功！");
        }
    } else {
        NSLog(@"自选股更新提醒数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(void)deleteSelfMarket:(selfMarketModel *)selfMarket{
    //sql插入语句
    
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (marketId='%@' and marketType='%@') ;",_tableName,selfMarket.marketId,selfMarket.marketType];
    UserModel *user = [UserModel um];
    if (user.userId>0) {
        string=[NSString stringWithFormat:@"delete from %@ where (marketId='%@' and marketType='%@' and userId='%@') ;",_tableName,selfMarket.marketId,selfMarket.marketType,user.userId];
    }
    user = nil;
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"删除Id:%@数据成功！",selfMarket.marketId);
        } else {
            NSLog(@"删除数据失败！");
        }
    } else {
        NSLog(@"自选股删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除所有数据
-(void)deleteAllSelfMarket{
    // 默认删除非登陆用户数据
    NSString *string=[NSString stringWithFormat:@"delete from %@ where userId='';",_tableName];
    UserModel *user = [UserModel um];
    // 如果用户登陆则删除登陆用户的数据
    if (user.userId>0) {
        string = [NSString stringWithFormat:@"delete from %@ where userId='%@';",_tableName,user.userId];
    }
    user = nil;
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"删除数据成功！");
        } else {
            NSLog(@"删除数据失败！");
        }
    } else {
        NSLog(@"自选股删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 查看自选股是否存在
-(BOOL)isExistSelfMarket:(selfMarketModel *)selfMarket{
    UserModel *user = [UserModel um];
    bool b=NO;
    NSString *string=[NSString stringWithFormat:@"select * from %@ where marketId='%@' and marketType='%@' and userId='' order by id desc;",_tableName,selfMarket.marketId,selfMarket.marketType];
    if (user.userId>0) {
        string=[NSString stringWithFormat:@"select * from %@ where marketId='%@' and marketType='%@' and userId='%@' order by id desc;",_tableName,selfMarket.marketId,selfMarket.marketType,user.userId];
    }
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
            NSLog(@"自选股数据存在吗？");
        }
        
    }else {
        
        NSLog(@"自选股数据的SQL语句语法有问题");
    }
    user = nil;
    sqlite3_finalize(stmt);
    return b;
}

#pragma mark 查询自选股列表数据
-(NSMutableArray *)getSelfMarketList{
    NSMutableArray *selfDatas=[NSMutableArray array];
    // 默认时间倒序排列
    NSString *string=[NSString stringWithFormat:@"select * from %@ where userId='' order by timestamp desc;",_tableName];
    // 如果用户存在
    UserModel *user = [UserModel um];
    if (user.userId>0) {
       string = [NSString stringWithFormat:@"select * from %@ where userId='%@' order by timestamp desc;",_tableName,user.userId];
    }
    user = nil;
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些查询准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
            char *s0 = (char *)sqlite3_column_text(stmt, 0);
            NSString *ids = [[NSString alloc] initWithCString:s0 encoding:NSUTF8StringEncoding];
            
            char *s1 = (char *)sqlite3_column_text(stmt, 1);
            if (s1==NULL) {
                s1="";
            }
            NSString *marketId = [[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            if (s2==NULL) {
                s2="";
            }
            NSString *marketName = [[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            if (s3==NULL) {
                s3="";
            }
            NSString *marketType = [[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            if (s4==NULL) {
                s4="";
            }
            NSString *userId = [[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            if (s5==NULL) {
                s5="";
            }
            NSString *time = [[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            
            char *s6 = (char *)sqlite3_column_text(stmt, 6);
            if (s6==NULL) {
                s6="";
            }
            NSString *isSyn = [[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            
            char *s7 = (char *)sqlite3_column_text(stmt, 7);
            if (s7==NULL) {
                s7="";
            }
            NSString *heightPrice = [[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            
            char *s8 = (char *)sqlite3_column_text(stmt, 8);
            if (s8==NULL) {
                s8="";
            }
            NSString *lowPrice = [[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            
            char *s9 = (char *)sqlite3_column_text(stmt, 9);
            if (s9==NULL) {
                s9="";
            }
            NSString *todayChangeRate = [[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
            
            char *s10 = (char *)sqlite3_column_text(stmt, 10);
            if (s10==NULL) {
                s10="";
            }
            NSString *isNotice = [[NSString alloc] initWithCString:s10 encoding:NSUTF8StringEncoding];
            
            char *s11 = (char *)sqlite3_column_text(stmt, 11);
            if (s11==NULL) {
                s11="";
            }
            NSString *isNews = [[NSString alloc] initWithCString:s11 encoding:NSUTF8StringEncoding];
            // 封装
            selfMarketModel *model = [[selfMarketModel alloc] initWithDic:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                           ids,@"ids",
                                                                           marketId,@"marketId",
                                                                           marketName,@"marketName",
                                                                           marketType,@"marketType",
                                                                           userId,@"userId",
                                                                           time,@"timestamp",
                                                                           isSyn,@"isSyn",
                                                                           heightPrice,@"heightPrice",
                                                                           lowPrice,@"lowPrice",
                                                                           todayChangeRate,@"todayChangeRate",
                                                                           isNotice,@"isNotice",
                                                                           isNews,@"isNews",
                                                                           nil]];
            [selfDatas addObject:model];
            model = nil;
        }
        NSLog(@"查询成功");
    }else {
        
        NSLog(@"查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return selfDatas;
}
#pragma mark 查询自选股单例数据
-(selfMarketModel *)getSelfMarketModelWithMarketId:(NSString *)marketId andMarketType:(NSString *)marketType{
    selfMarketModel *selfDatas=[[selfMarketModel alloc] init];
    // 默认时间倒序排列
    NSString *string=[NSString stringWithFormat:@"select * from %@ where userId='' and marketId='%@' and marketType='%@' order by timestamp desc;",_tableName,marketId,marketType];
    // 如果用户存在
    UserModel *user = [UserModel um];
    if (user.userId>0) {
        string = [NSString stringWithFormat:@"select * from %@ where userId='%@' and marketId='%@' and marketType='%@'  order by timestamp desc;",_tableName,user.userId,marketId,marketType];
    }
    user = nil;
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些查询准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
            char *s0 = (char *)sqlite3_column_text(stmt, 0);
            NSString *ids = [[NSString alloc] initWithCString:s0 encoding:NSUTF8StringEncoding];
            
            char *s1 = (char *)sqlite3_column_text(stmt, 1);
            if (s1==NULL) {
                s1="";
            }
            NSString *marketId = [[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            if (s2==NULL) {
                s2="";
            }
            NSString *marketName = [[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            if (s3==NULL) {
                s3="";
            }
            NSString *marketType = [[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            if (s4==NULL) {
                s4="";
            }
            NSString *userId = [[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            if (s5==NULL) {
                s5="";
            }
            NSString *time = [[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            
            char *s6 = (char *)sqlite3_column_text(stmt, 6);
            if (s6==NULL) {
                s6="";
            }
            NSString *isSyn = [[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
            
            char *s7 = (char *)sqlite3_column_text(stmt, 7);
            if (s7==NULL) {
                s7="";
            }
            NSString *heightPrice = [[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
            
            char *s8 = (char *)sqlite3_column_text(stmt, 8);
            if (s8==NULL) {
                s8="";
            }
            NSString *lowPrice = [[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
            
            char *s9 = (char *)sqlite3_column_text(stmt, 9);
            if (s9==NULL) {
                s9="";
            }
            NSString *todayChangeRate = [[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
            
            char *s10 = (char *)sqlite3_column_text(stmt, 10);
            if (s10==NULL) {
                s10="";
            }
            NSString *isNotice = [[NSString alloc] initWithCString:s10 encoding:NSUTF8StringEncoding];
            
            char *s11 = (char *)sqlite3_column_text(stmt, 11);
            if (s11==NULL) {
                s11="";
            }
            NSString *isNews = [[NSString alloc] initWithCString:s11 encoding:NSUTF8StringEncoding];
            // 封装
            selfMarketModel *model = [[selfMarketModel alloc] initWithDic:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                           ids,@"ids",
                                                                           marketId,@"marketId",
                                                                           marketName,@"marketName",
                                                                           marketType,@"marketType",
                                                                           userId,@"userId",
                                                                           time,@"timestamp",
                                                                           isSyn,@"isSyn",
                                                                           heightPrice,@"heightPrice",
                                                                           lowPrice,@"lowPrice",
                                                                           todayChangeRate,@"todayChangeRate",
                                                                           isNotice,@"isNotice",
                                                                           isNews,@"isNews",
                                                                           nil]];
            selfDatas = model;
            model = nil;
        }
        NSLog(@"查询成功");
    }else {
        
        NSLog(@"查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return selfDatas;
}

@end