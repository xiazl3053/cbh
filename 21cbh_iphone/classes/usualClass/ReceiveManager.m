//
//  ReceiveManager.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ReceiveManager.h"
#import "EMessages.h"
#import "ESessions.h"
#import "EMessagesDB.h"
#import "EFriends.h"
#import "EFriendsDB.h"
#import "ERoom.h"
#import "ERoomsDB.h"
#import "XMPPRoomManager.h"
#import "ERoomMemberModel.h"
#import "ERoomMemberDB.h"
#import "CommonOperation.h"
#import "NSXMLElement+XEP_0203.h"
#import "SessionInstance.h"

@interface ReceiveManager()
{
    XMPPRosterCoreDataStorage* xmppRosterStorage;
    XMPPRoster* xmppRoster;
}

@end

@implementation ReceiveManager

static ReceiveManager* singleton=nil;

+(ReceiveManager *)sharedManager{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [[self alloc] init];
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

-(void)setupRoster:(XMPPStream*)xmppStream deleagte:(id)delegate
{
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    [xmppRoster activate:xmppStream];
    [xmppRoster addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

-(void)releaseRoster
{
    [xmppRoster removeDelegate:self];
    [xmppRoster deactivate];
    
    xmppRoster = nil;
	xmppRosterStorage = nil;
}

#pragma mark - 接收Message包处理方法
-(void)receiveXmppMessage:(XMPPMessage *)message
{
    [self receiveXmppMessage:message completedBlock:nil];
}

#pragma mark - 接收Message包处理方法并且回调
-(void)receiveXmppMessage:(XMPPMessage *)message completedBlock:(XMPPCompletedBlock)completedBlock
{
    if([message isErrorMessage])
    {
        if(completedBlock)
        {
            completedBlock(nil,NO);
        }
    }
    else if ([message isMessageWithBody])
	{
        BOOL flag;
        XMPPJID *jid = [message from];
        
        EFriends *ef=[[EFriends alloc]init];
        ef.myJID=KUserJID;
        ef.jid=[jid bare];
        
        if ([message isChatMessage]) {
            if (![[EFriendsDB sharedEFriends]isExistFriends:ef]) {
                XMPPRoomManager *manager=[XMPPRoomManager instance];
                [manager getFriendInfomationWithIdentifer:ef.jid completion:^(NSDictionary *model, BOOL isSucess) {
                    if (isSucess) {
                        EFriends *friend=[model objectForKey:@"value"];
                           // friend.remark=friend.userName;
                            [[EFriendsDB sharedEFriends]insertWithFriend:friend];
                    }
                }];
            }
        }else{
            
        }
        
        // 聊天消息入库
        EMessages *msg = [self receiveMessgaeCreater:message isReceive:YES];
        
        // 插入数据库
        if(msg){
            [[EMessagesDB instanceWithFriendJID:[jid bare]] insertWithMessage:msg];
        }
    }
    else if([message hasReceiptResponse])
    {
        if(completedBlock)
        {
            completedBlock(nil,YES);
        }
    }
}

-(EMessages *)receiveMessgaeCreater:(XMPPMessage *)message isReceive:(BOOL)isReceive
{
    NSString* body = [message body];
    NSString* guid=[message attributeStringValueForName:@"id"];
    NSDictionary* dic=[body JSONValue];
    if ([dic isEqual:[NSNull null]]||dic==NULL||![[dic class] isSubclassOfClass:[NSDictionary class]]){
        return nil;
    }
    NSInteger type=[[dic objectForKey:@"messageType"] integerValue];
    EMessages* msg=[[EMessages alloc]init];
    msg.userName=[dic objectForKey:@"invite"];
    msg.content=[dic objectForKey:@"content"];
    msg.friends_jid=message.from.bare;
    msg.resource=message.from.resource;
    switch (type) {
        case 0://普通文字
            break;
        case 1://图片
        {
            NSString* picStr=[dic objectForKey:@"picUrls"];
            msg.picUrls=[picStr JSONValue];
        }
            break;
        case 2://语音
            break;
        case 3://股票
        {
            msg.KId=[dic objectForKey:@"KId"];
            msg.KType=[dic objectForKey:@"KType"];
            msg.KName=[dic objectForKey:@"KName"];
        }
            break;
        case 4://新闻资讯
        case 5://专题
        case 6://图集
        {
            msg.programId=[dic objectForKey:@"programId"];
            msg.articleId=[dic objectForKey:@"articleId"];
            msg.msgDesc=[dic objectForKey:@"description"];
            NSString* picUrl=[dic objectForKey:@"picUrl"];
            NSArray* array=[NSArray arrayWithObject:picUrl];
            msg.picUrls=[NSDictionary dictionaryWithObject:array forKey:DNewsLogoImg];
        }
            break;
        case 99://邀请群聊消息
        {
            msg.isSys=[[dic objectForKey:@"isSys"] intValue];
            NSArray* array=[dic objectForKey:@"data"];
            [self updateRoomMember:array roomJID:msg.friends_jid];
        }
            break;
        case 100://退出群聊消息
        {
            msg.isSys=[[dic objectForKey:@"isSys"] intValue];
        }
            break;
        default:
            break;
    }
    if(!guid){
        guid=[CommonOperation stringWithGUID];
    }
    msg.guid=guid;
    msg.myJID=KUserJID;
    msg.messageType = type;
    msg.isSelf = !isReceive;
    msg.isSend = 1;
    if([message.type isEqualToString:@"groupchat"])
    {
        msg.isGroup=YES;
    }
    if(message.wasDelayed)
    {
        msg.time=[message.delayedDeliveryDate timeIntervalSince1970];
    }
    else
    {
        msg.time = [[NSDate date] timeIntervalSince1970];
    }
    return msg;
}

#pragma mark - 接收Iq包处理方法
-(void)receiveXmppIQ:(XMPPIQ *)iq
{
    [self receiveXmppIQ:iq completedBlock:nil];
}

#pragma mark - 接收Iq包处理方法带回调方法
-(void)receiveXmppIQ:(XMPPIQ *)iq completedBlock:(XMPPCompletedBlock)completedBlock
{
    if ([@"result" isEqualToString:iq.type]) {
        NSXMLElement *query = iq.childElement;
        
        if ([@"query" isEqualToString:query.name]) {
            NSLog(@"query=%@",query);
            DDXMLNode *result=[query childAtIndex:0];
            //NSLog(@"rsult==%@",result.stringValue);
            if (![result.stringValue isEqualToString:@""]) {
                NSLog(@"-----custom.iq------");
                [self customIQDispose:result.stringValue completedBlock:completedBlock];
            }else{
                NSLog(@"-----system.iq------");
                NSArray *items = [query children];
                for (NSXMLElement *item in items) {
                    //订阅签署状态
                    NSString *subscription = [item attributeStringValueForName:@"subscription"];
                    // both状态为互为好友
                    if ([subscription isEqualToString:@"both"]) {
//                        NSString *jid = [item attributeStringValueForName:@"jid"];
//                        NSString *userName = [item attributeStringValueForName:@"name"];
//                        NSString *nickName = [item attributeStringValueForName:@"name"];
                        //[[jid componentsSeparatedByString:@"@"] firstObject];
                        
//                        EFriends *f = [[EFriends alloc] init];
//                        f.jid = jid;
//                        f.nickName = nickName;
//                        f.myJID = KUserJID;
//                        f.userName = userName;
//                        f.isFriend=YES;
//                        f.iconUrl=@"http://img0.bdstatic.com/img/image/shouye/mnka-12049944708.jpg";
//                        if ([[EFriendsDB sharedEFriends]isExistFriends:f]) {
//                            [[EFriendsDB sharedEFriends] updateWithFriend:f];
//                        }else{
//                            [[EFriendsDB sharedEFriends] insertWithFriend:f];
//                        }
                        
                        //群组：
                        //                        NSArray *groups = [item elementsForName:@"group"];
                        //                        for (NSXMLElement *groupElement in groups) {
                        //                            NSString *groupName = groupElement.stringValue;
                        //                            NSLog(@"didReceiveIQ----xmppJID:%@ , in group:%@",jid,groupName);
                        //                            // 朋友入库
                        //                            EFriends *f = [[EFriends alloc] init];
                        //                            f.jid = jid;
                        //                            f.nickName = nickName;
                        //                            f.myJID = [[sender myJID] bare];
                        //                            f.userName = userName;
                        //                            [[EFriendsDB sharedEFriends] insertWithFriend:f];
                        //                        }
                    }
                    else if ([subscription isEqualToString:@"from"]){
                        
                    }
                    else if ([subscription isEqualToString:@"to"]){
                        
                    }
                }
            }
        }
    }else if ([iq isSetIQ]){
//        //更改昵称
//        NSXMLElement *query = iq.childElement;
//        NSXMLElement *item =   [[query children]objectAtIndex:0];
//        NSString *jid = [item attributeStringValueForName:@"jid"];
//        NSString *name = [item attributeStringValueForName:@"name"];
//        NSString *subscription = [item attributeStringValueForName:@"subscription"];
//        NSLog(@"jid=%@,name=%@,subscription=%@",jid,name,subscription);
//        EFriends *friend=[[EFriends alloc]init];
//        friend.jid=jid;
//        friend.myJID=KUserJID;
//        friend.remark=name;
//        
//        [[SessionInstance instance]updateSessionWithFriend:friend];
        
        //    node
        //    NSXMLElement *groupElement = [item elementForName:@"group"];
        //    NSString *group = [groupElement attributeStringValueForName:@"group"];
        //    NSLog(@"didRecieveRosterItem:  jid=%@,name=%@,subscription=%@,group=%@",jid,name,subscription);
    
    }
}

#pragma mark - 接收Presence包处理方法
-(void)receiveXmppPresence:(XMPPPresence *)presence
{
    NSString *presenceType = [presence type]; //取得好友状态
    
    NSString *userId = KUserJID;//当前用户
    
    NSString *presenceFromUser = [[presence from] user];//在线用户
    NSLog(@"didReceivePresence---- presenceType:%@,用户:%@",presenceType,presenceFromUser);
//    NSLog(@"presence===%@",presence);
    
    if (![presenceFromUser isEqualToString:userId]) {
        //对收到的用户的在线状态的判断在线状态
        
        //在线用户
        if ([presenceType isEqualToString:@"available"]) {
            
        }
        
        //用户下线
        else if ([presenceType isEqualToString:@"unavailable"]) {
            
        }
        
        //这里再次加好友:如果请求的用户返回的是同意添加
        else if ([presenceType isEqualToString:@"subscribed"]) {
            NSLog(@"-------同意加你:%@-------",[[presence from] user]);
            
            EFriends *f = [[EFriends alloc] init];
            f.jid = [[presence from] bare];
            f.nickName = [[presence from] bare];
            f.myJID = KUserJID;
            f.userName = [[[[presence from] bare]componentsSeparatedByString:@"@"]firstObject];
            [[EFriendsDB sharedEFriends] insertWithFriend:f];
            
        }
        
        //用户拒绝添加好友
        else if ([presenceType isEqualToString:@"unsubscribed"]) {
            // 当用户拒绝添加为好友，订阅状态为unsubscribed
            // 用户点击拒绝按钮，会触发此事件
            // 删除分组里对应的朋友
            //[xmppRoster removeUser:[presence from]];
            NSLog(@"-------删除好友:%@-------",[[presence from] user]);
            
//            EFriends *f = [[EFriends alloc] init];
//            f.jid = [[presence from] bare];
//            f.nickName = [[presence from] bare];
//            f.myJID = [[sender myJID] bare];
//            f.userName =  [[[[presence from] bare]componentsSeparatedByString:@"@"]firstObject];
//            [[EFriendsDB sharedEFriends] deleteWithFriend:f];
        }
        
        else if ([presenceType isEqualToString:@"subscribe"]) {
            // 用户上线后收到历史添加好友请求
//            NSLog(@"%@-----请求添加好友",[[presence from] bare]);
//            XMPPRoomManager *manager=[XMPPRoomManager instance];
//            [manager acceptPresenceSubscriptionRequestFrom:[[presence from] bare] andAccept:YES];
//            
//            ESessions *session = [[ESessions alloc] init];
//            session.myJID = [[sender myJID] bare];
//            session.jid = [[presence from] bare];
//            session.time = [[NSDate date] timeIntervalSince1970];
//            session.isTop = NO;
//            session.isRead = NO;
//            if ([[ESessionsDB instance]isExistFriends:session]) {
//                [[ESessionsDB instance] updateWithSession:session];
//            }else{
//                [[ESessionsDB instance] insertWithSession:session];
//                
//                EMessages *msg=[[EMessages alloc]init];
//                msg.time = [[NSDate date] timeIntervalSince1970];
//                msg.messageType = 10;
//                msg.isRead = NO;
//                msg.content=[NSString stringWithFormat:@"加你为好友"];
//                msg.friends_jid=session.jid;
//                msg.myJID=[[sender myJID] bare];
//                [[EMessagesDB instanceWithFriendJID:[[presence from] bare]] insertWithMessage:msg];
//            }
        }else if ([presenceType isEqualToString:@"unsubscribe"]){
            NSLog(@"-------拒绝加好友:%@-------",[[presence from] user]);
        }
    }
}

#pragma mark -自定义IQ包返回处理
-(void)customIQDispose:(NSString *)json completedBlock:(XMPPCompletedBlock)block{
    NSDictionary *dic=[json JSONValue];
    NSString *api=[dic objectForKeyedSubscript:@"api"];
    if ([api isEqualToString:@"room/createRoom"]) {
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSString *roomID=[data objectForKey:@"roomJid"];
            //manager.createRoomBlock(roomID);
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            ERoom *model=[[ERoom alloc]initWithNSDictionary:data];
            [dic setValue:model forKey:@"value"];
            if (block) {
              block(dic,YES);
            }
            NSLog(@"----创建群成功,roomID====%@------",roomID);
        }else{
            NSLog(@"----创建群失败-------");
            if (block) {
                block(nil,NO);
            }
        }
    }else if ([api isEqualToString:@"room/addRoomUser"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSString *status=[data objectForKey:@"status"];
            //manager.JoinRoomBlock(status);
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:status forKey:@"value"];
            if (block) {
                block(dic,YES);
            }
            NSLog(@"----添加好友到群status====%@------",status);
        }else{
            NSLog(@"----添加好友到群失败--------");
            if (block) {
                block(nil,NO);
            }
        }
    }else if ([api isEqualToString:@"room/getJoinRooms"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSArray *list=[data objectForKey:@"list"];
            NSMutableArray *arr=[NSMutableArray array];
            for (NSDictionary *dic in list) {
                ERoom *model=[[ERoom alloc]initWithNSDictionary:dic];
                [arr addObject:model];
            }
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:arr forKey:@"value"];
            if (block) {
                block(dic,YES);
            }
        }else{
            if (block) {
                block(nil,NO);
            }
            }
    }else if ([api isEqualToString:@"user/search"]){
            if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
                NSDictionary *data=[dic objectForKey:@"data"];
                NSDictionary *user=[[data objectForKey:@"list"]objectAtIndex:0];
                EFriends *ef=[[EFriends alloc]initWithNSDictionary:user];
                //manager.queryFriendInfomationBlock(ef,0);
                NSMutableDictionary *back=[NSMutableDictionary dictionary];
                [back setValue:ef forKeyPath:@"value"];
                if (block) {
                    block(back,YES);
                }
            }else{
                NSMutableDictionary *back=[NSMutableDictionary dictionary];
                [back setValue:[dic objectForKey:@"msg"] forKeyPath:@"error"];
                if (block) {
                    block(back,NO);
                }
                    NSLog(@"---------无此好友-------");
            }
    }else if ([api isEqualToString:@"room/getRoomUsers"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSArray *list=[data objectForKey:@"list"];
            NSMutableArray *arr=[NSMutableArray array];
            for (NSDictionary *object in list) {
                ERoomMemberModel *model=[[ERoomMemberModel alloc]initWithNSDictionary:object];
                [arr addObject:model];
                if ([[ERoomMemberDB sharedInstance]isExistMember:model.member andRoomJid:model.roomJid]) {
                    [[ERoomMemberDB sharedInstance]updateWithFriend:model];
                }else{
                    [[ERoomMemberDB sharedInstance]insertWithMember:model];
                    NSLog(@"群用户jid=%@",model.member.jid);
                }
            }
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:arr forKeyPath:@"value"];
            if (block) {
                block(dic,YES);
            }
        }else{
            if (block) {
             block(nil,NO);
            }
        }
    }else if ([api isEqualToString:@"room/quitRoom"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSString *status=[data objectForKey:@"status"];
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:status forKeyPath:@"value"];
            if (block) {
                block(dic,YES);
            }
        }else{
            if (block) {
                block(nil,NO);
            }
        }
    }else if ([api isEqualToString:@"push/setting"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSString *status=[data objectForKey:@"status"];
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:status forKeyPath:@"value"];
            if (block) {
                block(dic,YES);
            }
        }else{
            if (block) {
                block(nil,NO);
            }
        }
    }else if ([api isEqual:@"user/rosterGetUsers"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSArray *list=[data objectForKey:@"list"];
            NSMutableArray *backData=[NSMutableArray array];
            for (NSDictionary *obj in list) {
               EFriends *ef=[[EFriends alloc]initWithNSDictionary:obj];
                [backData addObject:ef];
            }
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:backData forKeyPath:@"value"];
            if (block) {
                block(dic,YES);
            }
        }else{
            if (block) {
                block(nil,NO);
            }
        }
    }else if ([api isEqual:@"user/rosterUpdateUser"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSString *status=[data objectForKey:@"status"];
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:status forKeyPath:@"value"];
            if (block) {
                block(dic,YES);
            }
        }else{
            if (block) {
                block(nil,NO);
            }
        }
    }else if ([api isEqual:@"user/rosterCreateUser"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            EFriends *ef=[[EFriends alloc]initWithNSDictionary:data];
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:ef forKeyPath:@"value"];
            if (block) {
                block(dic,YES);
            }
        }else{
            if (block) {
                block(nil,NO);
            }
        }
    }else if ([api isEqual:@"user/rosterDeleteUser"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSString *status=[data objectForKey:@"status"];
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:status forKeyPath:@"value"];
            if (block) {
                block(dic,YES);
            }
        }else{
            if (block) {
                block(nil,NO);
            }
        }
    }else if([api isEqual:@"push/pushList"]){
        if ([[dic objectForKey:@"error"] isEqualToString:@"0"]) {
            NSDictionary *data=[dic objectForKey:@"data"];
            NSArray *list=[data objectForKey:@"list"];
            NSMutableArray *backData=[NSMutableArray array];
            for (NSDictionary *obj in list) {
                NSString *jid=[obj objectForKey:@"jid"];
                NSString *isShield=[obj objectForKey:@"isShield"];
                NSString *type=[obj objectForKeyedSubscript:@"type"];
                if ([type isEqual:@"0"]) {
                    //同步
                    EFriends *ef=[[EFriendsDB sharedEFriends]getFriendsWithJID:jid];
                    ef.isShield=[isShield intValue];
                    [[EFriendsDB sharedEFriends]updateWithFriend:ef];
                }else if ([type isEqual:@"1"]){
                    ERoom *room=[[ERoomsDB sharedInstance]getRoomWithJID:jid];
                    room.isShield=[isShield intValue];
                    [[ERoomsDB sharedInstance]updateWithRoom:room];
                }
                NSLog(@"jid=%@,isShield=%@,type=%@",jid,isShield,type);
            }
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setValue:backData forKeyPath:@"value"];
            if (block) {
                block(dic,YES);
            }
        }else{
            if (block) {
                block(nil,NO);
            }
        }
    }
}

-(void)updateRoomMember:(NSArray*)array roomJID:(NSString*)roomJID
{
    NSMutableArray* memberArray=[NSMutableArray array];
    for (NSDictionary* dic in array) {
        ERoomMemberModel* model=[[ERoomMemberModel alloc] initWithNSDictionary:dic andRoomJID:roomJID];
        [memberArray addObject:model];
    }
    if(memberArray.count>0)
    {
        [[ERoomMemberDB sharedInstance] insertWithMemberList:memberArray];
    }
}

@end
