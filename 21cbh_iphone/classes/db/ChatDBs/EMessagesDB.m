//
//  EMessagesDB.m
//  21cbh_iphone
//
//  Created by 21tech on 14-6-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "EMessagesDB.h"
#import "NSString+File.h"
#import <sqlite3.h>
#import "CommonOperation.h"
#import "EMessages.h"
#import "XMPPServer.h"

@interface EMessagesDB(){
    sqlite3 *_db;
}
@end

static EMessagesDB *instance;
static NSString* tableName_;
static NSMutableDictionary* tableNameDic;

@implementation EMessagesDB

+(EMessagesDB *)instanceWithFriendJID:(NSString*)friend_jid
{
    @synchronized(self){
        if(!instance){
            instance=[[EMessagesDB alloc] init];
        }
        if(![instance isExistTable:friend_jid])
        {
            [instance createTable:friend_jid];
        }
        tableName_=[tableNameDic objectForKey:friend_jid];
        return instance;
    }
}

-(id)init{
    if(self=[super init]){
        tableNameDic=[NSMutableDictionary new];
        [self openDB];
    }
    return self;
}

-(void)dealloc
{
    [tableNameDic removeAllObjects];
    tableNameDic=nil;
    tableName_=nil;
    [self closeDB];
}

#pragma mark 打开数据库
-(BOOL)openDB {
    
    if(_db){
        return YES;
    }
    
    // 数据库文件路径
    NSString *myjid = KUserJID;
    if(!myjid){
        return NO;
    }
    myjid = [myjid stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSString *filename = [NSString stringWithFormat:@"ChatMessageDB_%@.db",myjid];
    filename = [filename documentsAppend];
    
    NSLog(@"%@",filename);
    //检测是否需要删数据库文件
    [[CommonOperation getId] checkTableDeleteWithClassName:@"EMessagesDB" path:filename];
    
    
    // 如果数据库不存在，就会创建一个
    int result = sqlite3_open([filename UTF8String], &_db);
    if (result == SQLITE_OK) {
        //NSLog(@"打开数据库成功!");
    }else{
        NSLog(@"打开数据库失败!");
        return NO;
    }
    return YES;
}

#pragma mark 关闭数据库
-(void)closeDB{
    if (_db) {
        // 关闭数据库
        sqlite3_close(_db);
    }

    //NSLog(@"关闭了数据库!");
}

-(BOOL)isExistTable:(NSString*)friendJID
{
    return [tableNameDic objectForKey:friendJID]!=nil;
}

#pragma mark 创建表
- (void)createTable:(NSString*)friendJID
{
    //设置表名
    NSString* tableName=[self getTableNameWithFriendJID:friendJID];
    
    NSString *string=[NSString stringWithFormat:@"create table if not exists %@(guid text primary key, myJID text,friends_jid text,content text,time text,messageType text,isSelf text,wavSecond text,isRead text,isSend text,picUrls text,description text,programId text,articleId text,KId text,KType text,KName text,isSys text,userName text,isGroup text,resource text,otherData text);",tableName];
    
    const char *sql =[string UTF8String];
    
    char *error;
    // sqlite3_exec能执行一切SQL语句
    // insert into t_person(name, age) values('mj', 10);
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    
    if (result == SQLITE_OK) {
        [tableNameDic setObject:tableName forKey:friendJID];
        //NSLog(@"创表成功!");
    }else{
        NSLog(@"创表错误：%s", error);
    }
}

-(NSString*)getTableNameWithFriendJID:(NSString*)friendJID
{
    NSString* tableName=[NSString stringWithFormat:@"EMessages_%@",friendJID];
    tableName = [tableName stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    tableName = [tableName stringByReplacingOccurrencesOfString:@"@" withString:@"_"];
    tableName = [tableName stringByReplacingOccurrencesOfString:@"#" withString:@"_"];
    tableName = [tableName stringByReplacingOccurrencesOfString:@"%" withString:@"_"];
    tableName = [tableName stringByReplacingOccurrencesOfString:@"^" withString:@"_"];
    //tableName = [tableName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return tableName;
}

#pragma mark 插入数据
-(BOOL)insertWithMessage:(EMessages *)message
{
    return [self insertWithMessage:message isNotifaction:YES];
}

-(BOOL)insertWithMessage:(EMessages *)message isNotifaction:(BOOL)flag
{
    BOOL isSusses=NO;
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"insert into %@(guid,myJID,friends_jid,content,time,messageType,isSelf,wavSecond,isRead,isSend,picUrls,description,programId,articleId,KId,KType,KName,isSys,userName,isGroup,resource,otherData) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",tableName_];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        const char *guid=[message.guid UTF8String];
        const char *myJID=[message.myJID UTF8String];
        const char *friends_jid=[message.friends_jid UTF8String];
        const char *content=[message.content UTF8String];
        const char *time=[[NSString stringWithFormat:@"%f",message.time] UTF8String];
        const char *messageType=[[NSString stringWithFormat:@"%d",message.messageType] UTF8String];
        const char *isSelf=[[NSString stringWithFormat:@"%d",message.isSelf] UTF8String];
        const char *wavSecond=[[NSString stringWithFormat:@"%f",message.wavSecond] UTF8String];
        const char *isRead=[[NSString stringWithFormat:@"%d",message.isRead] UTF8String];
        const char *isSend=[[NSString stringWithFormat:@"%d",message.isSend] UTF8String];
        const char *picUrls=[[message.picUrls JSONRepresentation] UTF8String];
        const char *description=[message.msgDesc UTF8String];
        const char *programId = [message.programId UTF8String];
        const char *articleId = [message.articleId UTF8String];
        const char *KId = [message.KId UTF8String];
        const char *KType = [message.KType UTF8String];
        const char *KName=[message.KName UTF8String];
        const char *isSys=[[NSString stringWithFormat:@"%d",message.isSys] UTF8String];
        const char *userName=message.userName.UTF8String;
        const char *isGroup=[[NSString stringWithFormat:@"%d",message.isGroup] UTF8String];
        const char *resource=[message.resource UTF8String];
        const char *otherData=nil;
        if(message.otherData){
           otherData=[[message.otherData JSONRepresentation] UTF8String];
        }
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, guid, -1, NULL);
        sqlite3_bind_text(stmt, 2, myJID, -1, NULL);
        sqlite3_bind_text(stmt, 3, friends_jid, -1, NULL);
        sqlite3_bind_text(stmt, 4, content, -1, NULL);
        sqlite3_bind_text(stmt, 5, time, -1, NULL);
        sqlite3_bind_text(stmt, 6, messageType, -1, NULL);
        sqlite3_bind_text(stmt, 7, isSelf, -1, NULL);
        sqlite3_bind_text(stmt, 8, wavSecond, -1, NULL);
        sqlite3_bind_text(stmt, 9, isRead, -1, NULL);
        sqlite3_bind_text(stmt, 10, isSend, -1, NULL);
        sqlite3_bind_text(stmt, 11, picUrls, -1, NULL);
        sqlite3_bind_text(stmt, 12, description, -1, NULL);
        sqlite3_bind_text(stmt, 13, programId, -1, NULL);
        sqlite3_bind_text(stmt, 14, articleId, -1, NULL);
        sqlite3_bind_text(stmt, 15, KId, -1, NULL);
        sqlite3_bind_text(stmt, 16, KType, -1, NULL);
        sqlite3_bind_text(stmt, 17, KName, -1, NULL);
        sqlite3_bind_text(stmt, 18, isSys, -1, NULL);
        sqlite3_bind_text(stmt, 19, userName, -1, NULL);
        sqlite3_bind_text(stmt, 20, isGroup, -1, NULL);
        sqlite3_bind_text(stmt, 21, resource, -1, NULL);
        sqlite3_bind_text(stmt, 22, otherData, -1, NULL);
        
        // 执行sql语句
        result=sqlite3_step(stmt);
        if (result== SQLITE_DONE) {
            NSLog(@"插入数据成功！");
            isSusses=YES;
        } else {
            NSLog(@"插入消息数据失败，错误代码：%d",result);
        }
    } else {
        NSLog(@"插入消息数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    if(flag&&isSusses)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction
                                                               object:nil
                                                             userInfo:[NSDictionary dictionaryWithObject:message forKey:@"newMsg"]];
        });
    }
    return isSusses;
}

#pragma mark 更新数据默认通知
-(void)updateWithMessage:(EMessages *)message
{
    [self updateWithMessage:message isNotifaction:YES];
}

#pragma mark 更新数据是否通知
-(void)updateWithMessage:(EMessages *)message isNotifaction:(BOOL)flag
{
    NSString* str=[NSString stringWithFormat:@"update %@ set myJID=?,friends_jid=?,content=?,time=?,messageType=?,isSelf=?,wavSecond=?,isRead=?,isSend=?,picUrls=?,description=?,programId=?,articleId=?,KId=?,KType=?,userName=?,otherData=? where guid='%@';",tableName_,message.guid];
    
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, nil)==SQLITE_OK)
    {
        const char *myJID=[message.myJID UTF8String];
        const char *friends_jid=[message.friends_jid UTF8String];
        const char *content=[message.content UTF8String];
        const char *time=[[NSString stringWithFormat:@"%f",message.time] UTF8String];
        const char *messageType=[[NSString stringWithFormat:@"%d",message.messageType] UTF8String];
        const char *isSelf=[[NSString stringWithFormat:@"%d",message.isSelf] UTF8String];
        const char *wavSecond=[[NSString stringWithFormat:@"%f",message.wavSecond] UTF8String];
        const char *isRead=[[NSString stringWithFormat:@"%d",message.isRead] UTF8String];
        const char *isSend=[[NSString stringWithFormat:@"%d",message.isSend] UTF8String];
        const char *picUrls=[[message.picUrls JSONRepresentation] UTF8String];
        const char *description=[message.msgDesc UTF8String];
        const char *programId = [message.programId UTF8String];
        const char *articleId = [message.articleId UTF8String];
        const char *KId = [message.KId UTF8String];
        const char *KType = [message.KType UTF8String];
        const char *userName=message.userName.UTF8String;
        const char *otherData=nil;
        if(message.otherData){
            otherData=[[message.otherData JSONRepresentation] UTF8String];
        }
        
        // 第2个int类型的参数用来指定第几列，从1开始
        sqlite3_bind_text(stmt, 1, myJID, -1, NULL);
        sqlite3_bind_text(stmt, 2, friends_jid, -1, NULL);
        sqlite3_bind_text(stmt, 3, content, -1, NULL);
        sqlite3_bind_text(stmt, 4, time, -1, NULL);
        sqlite3_bind_text(stmt, 5, messageType, -1, NULL);
        sqlite3_bind_text(stmt, 6, isSelf, -1, NULL);
        sqlite3_bind_text(stmt, 7, wavSecond, -1, NULL);
        sqlite3_bind_text(stmt, 8, isRead, -1, NULL);
        sqlite3_bind_text(stmt, 9, isSend, -1, NULL);
        sqlite3_bind_text(stmt, 10, picUrls, -1, NULL);
        sqlite3_bind_text(stmt, 11, description, -1, NULL);
        sqlite3_bind_text(stmt, 12, programId, -1, NULL);
        sqlite3_bind_text(stmt, 13, articleId, -1, NULL);
        sqlite3_bind_text(stmt, 14, KId, -1, NULL);
        sqlite3_bind_text(stmt, 15, KType, -1, NULL);
        sqlite3_bind_text(stmt, 16, userName, -1, NULL);
        sqlite3_bind_text(stmt, 17, otherData, -1, NULL);
        
        if(sqlite3_step(stmt)!=SQLITE_DONE)
        {
            NSLog(@"updateWithMessage更新数据失败！");
        }
    }
    else
    {
        NSLog(@"updateWithMessage更新数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    if(flag)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPMsgStatusNotifaction
                                                               object:nil
                                                             userInfo:[NSDictionary dictionaryWithObject:message forKey:@"updateMsg"]];
        });
    }
    message=nil;
}

-(void)setMessageStateWithIsRead:(BOOL)isRead{
    
    NSString* str=[NSString stringWithFormat:@"update %@ set isRead=%d where isRead=0;",tableName_,isRead];
    sqlite3_stmt *stmt;
    int result=sqlite3_prepare_v2(_db, str.UTF8String, -1, &stmt, nil);
    if(result==SQLITE_OK)
    {
        if(sqlite3_step(stmt)!=SQLITE_DONE)
        {
            NSLog(@"setMessageStateWithIsRead更新数据失败！");
        }
    }
    else
    {
        NSLog(@"setMessageStateWithIsRead更新数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除全部数据
-(void)deleteAllMessage
{
    NSString *string=[NSString stringWithFormat:@"delete from %@;",tableName_];
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
        NSLog(@"删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
-(BOOL)deleteMessage:(NSString*)guid{
    BOOL flag=NO;
    //sql插入语句
    NSString *string=[NSString stringWithFormat:@"delete from %@ where (guid='%@');",tableName_,guid];
    const char *sql = [string UTF8String];
    sqlite3_stmt *stmt;
    
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 执行sql语句
        if (sqlite3_step(stmt)==SQLITE_DONE) {
            NSLog(@"删除消息:%@数据成功！",guid);
            flag=YES;
        } else {
            NSLog(@"删除数据失败！");
        }
    } else {
        NSLog(@"删除数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return flag;
}

#pragma mark 查询数据
-(NSMutableArray *)selectMessageWithPage:(int)page{
    NSMutableArray *array=[NSMutableArray array];
    NSString *string=[NSString stringWithFormat:@"select * from %@ order by time desc limit %d*15,15;",tableName_,page];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
            
            EMessages *msg=[self messageItem:stmt];

            [array addObject:msg];
        }
    }else {
        NSLog(@"查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return array;
}

-(EMessages*)getLastMessage{
    EMessages *message;
    NSString *string=[NSString stringWithFormat:@"select * from %@ order by time desc limit 0,1;",tableName_];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
            message=[self messageItem:stmt];
        }
    }else {
        NSLog(@"查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return message;
}

-(int)getLastInsertID{
    int rowid = 0;
    NSString *string=[NSString stringWithFormat:@"SELECT LAST_INSERT_ROWID() FROM %@;",tableName_];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    // sqlite3_prepare_v2做一些插入数据的准备
    // 主要是检查SQL语句的语法问题
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        // 如果返回值是ROW,代表读取到一行数据
        while (sqlite3_step(stmt) == SQLITE_ROW){
            char *s0 = (char *)sqlite3_column_text(stmt, 0);
            NSString *rowid_=[[NSString alloc] initWithCString:s0 encoding:NSUTF8StringEncoding];
            rowid = [rowid_ intValue];
        }
    }else {
        NSLog(@"查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return rowid;
}

-(int)getUnReadCountWithJID:(NSString *)myJID
{
    char* error=NULL;
    char** result;
    int row=0;
    int column=0;
    NSString* sql=[NSString stringWithFormat:@"select * from %@ where isRead='0' and myJID='%@'",tableName_,myJID];
    sqlite3_get_table(_db, sql.UTF8String, &result, &row, &column, &error);
    if(error){
        return 0;
    }
    sqlite3_free_table(result);
    return row;
}

-(NSArray*)getUnSendedMessages
{
    NSString *string=[NSString stringWithFormat:@"select * from %@ where isSend=0 order by time asc;",tableName_];
    return [self getSelectArrayBySQL:string];
}

-(NSArray *)getImageTypeMessages
{
    NSString *string=[NSString stringWithFormat:@"select * from %@ where messageType=1 order by time asc;",tableName_];
    return [self getSelectArrayBySQL:string];
}

-(NSArray*)getSelectArrayBySQL:(NSString*)string
{
    NSMutableArray *array=[NSMutableArray array];
    const char *sql = [string UTF8String];
    
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    // 说明语句没有语法问题
    if (result == SQLITE_OK) {
        int i=0;
        while (sqlite3_step(stmt) == SQLITE_ROW){
            i++;
            
            EMessages *m=[self messageItem:stmt];
            
            [array addObject:m];
        }
    }else {
        NSLog(@"查询数据的SQL语句语法有问题");
    }
    sqlite3_finalize(stmt);
    return array;
}

-(EMessages*)messageItem:(sqlite3_stmt*)stmt
{
    EMessages* msg=[[EMessages alloc] init];
    
    char *s1 = (char *)sqlite3_column_text(stmt, 0);
    if (s1) {
        NSString *guid=[[NSString alloc] initWithCString:s1 encoding:NSUTF8StringEncoding];
        msg.guid = guid;
    }
    
    char *s2 = (char *)sqlite3_column_text(stmt, 1);
    NSString *myJID=[[NSString alloc] initWithCString:s2 encoding:NSUTF8StringEncoding];
    msg.myJID = myJID;
    
    char *s3 = (char *)sqlite3_column_text(stmt, 2);
    if (s3) {
        NSString *friends_jid=[[NSString alloc] initWithCString:s3 encoding:NSUTF8StringEncoding];
        msg.friends_jid = friends_jid;
    }
    
    char *s4 = (char *)sqlite3_column_text(stmt, 3);
    if (s4) {
        NSString *content=[[NSString alloc] initWithCString:s4 encoding:NSUTF8StringEncoding];
        msg.content = content;
    }
    
    char *s5 = (char *)sqlite3_column_text(stmt, 4);
    if (s5) {
        NSString *time=[[NSString alloc] initWithCString:s5 encoding:NSUTF8StringEncoding];
        msg.time = [time doubleValue];
    }
    
    char *s6 = (char *)sqlite3_column_text(stmt, 5);
    NSString *messageType=[[NSString alloc] initWithCString:s6 encoding:NSUTF8StringEncoding];
    msg.messageType = [messageType intValue];
    
    char *s7 = (char *)sqlite3_column_text(stmt, 6);
    NSString *isSelf=[[NSString alloc] initWithCString:s7 encoding:NSUTF8StringEncoding];
    msg.isSelf = [isSelf intValue];
    
    char *s8 = (char *)sqlite3_column_text(stmt, 7);
    NSString *wavSecond=[[NSString alloc] initWithCString:s8 encoding:NSUTF8StringEncoding];
    msg.wavSecond = [wavSecond doubleValue];
    
    char *s9 = (char *)sqlite3_column_text(stmt, 8);
    NSString *isRead=[[NSString alloc] initWithCString:s9 encoding:NSUTF8StringEncoding];
    msg.isRead = [isRead intValue];
    
    char *s10 = (char *)sqlite3_column_text(stmt, 9);
    NSString *isSend=[[NSString alloc] initWithCString:s10 encoding:NSUTF8StringEncoding];
    msg.isSend = [isSend intValue];
    
    
    char *s11 = (char *)sqlite3_column_text(stmt, 10);
    if (s11) {
        NSString *picUrls=[[NSString alloc] initWithCString:s11 encoding:NSUTF8StringEncoding];
        msg.picUrls = [picUrls JSONValue] ;
    }
    
    
    char *s12 = (char *)sqlite3_column_text(stmt, 11);
    if (s12) {
        NSString *msgDesc=[[NSString alloc] initWithCString:s12 encoding:NSUTF8StringEncoding];
        msg.msgDesc = msgDesc;
    }
    
    char *s13 = (char *)sqlite3_column_text(stmt, 12);
    if (s13) {
        NSString *programId=[[NSString alloc] initWithCString:s13 encoding:NSUTF8StringEncoding];
        msg.programId = programId;
    }
    
    char *s14 = (char *)sqlite3_column_text(stmt, 13);
    if (s14) {
        NSString *articleId=[[NSString alloc] initWithCString:s14 encoding:NSUTF8StringEncoding];
        msg.articleId = articleId;
    }
    
    char *s15 = (char *)sqlite3_column_text(stmt, 14);
    if (s15) {
        NSString *KId=[[NSString alloc] initWithCString:s15 encoding:NSUTF8StringEncoding];
        msg.KId = KId;
    }
    
    char *s16 = (char *)sqlite3_column_text(stmt, 15);
    if (s16) {
        NSString *KType=[[NSString alloc] initWithCString:s16 encoding:NSUTF8StringEncoding];
        msg.KType = KType;
    }
    
    char *s17=(char *)sqlite3_column_text(stmt, 16);
    if(s17){
        NSString *kName=[[NSString alloc] initWithCString:s17 encoding:NSUTF8StringEncoding];
        msg.kName = kName;
    }
    
    char *s18=(char *)sqlite3_column_text(stmt, 17);
    if(s18){
        NSString *isSys=[[NSString alloc] initWithCString:s18 encoding:NSUTF8StringEncoding];
        msg.isSys = [isSys intValue];
    }
    
    char *s19 = (char *)sqlite3_column_text(stmt, 18);
    if (s19) {
        NSString *userName=[[NSString alloc] initWithCString:s19 encoding:NSUTF8StringEncoding];
        msg.userName = userName;
    }
    
    char *s20=(char *)sqlite3_column_text(stmt, 19);
    if(s20){
        NSString *isGroup=[[NSString alloc] initWithCString:s20 encoding:NSUTF8StringEncoding];
        msg.isGroup = [isGroup intValue];
    }
    
    char *s21=(char *)sqlite3_column_text(stmt, 20);
    if(s21){
        NSString *resource=[[NSString alloc] initWithCString:s21 encoding:NSUTF8StringEncoding];
        msg.resource=resource;
    }
    
    char *s22=(char *)sqlite3_column_text(stmt, 21);
    if(s22){
        NSString *otherData=[[NSString alloc] initWithCString:s22 encoding:NSUTF8StringEncoding];
        msg.otherData=[otherData JSONValue];
    }
    
    return msg;
}

@end
