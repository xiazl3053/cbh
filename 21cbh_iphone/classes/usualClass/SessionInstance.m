//
//  Instance.m
//  21cbh_iphone
//
//  Created by Franky on 14-8-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "SessionInstance.h"
#import <AddressBook/AddressBook.h>
#import "ContactItem.h"
#import "CWPHttpRequest.h"
#import "ESessions.h"
#import "ESessionsDB.h"
#import "EMessages.h"
#import "EMessagesDB.h"
#import "XMPPRoomManager.h"

@interface SessionInstance()
{
    BOOL isGetSession;
    BOOL isGetAddress;
    int unReadCount_;
    NSMutableArray* localContacts_;
    NSMutableArray* sessionArray_;
    UILocalNotification *localNotification;
}

@end

static SessionInstance* singleton=nil;

@implementation SessionInstance

+(SessionInstance *)instance{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [[SessionInstance alloc] init];
        }
    }
    return singleton;
    
}

+(id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

-(id)init
{
    if(self=[super init])
    {
        localContacts_=[NSMutableArray array];
        sessionArray_=[NSMutableArray array];
        [self initNotification];
    }
    return self;
}

#pragma mark 通知响应
-(void)initNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveMessage:) name:kXMPPNewMsgNotifaction object:nil];
}

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPNewMsgNotifaction object:nil];
}

-(void)dealloc
{
    [self removeNotification];
    [localContacts_ removeAllObjects];
    localContacts_=nil;
    [sessionArray_ removeAllObjects];
    sessionArray_=nil;
}

-(void)didReceiveMessage:(NSNotification*)notification
{
    EMessages* msg=[notification.userInfo objectForKey:@"newMsg"];
    if(msg){
        [self adjustMessageInArrays:msg];
    }
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        if(!localNotification){
            localNotification = [[UILocalNotification alloc] init];
        }
        localNotification.alertAction = @"Ok";
        localNotification.alertBody = [NSString stringWithFormat:@"%@:%@",msg.userName,msg.content];
        localNotification.applicationIconBadgeNumber=[[SessionInstance instance] totalUnReadCount];//标记数
        //localNotification.userInfo  = [NSDictionary dictionaryWithObject:msg forKey:@"newMsg"];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

-(void)adjustMessageInArrays:(EMessages*)message
{
    BOOL isExist=NO;
    NSMutableDictionary* dic=[NSMutableDictionary dictionary];
    for (int i=0;i<INSTANCE.SessionArray.count;i++)
    {
        ESessions* item=[INSTANCE.SessionArray objectAtIndex:i];
        if([item.jid isEqualToString:message.friends_jid]&&[item.myJID isEqualToString:message.myJID])
        {
            isExist=YES;
            if(![INSTANCE.currentJID isEqualToString:message.friends_jid]&&!message.isRead){
                item.unReadCount++;
            }
            item.content = message.content;
            item.message_time = [NSString stringWithFormat:@"%f",message.time];
            item.nickName = [XMPPJID jidWithString:message.friends_jid].bare;
            item.time = [[NSDate date] timeIntervalSince1970];
            [[ESessionsDB instance] updateWithSession:item];
            [dic setObject:item forKey:@"session"];
        }
    }
    if(!isExist)
    {
        ESessions *session = [[ESessions alloc] init];
        session.myJID = message.myJID;
        session.jid = message.friends_jid;
        session.time = [[NSDate date] timeIntervalSince1970];
        session.isTop = NO;
        if(![INSTANCE.currentJID isEqualToString:message.friends_jid]&&!message.isRead){
            session.unReadCount=1;
        }
        session.content = message.content;
        session.message_time = [NSString stringWithFormat:@"%f",message.time];
        session.nickName = [XMPPJID jidWithString:message.friends_jid].bare;
        if(message.isGroup)
        {
            session.session_type=EsesionPublicGroup;
            if(message.messageType==99)
            {
                session.sessionName=message.userName;
                [[XMPPRoomManager instance] joinRoomJid:message.friends_jid];
            }
        }
        else
        {
            session.session_type=EsesionPrivateChat;
        }
        [sessionArray_ addObject:session];
        [[ESessionsDB instance] insertWithSession:session];
        [dic setObject:session forKey:@"session"];
    }
    
    [self sortCurrentArray];
    
    [dic setObject:[NSString stringWithFormat:@"%d",isExist] forKey:@"isExist"];
    [dic setObject:[NSString stringWithFormat:@"%d",kSessionNewMsg] forKey:kSessionChangeType];
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPSessionChangeNotifaction
                                                       object:nil
                                                     userInfo:dic];
}

-(void)updateSession:(NSString*)friends_jid myJID:(NSString*)myJID isShield:(BOOL)isShield isTop:(BOOL)isTop
{
    BOOL isExist=NO;
    NSMutableDictionary* dic=[NSMutableDictionary dictionary];
    for (int i=0;i<INSTANCE.SessionArray.count;i++)
    {
        ESessions* item=[INSTANCE.SessionArray objectAtIndex:i];
        if([item.jid isEqualToString:friends_jid]&&[item.myJID isEqualToString:myJID])
        {
            isExist=YES;
            if(isShield)
            {
                item.isShiled=!item.isShiled;
            }
            if(isTop)
            {
                item.isTop=!item.isTop;
                item.time = [[NSDate date] timeIntervalSince1970];
            }
            [[ESessionsDB instance] updateWithSession:item];
            [dic setObject:item forKey:@"session"];
        }
    }
    if(!isExist&&isTop)
    {
        ESessions *session = [[ESessions alloc] init];
        session.myJID = myJID;
        session.jid = friends_jid;
        session.time = [[NSDate date] timeIntervalSince1970];
        session.isTop = NO;
        session.unReadCount=0;
        session.isShiled=isShield;
        session.isTop=isTop;
        [sessionArray_ insertObject:session atIndex:0];
        [[ESessionsDB instance] insertWithSession:session];
        [dic setObject:session forKey:@"session"];
    }
    
    [self sortCurrentArray];
    
    [dic setObject:[NSString stringWithFormat:@"%d",isExist] forKey:@"isExist"];
    [dic setObject:[NSString stringWithFormat:@"%d",kSessionUpdate] forKey:kSessionChangeType];
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPSessionChangeNotifaction
                                                       object:nil
                                                     userInfo:dic];
}

-(void)cleanSessionLast:(NSString *)friends_jid
{
    BOOL isExist=NO;
    NSMutableDictionary* dic=[NSMutableDictionary dictionary];
    for (int i=0;i<INSTANCE.SessionArray.count;i++)
    {
        ESessions* item=[INSTANCE.SessionArray objectAtIndex:i];
        if([item.jid isEqualToString:friends_jid])
        {
            isExist=YES;
            item.content=nil;
            item.message_time=nil;
            [dic setObject:item forKey:@"session"];
            break;
        }
    }
    if(isExist)
    {
        [dic setObject:[NSString stringWithFormat:@"%d",isExist] forKey:@"isExist"];
        [dic setObject:[NSString stringWithFormat:@"%d",kSessionUpdate] forKey:kSessionChangeType];
        [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPSessionChangeNotifaction
                                                           object:nil
                                                         userInfo:dic];
    }
}

-(void)sortCurrentArray
{
    NSSortDescriptor* sortByA = [NSSortDescriptor sortDescriptorWithKey:@"isTop" ascending:NO];
    NSSortDescriptor* sortByB = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    [sessionArray_ sortUsingDescriptors:[NSArray arrayWithObjects:sortByA,sortByB,nil]];
}

-(void)updateUnReadCount:(ESessions*)session count:(int)count
{
    if(session.unReadCount!=count)
    {
        NSMutableDictionary* dic=[NSMutableDictionary dictionary];
        if(session.unReadCount!=0&&count==0)
        {
            [[EMessagesDB instanceWithFriendJID:session.jid] setMessageStateWithIsRead:YES];
        }
        session.unReadCount=count;
        [[ESessionsDB instance] updateWithSession:session];
        [dic setObject:[NSString stringWithFormat:@"%d",kSessionUnRead] forKey:kSessionChangeType];
        [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPSessionChangeNotifaction
                                                           object:nil
                                                         userInfo:dic];
    }
}

-(void)updateSessionWithFriend:(EFriends *)efriends
{
    for (ESessions* session in INSTANCE.SessionArray)
    {
        if([session.jid isEqualToString:efriends.jid])
        {
            session.sessionName=efriends.nickName;
            break;
        }
    }
    NSMutableDictionary* dic=[NSMutableDictionary dictionary];
    [dic setObject:[NSString stringWithFormat:@"%d",kSessionUpdate] forKey:kSessionChangeType];
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPSessionChangeNotifaction
                                                       object:nil
                                                     userInfo:dic];
}

-(ESessions *)getSession:(NSString *)friends_jid
{
    for (ESessions* session in INSTANCE.SessionArray)
    {
        if([session.jid isEqualToString:friends_jid])
        {
            return session;
        }
    }
    return nil;
}

-(void)deleteSession:(ESessions *)session
{
    if(session)
    {
        [[ESessionsDB instance] deleteSession:session.jid];
        [sessionArray_ removeObject:session];
        NSMutableDictionary* dic=[NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%d",kSessionDelete] forKey:kSessionChangeType];
        [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPSessionChangeNotifaction
                                                           object:nil
                                                         userInfo:dic];
    }
}

-(void)getAddressBook
{
    if(!isGetAddress)
    {
        isGetAddress=YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ @autoreleasepool {
            ABAddressBookRef addressBook=ABAddressBookCreateWithOptions(nil, nil);
            //等待同意后向下执行
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
            if(ABAddressBookGetAuthorizationStatus()!=kABAuthorizationStatusAuthorized){
                return;
            }
            
            NSMutableSet* phoneSet=[NSMutableSet set];
            CFArrayRef addressArray=ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex count=ABAddressBookGetPersonCount(addressBook);
            for (int i=0; i<count; i++)
            {
                ContactItem* item=[[ContactItem alloc] init];
                ABRecordRef person=CFArrayGetValueAtIndex(addressArray, i);
                NSString* firstName=CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                firstName = firstName != nil?firstName:@"";
                NSString* lastName=CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
                lastName = lastName != nil?lastName:@"";
                NSString* fullName=[NSString stringWithFormat:@"%@ %@",lastName,firstName];
                item.userName=fullName;
                
                ABMultiValueRef phoneArray=ABRecordCopyValue(person, kABPersonPhoneProperty);
                CFIndex index=ABMultiValueGetCount(phoneArray);
                NSMutableArray* array=[NSMutableArray array];
                for (int i=0; i<index; i++) {
                    NSString * phone=CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneArray, i));
                    phone=[phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    phone=[phone stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                    phone=[phone stringByReplacingOccurrencesOfString:@" " withString:@""];
                    [array addObject:phone];
                    if(phone.length>=11)
                    {
                        [phoneSet addObject:phone];
                    }
                }
                item.phoneArray=array;
                [localContacts_ addObject:item];
                if (phoneSet.count>19||i==count-1)
                {
                    NSMutableString* phoneStr=[NSMutableString string];
                    BOOL flag=NO;
                    for (NSString* phone in phoneSet)
                    {
                        if(!flag)
                        {
                            flag=YES;
                        }
                        else
                        {
                            [phoneStr appendString:@","];
                        }
                        [phoneStr appendString:phone];
                    }
                    [phoneSet removeAllObjects];
                    [CWPHttpRequest postMatchContactsRequest:phoneStr completionBlock:^(NSDictionary *dic, BOOL isSuccess)
                     {
                         if (isSuccess)
                         {
                             NSArray* array=[dic objectForKey:@"data"];
                             if(array&&[array.class isSubclassOfClass:NSArray.class])
                             {
                                 for (NSDictionary* cDic in array)
                                 {
                                     NSString* status=[cDic objectForKey:@"status"];
                                     if([status isEqualToString:@"1"]||[status isEqualToString:@"0"])
                                     {
                                         NSString* phone=[cDic objectForKey:@"phone"];
                                         for (ContactItem* item in localContacts_)
                                         {
                                             if (item.phoneArray&&[item.phoneArray containsObject:phone])
                                             {
                                                 item.uuid=[cDic objectForKey:@"uuid"];
                                                 item.userPhone=phone;
                                                 if([status isEqualToString:@"0"])
                                                 {
                                                     item.isAdded=YES;
                                                 }
                                                 else
                                                 {
                                                     item.isUsed=YES;
                                                 }
                                             }
                                         }
                                     }
                                 }
                             }
                         }
                     }];
                    //usleep(1);
                }
                CFRelease(person);
            }
            CFRelease(addressBook);
            }
        });
    }
}

-(NSArray *)ContactArrays
{
    return localContacts_;
}

-(int)totalUnReadCount
{
    unReadCount_=0;
    for (ESessions* session in sessionArray_)
    {
        unReadCount_+=session.unReadCount;
    }
    return unReadCount_;
}

-(NSArray *)SessionArray
{
    if(!isGetSession)
    {
        isGetSession=YES;
        sessionArray_=[[ESessionsDB instance] selectSessions];
    }
    return sessionArray_;
}

@end
