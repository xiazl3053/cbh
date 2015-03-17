//
//  searchStocksDB.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "searchStocksDB.h"
#import "NSString+File.h"
#import "DCommon.h"
#import <sqlite3.h>
#import "searchStocksModel.h"

@interface searchStocksDB(){
    // 数据库实例，代表着整个数据库
    sqlite3 *_db;
    //表名
    NSString *_tableName;
}

@end
@implementation searchStocksDB

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
    NSString *filename = [self saveBundelToDocuments];
    // 如果数据库不存在，就会创建一个
    int result = sqlite3_open([filename UTF8String], &_db);
    if (result == SQLITE_OK) {
        NSLog(@"打开数据库成功!%@",[NSBundle mainBundle]);
        [self createTables];
    }else{
        NSLog(@"打开数据库失败!");
    }
}

#pragma mark 保存到Documents路径
-(NSString *)saveBundelToDocuments{
    // Documents路径
    NSString *filename = [DCommon documentsAppend:ksearchStockDBName];
    // Bundle 文件
    NSString *bFilename = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/DStocksBundle.bundle/"];
    bFilename = [bFilename stringByAppendingString:ksearchStockDBName];
    NSLog(@"---DFM---bundle:%@",bFilename);
    //复制文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    bool isexit=[fileManager fileExistsAtPath:filename];
    if (!isexit) {// 如果不存在
        //复制
        [fileManager copyItemAtPath:bFilename toPath:filename error:nil];
    }
    return filename;
}


#pragma mark 关闭数据库
-(void)closeDB{
    // 关闭数据库
    sqlite3_close(_db);
    
    NSLog(@"关闭了数据库!");
}
#pragma mark 创建表
- (void)createTables {
    //设置表名
    _tableName=@"StockTable";
    // 创建表 code 股票代码 market 市场类型  type 0=大盘 1=沪股 2=深股 pinyin 股票拼音简写 name股票名称
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, code text, market text, type text, pinyin text, name text);",_tableName];
    
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


#pragma mark 查询自选股列表数据
-(NSMutableArray *)searchStocksWithWhere:(NSString *)str{
    // 隔离数字与拼音
    NSString *number = [[DCommon findNumFromStr:str] objectAtIndex:0];
    NSString *pinyin = [[DCommon findNumFromStr:str] objectAtIndex:1];
    NSMutableArray *selfDatas=[NSMutableArray array];
    // 默认时间倒序排列
    NSString *string = [NSString stringWithFormat:@"select * from %@ where code like ? or pinyin like ? or name like ? order by pinyin asc limit 50;",_tableName];
    if (number.length>0 && pinyin.length>0) {
        string = [NSString stringWithFormat:@"select * from %@ where code like ? or pinyin like ? or name like ? order by pinyin asc limit 50;",_tableName];
    }
    else{
        if (number.length>0) {
            string = [NSString stringWithFormat:@"select * from %@ where code like ? order by pinyin asc limit 50;",_tableName];
        }
        if (pinyin.length>0) {
            string = [NSString stringWithFormat:@"select * from %@ where pinyin like ? or name like ? order by pinyin asc limit 50;",_tableName];
        }
    }
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些查询准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        if (number.length>0 && pinyin.length>0) {
            sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",number]UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [[NSString stringWithFormat:@"%%%@%%",pinyin]UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [[NSString stringWithFormat:@"%%%@%%",pinyin]UTF8String], -1, NULL);
        }else{
            if (number.length>0) {
                sqlite3_bind_text(stmt, 1,[[NSString stringWithFormat:@"%%%@%%",number]UTF8String], -1, NULL);
            }
            if (pinyin.length>0) {
                sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",pinyin]UTF8String], -1, NULL);
                sqlite3_bind_text(stmt, 2, [[NSString stringWithFormat:@"%%%@%%",pinyin]UTF8String], -1, NULL);
            }
        }
        
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
//            char *s0 = (char *)sqlite3_column_text(stmt, 0);
//            NSString *ids = [[NSString alloc] initWithCString:s0 encoding:NSUTF8StringEncoding];
            
            char *s1 = (char *)sqlite3_column_text(stmt, 1);
            if (s1==NULL) {
                s1="";
            }
            NSString *code = [[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
            
            char *s2 = (char *)sqlite3_column_text(stmt, 2);
            if (s2==NULL) {
                s2="";
            }
            NSString *market = [[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
            
            char *s3 = (char *)sqlite3_column_text(stmt, 3);
            if (s3==NULL) {
                s3="";
            }
            NSString *type = [[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
            
            char *s4 = (char *)sqlite3_column_text(stmt, 4);
            if (s4==NULL) {
                s4="";
            }
            NSString *pingyin = [[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
            
            char *s5 = (char *)sqlite3_column_text(stmt, 5);
            if (s5==NULL) {
                s5="";
            }
            NSString *name = [[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
            
            // 封装
            searchStocksModel *model = [[searchStocksModel alloc] init];
            model.code = code;
            model.market = market;
            model.type = type;
            model.pinyin = pingyin;
            model.name = name;
            [selfDatas addObject:model];
            model = nil;
        }
        NSLog(@"查询成功%@,%@,%@",string,pinyin,number);
    }else {
        
        NSLog(@"查询数据的SQL语句语法有问题%@",string);
    }
    sqlite3_finalize(stmt);
    return selfDatas;
}

@end
