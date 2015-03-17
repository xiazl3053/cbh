//
//  XMPPRoomModel.m
//  21cbh_iphone
//
//  Created by qinghua on 14-6-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XMPPRoomManager.h"
#import "XMPPRoom.h"
#import "XMPPRoster.h"
#import "CommonOperation.h"
#import "XMPPFramework.h"
#import "XMPPServer.h"
#define KRoomServerDomain @"conference.im.21cbh.com"


static XMPPRoomManager *singleton=nil;
static NSOperationQueue *_XMPPQueue = nil;
static XMPPRoster  *_xmppRoster=nil;
static XMPPRosterCoreDataStorage *_xmppRosterStorage=nil;
static XMPPRoomCoreDataStorage *_xmppRoomStroage=nil;
@implementation XMPPRoomManager


#pragma mark - singleton
#pragma mark -sharedRoomManager
+(XMPPRoomManager *)instance{
    @synchronized(self){
        if (singleton == nil) {
            _XMPPQueue = [[NSOperationQueue alloc] init];
            _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
            if (_xmppRosterStorage==nil) {
                _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
            }
            _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage dispatchQueue:nil];
            
            
            _xmppRoomStroage=[[XMPPRoomCoreDataStorage alloc]init];
            if (_xmppRoomStroage==nil) {
                _xmppRoomStroage=[[XMPPRoomCoreDataStorage alloc]init];
            }
//            XMPPJID *jid=[XMPPJID jidWithString:KUserJID];
//            _xmppRoom=[[XMPPRoom alloc]initWithRoomStorage:_xmppRoomStroage jid:jid dispatchQueue:nil];
//            
            singleton = [[self alloc] init];
        }
    }
    return singleton;
    
}

#pragma mark -allocWithZone
+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;
        }
    }
    return nil;
}

#pragma mark -copyWithZone
- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}
/*********************************************No back***********************/
#pragma mark - custom
#pragma mark -createRoom
-(void)createRoom{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:KUserName,@"uuid",@"room/createRoom",@"m", nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq];
    NSLog(@"\n requestUserinfomation===%@\n",iq);
}
#pragma mark -addRoomUser
-(void)addRoomUser:(NSArray *)userJids andRoomJid:(NSString *)roomJid{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];

    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"room/addRoomUser",@"m",roomJid,@"roomJid", nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    [dic setValue:userJids forKey:@"uuids"];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq];
    NSLog(@"addRoomUser====%@",iq);
    
}
#pragma mark -getUserJoinRoomsList
-(void)getUserJoinRoomsListWithUserName:(NSString *)userName{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:userName,@"uuid",@"room/getJoinRooms",@"m", nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq];
    NSLog(@"\n requestUserinfomation===%@\n",iq);
}

#pragma mark -getRoomUsersListWithRoomJid
-(void)getRoomUsersListWithRoomJid:(NSString *)roomJid{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"test1",@"userName",@"room/getRoomUsers",@"m",roomJid,@"roomName", nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq];
    NSLog(@"getRoomUserList====%@",iq);
}

#pragma mark -加入房间
-(void)joinRoomJid:(NSString *)roomJid{
    
    
   // <presence id="9h928-18" to="test1_1406260293406@conference.im.21cbh.com/test11@im.21cbh.com/Smack"><x xmlns="http://jabber.org/protocol/muc"></x></presence>
    
    NSXMLElement *presence=[NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    [presence addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@/%@",roomJid,KUserJID]];
    NSXMLElement *x=[NSXMLElement elementWithName:@"x"];
    [x addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc"];
    [presence addChild:x];
    
    [[XMPPServer sharedServer]sendElement:presence];
    NSLog(@"joinRoomJid====%@",presence);
    
}

#pragma mark -获取好友信息
-(void)getFriendInfomationWithIdentifer:(NSString *)identifier{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:identifier,@"keyword",@"user/search",@"m", nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq];
    NSLog(@"getFriendInfomationWithIdentifer====%@",iq);
}

#pragma mark -test
-(void)getUserinfomation:(NSString *)userID{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    // [iq addAttributeWithName:@"from" stringValue:KUserJID];
    [iq addAttributeWithName:@"id" stringValue:@"getUserinfomation"];
    // [iq addAttributeWithName:@"to" stringValue:KRoomServerDomain];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:@"11111",@"userId",@"room/createRoom",@"m", nil];
    
    method.stringValue=[dic JSONRepresentation];
    
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq];
    NSLog(@"\n requestUserinfomation===%@\n",iq);
    
}

#pragma mark - 好友操作
#pragma mark -添加好友请求
- (void)addFriendSubscribe:(NSString *)jid
{
   // <presence xmlns="jabber:client" id="H84pF-38" to="test8@127.0.0.1" type="subscribe" from="test6@127.0.0.1"/>
    //<presence xmlns="jabber:client" id="PQS1F-31" to="test6@im.21cbh.com" type="subscribe" from="test5@im.21cbh.com"/>
    
    NSXMLElement *presence=[NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"from" stringValue:KUserJID];
    [presence addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [presence addAttributeWithName:@"to" stringValue:jid];
    [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
    [presence addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSLog(@"\npresence===%@\n",presence);
    [[XMPPServer sharedServer] sendElement:presence];

}
#pragma mark -响应好友请求
-(void)acceptPresenceSubscriptionRequestFrom:(NSString *)name andAccept:(BOOL)b{
    XMPPJID *jid = [XMPPJID jidWithString:name];
    if(b){
       // [_xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:b];
        
      // presence===<presence xmlns="jabber:client" id="VhLvB-35" to="test5@im.21cbh.com" type="subscribe" from="test6@im.21cbh.com"/>
        
        NSXMLElement *presence=[NSXMLElement elementWithName:@"presence"];
        [presence addAttributeWithName:@"from" stringValue:KUserJID];
        [presence addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
        [presence addAttributeWithName:@"to" stringValue:name];
        [presence addAttributeWithName:@"type" stringValue:@"subscribed"];
        NSLog(@"\npresence===%@\n",presence);
        [[XMPPServer sharedServer] sendElement:presence];
        
    }else{
        //[_xmppRoster rejectPresenceSubscriptionRequestFrom:jid];
        
       // <presence xmlns="jabber:client" id="l62bl-29" to="test5@im.21cbh.com" type="unsubscribe" from="test6@im.21cbh.com"/>
        
        NSXMLElement *presence=[NSXMLElement elementWithName:@"presence"];
        [presence addAttributeWithName:@"from" stringValue:KUserJID];
        [presence addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
        [presence addAttributeWithName:@"to" stringValue:name];
        [presence addAttributeWithName:@"type" stringValue:@"unsubscribe"];
        NSLog(@"\npresence===%@\n",presence);
        [[XMPPServer sharedServer] sendElement:presence];
    }
}

#pragma mark - 房间操作
#pragma mark -邀请好友加入房间
-(void)invitedFriends:(NSString *)friendJID andRoomJID:(NSString *)roomJID{
    NSXMLElement *presence = [NSXMLElement elementWithName:@"message"];
    [presence addAttributeWithName:@"from" stringValue:KUserJID];
    [presence addAttributeWithName:@"to" stringValue:roomJID];
    [presence addAttributeWithName:@"id" stringValue:@"invitedFriend"];
    NSXMLElement *x=[NSXMLElement elementWithName:@"x"];
    [x addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#user"];
    NSXMLElement *intve=[NSXMLElement elementWithName:@"invite"];
    [intve addAttributeWithName:@"to" stringValue:friendJID];
    NSXMLElement *reason=[NSXMLElement elementWithName:@"reason"];
    reason.stringValue=@"hi hi";
    [presence addChild:x];
    [x addChild:intve];
    [intve addChild:reason];
    NSLog(@"presence===%@",presence);
    [presence addAttributeWithName:@"reason" stringValue:@"Hey Hecate, this is the place for all good witches!"];
    [[XMPPServer sharedServer] sendElement:presence];
}
-(void)acceptFriend:(NSString *)jid{

    //<iq xmlns="jabber:client" type="set" id="111-73" to="test7@im.21cbh.com/21APP"><query xmlns="jabber:iq:roster"><item jid="test6@im.21cbh.com" subscription="to"/></query></iq>
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:roster"];
    [iq  addAttributeWithName:@"type" stringValue:@"set"];
    [iq  addAttributeWithName:@"to" stringValue:jid];
    
    
}

#pragma mark -进入房间
-(void)intoRoom:(NSString *)roomJID{
    NSXMLElement *presence=[NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"from" stringValue:KUserJID];
    [presence addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@/%@",roomJID,KUserName]];
    NSXMLElement *x=[NSXMLElement elementWithName:@"x"];
    [x addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc"];
    [presence addChild:x];
    NSLog(@"\n******intoRoom********===%@\n",presence);
    [[XMPPServer sharedServer] sendElement:presence];
}

#pragma  mark -退出房间
-(void)exitRoom:(NSString *)roomJID{
    NSXMLElement *presence=[NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"from" stringValue:KUserJID];
    [presence addAttributeWithName:@"to" stringValue:roomJID];
    [presence addAttributeWithName:@"type" stringValue:@"unavailable"];
    NSLog(@"\npresence===%@\n",presence);
    [[XMPPServer sharedServer] sendElement:presence];
}

#pragma  mark -创建Room<TempRoom>
-(void)createRoom:(NSString *)roomName andUserNickName:(NSString *)nickName{
    NSXMLElement *presence=[NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"from" stringValue:KUserJID];
    //Room ID,Domain name,UserNcik name,temp Room
    [presence addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@/%@",roomName,KRoomServerDomain,nickName]];
    NSXMLElement *x=[NSXMLElement elementWithName:@"x"];
    [x addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc"];
    [presence addChild:x];
    NSLog(@"\npresence===%@\n",presence);
    [[XMPPServer sharedServer] sendElement:presence];
}

#pragma mark -requestRoomConfiguration
-(void)requestReserveRoomConfiguration:(NSString *)roomJID{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"from" stringValue:KUserJID];
    [iq addAttributeWithName:@"id" stringValue:@"requestReserveRoomConfiguration"];
    [iq addAttributeWithName:@"to" stringValue:roomJID];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#owner"];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq];
    NSLog(@"\n requestReserveRoomConfiguration===%@\n",iq);

}

#pragma mark -配置RoomProperty
-(void)configurationRoomPreperty:(NSString *)roomJID{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"from" stringValue:KUserJID];
    [iq addAttributeWithName:@"id" stringValue:@"create"];
    [iq addAttributeWithName:@"to" stringValue:roomJID];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#owner"];
    
    NSXMLElement *x=[NSXMLElement elementWithName:@"x"];
    [x addAttributeWithName:@"xmlns" stringValue:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    NSXMLElement *field=[NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    NSXMLElement *value=[NSXMLElement elementWithName:@"value"];
    value.stringValue=@"http://jabber.org/protocol/muc#roomconfig";
    [field addChild:value];
    
    NSXMLElement *field1=[NSXMLElement elementWithName:@"field"];
    [field1 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];
    NSXMLElement *value1=[NSXMLElement elementWithName:@"value"];
    value1.stringValue=@"A Dark Cave";
    [field1 addChild:value1];
    
    NSXMLElement *field2=[NSXMLElement elementWithName:@"field"];
    [field2 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomdesc"];
    NSXMLElement *value2=[NSXMLElement elementWithName:@"value"];
    value2.stringValue=@"The place for all good witches!";
    [field2 addChild:value2];
    
    NSXMLElement *field3=[NSXMLElement elementWithName:@"field"];
    [field3 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_enablelogging"];
    NSXMLElement *value3=[NSXMLElement elementWithName:@"value"];
    value3.stringValue=@"0";
    [field3 addChild:value3];
    
    
    NSXMLElement *field4=[NSXMLElement elementWithName:@"field"];
    [field4 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];
    NSXMLElement *value4=[NSXMLElement elementWithName:@"value"];
    value4.stringValue=@"0";
    [field4 addChild:value4];
    
    NSXMLElement *field5=[NSXMLElement elementWithName:@"field"];
    [field5 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_moderatedroom"];
    NSXMLElement *value5=[NSXMLElement elementWithName:@"value"];
    value5.stringValue=@"0";
    [field5 addChild:value5];
    
    NSXMLElement *field6=[NSXMLElement elementWithName:@"field"];
    [field6 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    NSXMLElement *value6=[NSXMLElement elementWithName:@"value"];
    value6.stringValue=@"1";
    [field6 addChild:value6];
    
    [x addChild:field];
    [x addChild:field1];
    [x addChild:field2];
    [x addChild:field3];
    [x addChild:field4];
    [x addChild:field5];
    [x addChild:field6];
    
    [query addChild:x];
    [iq addChild:query];
    
    [[XMPPServer sharedServer] sendElement:iq];
    NSLog(@"\n create===%@\n",iq);
}

#pragma mark -getGroupList
-(void)getGroupList:(NSString *)roomDomain{
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"from" stringValue:KUserJID];
    [iq addAttributeWithName:@"id" stringValue:@"getGroupList"];
    [iq addAttributeWithName:@"to"stringValue:roomDomain];
    [iq addAttributeWithName:@"type"stringValue:@"get"];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    
    [[XMPPServer sharedServer] sendElement:iq];
}

#pragma mark -获取房间信息
-(void)getRoomInfomation:(NSString *)roomJID{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"from" stringValue:KUserJID];
    [iq addAttributeWithName:@"id" stringValue:@"getRoomInfomation"];
    [iq addAttributeWithName:@"to" stringValue:roomJID];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#info"];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq];
    
    NSLog(@"\ngetRoomInfomation=%@\n",iq);
}

#pragma mark -getOnlyRoomID
-(void)getOnlyRoomID:(NSString *)roomDomain{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"from" stringValue:KUserJID];
    [iq addAttributeWithName:@"id" stringValue:@"getOnlyRoomID"];
    [iq addAttributeWithName:@"to" stringValue:roomDomain];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    NSXMLElement *unique=[NSXMLElement elementWithName:@"unique"];
    [unique addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#unique"];
    [iq addChild:unique];
    [[XMPPServer sharedServer] sendElement:iq];
    NSLog(@"********getOnlyRoomID=%@***********",iq);
}




#pragma mark -设置用户昵称
-(void)setUserNickName:(NSString *)nickName toUser:(NSString *)jid{
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
	[item addAttributeWithName:@"jid" stringValue:jid];
	[item addAttributeWithName:@"name" stringValue:nickName];
    [item addAttributeWithName:@"subscription" stringValue:@"both"];
	
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
	[query addChild:item];
	XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
	[iq addChild:query];
	
	[[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        NSLog(@"-----setUserNickName-----back--");
    }];
    NSLog(@"iq===%@",iq);
}


#pragma mark -删除好友
-(void)delUserName:(NSString *)jid{
    //    XMPPJID *j=[XMPPJID jidWithString:jid];
    //    [_xmppRoster removeUser:j];
    //
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
	[item addAttributeWithName:@"jid" stringValue:jid];
	[item addAttributeWithName:@"subscription" stringValue:@"remove"];
	
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
	[query addChild:item];
	
	XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
	[iq addChild:query];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    [[XMPPServer sharedServer]sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        NSLog(@"-----romoveFriend-----back--");
        
    }];
    
    NSLog(@"iq====%@",iq);
}

/*******************************************Now*****************************************************/

#pragma mark -获取设备信息
-(NSMutableDictionary *)getDeviceAttribute{
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",kClientType],@"clientType",[[CommonOperation getId]getVersion],@"version",[[CommonOperation getId]getScreenType],@"screenType", nil];
    return dic;
}
#pragma mark - completion
#pragma mark -createRoomCompletion
-(void)createRoomUser:(NSArray *)userJids Completion:(CreateRoomBlock)createRoomBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSString *name=[NSString stringWithFormat:@"%@、%@",[userJids objectAtIndex:0],[userJids objectAtIndex:1]];
    
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:KUserName,@"uuid",@"room/createRoom",@"m", name,@"roomName",nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        NSLog(@"---------createRomm----back");
        createRoomBlock(dictionary,finished);
    }];
    NSLog(@"\n requestUserinfomation===%@\n",iq);
}

#pragma mark -addRoomUser
-(void)addRoomUser:(NSArray *)userJids andRoomJid:(NSString *)roomJid completion:(CreateRoomJoinRoomBlock)joinRoomBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"room/addRoomUser",@"m",roomJid,@"roomJid", nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    [dic setValue:userJids forKey:@"uuids"];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        joinRoomBlock(dictionary,finished);
        NSLog(@"--------joinRomm----back");
    }];
    NSLog(@"addRoomUser====%@",iq);
}

#pragma mark -获取好友信息
-(void)getFriendInfomationWithIdentifer:(NSString *)identifier completion:(QueryFriendInfomationBlock)queryFriendInfomationBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:identifier,@"keyword",@"user/search",@"m", nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        queryFriendInfomationBlock(dictionary,finished);
        NSLog(@"------getFriendInfomationWithIdentifer--------back");
    }];
    NSLog(@"getFriendInfomationWithIdentifer====%@",iq);
}

#pragma mark -getUserJoinRoomsList
-(void)getUserJoinRoomsListWithUserName:(NSString *)userName completion:(QueryUserJoinRoomsListBlock)joinRoomsList{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:userName,@"uuid",@"room/getJoinRooms",@"m", nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        joinRoomsList(dictionary,finished);
        NSLog(@"------getUserJoinRoomsList--------back");
    }];
    NSLog(@"\n requestUserinfomation===%@\n",iq);
}

#pragma mark -getRoomUsersListWithRoomJid
-(void)getRoomUsersListWithRoomJid:(NSString *)roomJid completion:(QueryRoomUserlistBolock)userlistBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"room/getRoomUsers",@"m",roomJid,@"roomJid", nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        userlistBlock(dictionary,finished);
        NSLog(@"----------getRoomUserList-----back");
    }];
    NSLog(@"getRoomUserList====%@",iq);
}

#pragma mark -退出房间
-(void)exitRoomWithjid:(NSString *)jid completion:(ExitRoomBlock)exitRoomBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:jid,@"roomJid",@"room/quitRoom",@"m",KUserName,@"uuid",nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        exitRoomBlock(dictionary,finished);
        NSLog(@"------exitRoomWithjid--------back");
    }];
    NSLog(@"exitRoomWithjid====%@",iq);
}

#pragma mark -获取好友列表
-(void)getFriendsList:(NSString *)uuid completion:(operationBackBlock)backBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"user/rosterGetUsers",@"m",uuid,@"uuid",nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
          backBlock(dictionary,finished);
        NSLog(@"----------getFriendsList-----back");
    }];
    NSLog(@"getFriendsList====%@",iq);
}

#pragma mark -添加好友
-(void)addFriend:(NSString *)uuid completion:(operationBackBlock)backBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"user/rosterCreateUser",@"m",uuid,@"fuuid",KUserName,@"uuid",nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        backBlock(dictionary,finished);
        NSLog(@"----------addFriend-----back");
    }];
    NSLog(@"addFriend====%@",iq);
}

#pragma mark -删除好友
-(void)delFriend:(NSString *)uuid completion:(operationBackBlock)backBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"user/rosterDeleteUser",@"m",uuid,@"fuuid",KUserName,@"uuid",nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        backBlock(dictionary,finished);
        NSLog(@"----------delFriend-----back");
    }];
    NSLog(@"delFriend====%@",iq);
}


#pragma mark -设置用户昵称
-(void)setFriendNickName:(NSString *)nickName toFrienduuid:(NSString *)uuid completion:(operationBackBlock)backBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"user/rosterUpdateUser",@"m",KUserName,@"uuid",uuid,@"fuuid",nickName,@"nickName",nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        backBlock(dictionary,finished);
        NSLog(@"----------setFriendNickName-----back");
    }];
    NSLog(@"setFriendNickName====%@",iq);
}


#pragma mark -设置推送
-(void)setUserPushWithJid:(NSString *)jid type:(NSInteger )type isShield:(BOOL)b completion:(SetPushBlock)pushBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSString *isShield;
    if (b) {
        isShield=@"0";
    }else{
        isShield=@"1";
    }
    
    
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"push/setting",@"m",jid,@"jid",KUserName,@"uuid",isShield,@"isShield",[NSNumber numberWithInt:type],@"type",nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        //  pushBlock(dictionary,finished);
        NSLog(@"----------setUserPushWithJid-----back");
    }];
    NSLog(@"setUserPushWithJid====%@",iq);
}

#pragma mark -获取推送列表
-(void)getPushList:(NSString *)uuid completion:(operationBackBlock)backBlock{
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:[CommonOperation stringWithGUID]];
    NSXMLElement *query=[NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:chbapi"];
    NSXMLElement *method=[NSXMLElement elementWithName:@"method"];
    NSDictionary *custom=[NSDictionary dictionaryWithObjectsAndKeys:@"push/pushList",@"m",uuid,@"uuid",nil];
    NSMutableDictionary *dic=[self getDeviceAttribute];
    [dic setValuesForKeysWithDictionary:custom];
    method.stringValue=[dic JSONRepresentation];
    [query addChild:method];
    [iq addChild:query];
    [[XMPPServer sharedServer] sendElement:iq completed:^(NSDictionary *dictionary, BOOL finished) {
        backBlock(dictionary,finished);
        NSLog(@"----------getPushList-----back");
    }];
    NSLog(@"getPushList====%@",iq);
}

@end
