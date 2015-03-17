//
//  XMPPServer.m
//  21cbh_iphone
//
//  Created by 21tech on 14-6-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XMPPServer.h"
#import "XMPPPresence.h"
#import "XMPPJID.h"
#import <AVFoundation/AVFoundation.h>
#import "XMPPFramework.h"
#import "DCommon.h"
#import "CommonOperation.h"
#import "ReceiveManager.h"
#import "XMPPMessageDeliveryReceipts.h"
#import "XMPPRoomManager.h"
#import "ERoom.h"
#import "ERoomsDB.h"
#import "ERoomMemberDB.h"
#import "ERoomMemberModel.h"
#import "EFriends.h"
#import "EFriendsDB.h"
#import "EFriendsAndRoomsOpration.h"
#import "SessionInstance.h"

static XMPPServer *singleton = nil;
static NSString *const xCompletedCallbackKey = @"completed";
static NSString *const xTimeOutSource=@"timeout";

@interface XMPPServer()<UIAlertViewDelegate>
{
    XMPPMessageDeliveryReceipts* xmppReceipts;
    
    NSInteger _connnectInterval;//连接时间间隔
}
@property (strong,nonatomic) NSOperationQueue *xmppQueue;
@property (strong,nonatomic) NSMutableDictionary* xmppCallBacks;
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t barrierQueue;

@end

@implementation XMPPServer

#pragma mark - singleton
+(XMPPServer *)sharedServer{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [[self alloc] init];
            //注册通知
            [singleton registerNotification];
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
    if(self=[super init]){
        _xmppQueue=[NSOperationQueue new];
        _xmppQueue.maxConcurrentOperationCount=2;
        _xmppCallBacks=[NSMutableDictionary new];
        _barrierQueue=dispatch_queue_create("com.21cbh.XMPPServerBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _xmppTimeout=15.0;
        _connnectInterval=5;
    }
    return self;
}

-(void)dealloc{
    //移除通知
    [self removeNotification];
    [self teardownStream];
    [self.xmppQueue cancelAllOperations];
    SDDispatchQueueRelease(_barrierQueue);
}


#pragma mark - private
-(void)setupStream{
    if (!xmppStream) {
        // NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
        
        // Setup xmpp stream
        //
        // The XMPPStream is the base class for all activity.
        // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
        
        xmppStream = [[XMPPStream alloc] init];
        
#if !TARGET_IPHONE_SIMULATOR
        {
            // Want xmpp to run in the background?
            //
            // P.S. - The simulator doesn't support backgrounding yet.
            //        When you try to set the associated property on the simulator, it simply fails.
            //        And when you background an app on the simulator,
            //        it just queues network traffic til the app is foregrounded again.
            //        We are patiently waiting for a fix from Apple.
            //        If you do enableBackgroundingOnSocket on the simulator,
            //        you will simply see an error message from the xmpp stack when it fails to set the property.
            
            xmppStream.enableBackgroundingOnSocket = YES;
        }
#endif
        
        // Setup reconnect
        //
        // The XMPPReconnect module monitors for "accidental disconnections" and
        // automatically reconnects the stream for you.
        // There's a bunch more information in the XMPPReconnect header file.
        
        //        xmppReconnect = [[XMPPReconnect alloc] init];
        
        [[ReceiveManager sharedManager] setupRoster:xmppStream deleagte:self];
        
        xmppReceipts=[[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        xmppReceipts.autoSendMessageDeliveryReceipts = YES;
        xmppReceipts.autoSendMessageDeliveryRequests = YES;
        [xmppReceipts activate:xmppStream];
        
        // Setup vCard support
        //
        // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
        // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
        
        // Setup capabilities
        //
        // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
        // Basically, when other clients broadcast their presence on the network
        // they include information about what capabilities their client supports (audio, video, file transfer, etc).
        // But as you can imagine, this list starts to get pretty big.
        // This is where the hashing stuff comes into play.
        // Most people running the same version of the same client are going to have the same list of capabilities.
        // So the protocol defines a standardized way to hash the list of capabilities.
        // Clients then broadcast the tiny hash instead of the big list.
        // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
        // and also persistently storing the hashes so lookups aren't needed in the future.
        //
        // Similarly to the roster, the storage of the module is abstracted.
        // You are strongly encouraged to persist caps information across sessions.
        //
        // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
        // It can also be shared amongst multiple streams to further reduce hash lookups.
        
        // Activate xmpp modules
        
        // Add ourself as a delegate to anything we may be interested in
        
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //[xmppCapabilities addDelegate:self delegateQueue:dispatch_get_main_queue()];
        // Optional:
        //
        // Replace me with the proper domain and port.
        // The example below is setup for a typical google talk account.
        //
        // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
        // For example, if you supply a JID like 'user@quack.com/rsrc'
        // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
        //
        // If you don't specify a hostPort, then the default (5222) will be used.
        
    	//[xmppStream setHostName:@"talk.google.com"];
        //        [xmppStream setHostName:@"192.168.16.18"];
        //    	[xmppStream setHostPort:5222];
    }
}

- (void)teardownStream
{
    [xmppReceipts deactivate];
	[xmppStream removeDelegate:self];
    
	[[ReceiveManager sharedManager] releaseRoster];
	[xmppStream disconnect];
	
	xmppStream = nil;
}

-(void)getOnline{
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
}


-(void)getOffline{
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [xmppStream sendElement:presence];
}

-(BOOL)connect{
    [self setupStream];
    //从本地取得用户名，密码和服务器地址
    NSString *uuid=[UserModel um].uuid;
    NSString *phoneNum=[UserModel um].phoneNum;
    password =[[CommonOperation getId] getToken];
    
    if (!uuid||!password||phoneNum.length<11) {//没有uuid.没有tonken或没有手机号,均不进行openFire连接
        return NO;
    }
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    //设置用户：user1@dashixiong.cn/appname 格式的用户名
    XMPPJID *jid = [XMPPJID jidWithUser:uuid domain:KXMPPDomain resource:KXMPPResource];
    [xmppStream setMyJID:jid];
    //设置服务器
    [xmppStream setHostName:KXMPPHost];
    //    [xmppStream setHostName:@"192.168.16.18"];
    [xmppStream setHostPort:KXMPPPort];
    //连接服务器
    NSError *error = nil;
    
    
    if (![xmppStream connectWithTimeout:10 error:&error]) {//新版本的xmpp
        NSLog(@"cant connect %@", KXMPPHost);
        
        return NO;
    }

    return YES;
}

//断开服务器连接
-(void)disconnect{
    
    [self getOffline];
    [xmppStream disconnect];
}

#pragma mark 重新连接
-(void)connnectAgain{
    //重新连接
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (![[CommonOperation getId] getNetStatus]){
            return;
        }
        
        sleep(_connnectInterval);
        [self connect];
        
    });
}



-(XMPPJID *)myJID
{
    return xmppStream.myJID;
}



#pragma mark 相应的网络状态处理
-(void)netStatusHandle{
    
    if (![[CommonOperation getId] getNetStatus]) {
         NSLog(@"网络异常,openFire已经断开连接.......");
        [self disconnect];
        
    }else{
        NSLog(@"网络恢复正常,openFire重新连接.......");
        [self connect];
    }
}


#pragma mark 注册通知
-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(disconnect) name:kNotifcationKeyForLogout object:nil];//注销通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connnectAgain) name:kNotifcationKeyForLogin object:nil];//登陆通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStatusHandle) name:kReachabilityChangedNotification object:nil]; //网络状态处理
}

#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForLogout object:nil];//注销通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForLogin object:nil];//登陆通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];//网络监听通知
}



#pragma mark - XMPPStream delegate
#pragma mark 连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    _isOpen = YES;
    NSError *error = nil;
    //验证密码
    [xmppStream authenticateWithPassword:password error:&error];
    NSLog(@"openFire连接成功!");
    [self sendXMPPStreamStateChangeNotication:XMPPStreamStateConnected];
    _connnectInterval=5;
}

#pragma mark 连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    _isOpen=NO;
    NSLog(@"openFire连接超时!");
    _connnectInterval=_connnectInterval*2;
}


- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    NSLog(@"openFire断开连接");
    _isOpen=NO;
    if (_isAuthorized) {//是通过验证的才重新连接
        NSLog(@"openFire重新连接.....重新连接的时间为%i秒",_connnectInterval);
        [self connnectAgain];
    }
    [self sendXMPPStreamStateChangeNotication:XMPPStreamStateDisConnect];
   
    _connnectInterval=_connnectInterval*2;
}

#pragma mark 验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    _isAuthorized=YES;
    //上线
    [self getOnline];
    NSLog(@"openFire验证通过!");
    [self getFriendsList];
    [self getPushList];
    [self joinRoomList];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    _isAuthorized=NO;
    NSLog(@"openFire验证错误:%@",error);
    //断开连接
    [self disconnect];
    //如果是手动登陆就去重新去登陆
    if (self.isManual) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示信息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆提示" message:@"帐号身份已过期，请重新登陆" delegate:self cancelButtonTitle:@"重新登录" otherButtonTitles:@"此设备下线", nil];
            alert.tag=1000;
            [alert show];
        });
    }
    
}

#pragma mark 收到服务器的错误信息提醒
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error{
    NSLog(@"error:%@",error);
    DDXMLNode *conflict=[error childAtIndex:0];
    if ([@"conflict" isEqual:conflict.name]) {
        NSLog(@"相同的账号登录冲突");
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示信息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"帐号多处登陆提示" message:@"您的帐号已在其他设备登陆，您被迫下线，请重新登陆" delegate:self cancelButtonTitle:@"重新登录" otherButtonTitles:@"此设备下线", nil];
            alert.tag=1000;
            [alert show];
        });
    }
}



/**
 * These methods are called after their respective XML elements are received on the stream.
 *
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then xmpp stream will automatically send an error response.
 *
 * Concerning thread-safety, delegates shouldn't modify the given elements.
 * As documented in NSXML / KissXML, elements are read-access thread-safe, but write-access thread-unsafe.
 * If you have need to modify an element for any reason,
 * you should copy the element first, and then modify and use the copy.
 *
 */

/*
 
 名册
 
 <iq xmlns="jabber:client" type="result" to="user2@chtekimacbook-pro.local/80f94d95">
 <query xmlns="jabber:iq:roster">
 <item jid="user6" name="" ask="subscribe" subscription="from"/>
 <item jid="user3@chtekimacbook-pro.local" name="bb" subscription="both">
 <group>好友</group><group>user2的群组1</group>
 </item>
 <item jid="user7" name="" ask="subscribe" subscription="from"/>
 <item jid="user7@chtekimacbook-pro.local" name="" subscription="both">
 <group>好友</group><group>user2的群组1</group>
 </item>
 <item jid="user1" name="" ask="subscribe" subscription="from"/>
 </query>
 </iq>
 */

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    NSLog(@"didReceiveIQ--iq is:%@",iq.XMLString);
    [self completeCallBack:iq];
    return YES;
}

/*
 收到消息
 
 <message
 to='romeo@example.net'
 from='juliet@example.com/balcony'
 type='chat'
 xml:lang='en'>
 <body>Wherefore art thou, Romeo?</body>
 <messageType></messageType>
 </message>
 
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"----message----%@",message.XMLString);
    [self completeCallBack:message];
}

/*
 
 收到好友状态
 <presence xmlns="jabber:client"
 from="user3@chtekimacbook-pro.local/ch&#x7684;MacBook Pro"
 to="user2@chtekimacbook-pro.local/7b55e6b">
 <priority>0</priority>
 <c xmlns="http://jabber.org/protocol/caps" node="http://www.apple.com/ichat/caps" ver="900" ext="ice recauth rdserver maudio audio rdclient mvideo auxvideo rdmuxing avcap avavail video"/>
 <x xmlns="http://jabber.org/protocol/tune"/>
 <x xmlns="vcard-temp:x:update">
 <photo>E10C520E5AE956E659A0DBC5C7F48E12DF9BE6EB</photo>
 </x>
 </presence>
 */
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSLog(@"didReceivePresence----%@",presence.XMLString);
    [[ReceiveManager sharedManager] receiveXmppPresence:presence];
    
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{

}

#pragma mark - XMPPRoster delegate
/**
 * Sent when a presence subscription request is received.
 * That is, another user has added you to their roster,
 * and is requesting permission to receive presence broadcasts that you send.
 *
 * The entire presence packet is provided for proper extensibility.
 * You can use [presence from] to get the JID of the user who sent the request.
 *
 * The methods acceptPresenceSubscriptionRequestFrom: and rejectPresenceSubscriptionRequestFrom: can
 * be used to respond to the request.
 *
 *  好友添加请求
 */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    //好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    
    NSLog(@"didReceivePresenceSubscriptionRequest----presenceType:%@,用户：%@,presence:%@",presenceType,presenceFromUser,presence);
    
    
    
    //    [_XMPPQueue addOperationWithBlock:^{
    //        XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
    //        [[XMPPServer xmppRoster]  acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    //    }];
    
    
    /*
     user1向登录账号user2请求加为好友：
     
     presenceType:subscribe
     presence2:<presence xmlns="jabber:client" to="user2@chtekimacbook-pro.local" type="subscribe" from="user1@chtekimacbook-pro.local"/>
     sender2:<XMPPRoster: 0x7c41450>
     
     登录账号user2发起user1好友请求，user5
     presenceType:subscribe
     presence2:<presence xmlns="jabber:client" type="subscribe" to="user2@chtekimacbook-pro.local" from="user1@chtekimacbook-pro.local"/>
     sender2:<XMPPRoster: 0x14ad2fb0>
     */
}

/**
 * Sent when a Roster Push is received as specified in Section 2.1.6 of RFC 6121.
 *
 * 添加好友、好友确认、删除好友
 
 用户收到添加好友请求
 test用户向mm用户请求添加好友
 <iq xmlns="jabber:client" type="set" id="671-1804" to="mm@dashixiong.cn/jianghu"><query xmlns="jabber:iq:roster"><item jid="test@dashixiong.cn" subscription="from"/></query></iq>
 
 //用户6确认后：
 <iq xmlns="jabber:client" type="set" id="880-334" to="user2@chtekimacbook-pro.local/662d302c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="subscribe" subscription="none"/></query></iq>
 
 //删除用户6：？？？
 <iq xmlns="jabber:client" type="set" id="592-372" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="from"/></query></iq>
 
 <iq xmlns="jabber:client" type="set" id="954-374" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="none"/></query></iq>
 
 <iq xmlns="jabber:client" type="set" id="965-376" to="user2@chtekimacbook-pro.local/e799ef0c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" subscription="remove"/></query></iq>
 */
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    
    // 在线收到添加好友请求处理
    NSLog(@"didReceiveRosterPush:(XMPPIQ *)iq is :%@",iq.XMLString);
}

/**
 * Sent when the initial roster is received.
 *
 */
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    NSLog(@"xmppRosterDidBeginPopulating");
}

/**
 * Sent when the initial roster has been populated into storage.
 *
 */
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"xmppRosterDidEndPopulating");
}

/**
 * Sent when the roster recieves a roster item.
 *
 * Example:
 *
 * <item jid='romeo@example.net' name='Romeo' subscription='both'>
 *   <group>Friends</group>
 * </item>
 *
 */


-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{

}

-(void)sendElement:(NSXMLElement *)element
{
    [xmppStream sendElement:element];
}

-(void)sendElement:(NSXMLElement *)element completed:(XMPPCompletedBlock)completedBlock
{
    NSString* guid=[element attributeStringValueForName:@"id"];
    __weak XMPPServer *wself=self;
    
    [self addCompletedBlock:guid andCompletedBlock:completedBlock createCallback:^{
        [wself sendElement:element];
    }];
}

-(void)sendElement:(NSXMLElement *)element andGetReceipt:(XMPPElementReceipt **)receiptPtr
{   NSLog(@"send=%@",element);
    [xmppStream sendElement:element andGetReceipt:receiptPtr];
}

-(void)sendElement:(NSXMLElement *)element andGetReceipt:(XMPPElementReceipt **)receiptPtr completed:(XMPPCompletedBlock)completedBlock
{
    NSString* guid=[element attributeStringValueForName:@"id"];
    __weak XMPPServer *wself=self;
    
    [self addCompletedBlock:guid andCompletedBlock:completedBlock createCallback:^{
        [wself sendElement:element andGetReceipt:receiptPtr];
    }];
}

-(dispatch_source_t)createDispatchTimer:(dispatch_block_t)block
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, self.barrierQueue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, _xmppTimeout*NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0.1);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer); 
    } 
    return timer; 
}

#pragma 添加回调Block
-(void)addCompletedBlock:(NSString*)guid andCompletedBlock:(XMPPCompletedBlock)completedBlock createCallback:(void (^)())createCallback
{
    if(guid==nil){
        if(completedBlock!=nil){
            completedBlock(nil,NO);
        }
        return;
    }
    dispatch_barrier_sync(self.barrierQueue, ^{
        BOOL first=NO;
        if(!self.xmppCallBacks[guid]){
            self.xmppCallBacks[guid]=[NSMutableArray new];
            first=YES;
        }
        
        NSMutableArray* callbacksForGuid=self.xmppCallBacks[guid];
        NSMutableDictionary *callbacks = [NSMutableDictionary new];
        if (completedBlock)
        {
            callbacks[xCompletedCallbackKey] = [completedBlock copy];
        }
        dispatch_source_t timer=[self createDispatchTimer:^{
            [self removeCallbacksForGuid:guid isTimeOut:YES];
        }];
        callbacks[xTimeOutSource]=timer;
        [callbacksForGuid addObject:callbacks];
        self.xmppCallBacks[guid] = callbacksForGuid;
        
        if(first){
            createCallback();
        }
    });
}

#pragma 查找是否带有当前GUID对应的Block，有则回调
-(void)completeCallBack:(NSXMLElement*)element
{
    __block XMPPCompletedBlock completed=nil;
    __block NSString* guid=nil;
    
    void (^block)(void)=^
    {
        NSArray* callbackForGuid=self.xmppCallBacks[guid];
        if(callbackForGuid)
        {
            [self removeCallbacksForGuid:guid isTimeOut:NO];
            for(NSDictionary* callback in callbackForGuid)
            {
                completed=callback[xCompletedCallbackKey];
            }
        }
    };
    
    ReceiveManager* manager=[ReceiveManager sharedManager];
    NSString* elementName=element.name;
    
    if ([elementName isEqualToString:@"iq"])
    {
        guid=[element attributeStringValueForName:@"id"];
        if(guid)
        {
            block();
            [manager receiveXmppIQ:[XMPPIQ iqFromElement:element] completedBlock:completed];
        }
    }
    else if ([elementName isEqualToString:@"message"])
    {
        XMPPMessage* message=[XMPPMessage messageFromElement:element];
        if([message hasReceiptResponse])
        {
            guid=[message receiptResponseID];
        }
        else
        {
            guid=[element attributeStringValueForName:@"id"];
        }
        if(guid&&![guid isEqualToString:@"local-only"])
        {
            block();
        }
        [manager receiveXmppMessage:message completedBlock:completed];
    }
    else if ([elementName isEqualToString:@"presence"])
    {
        
    }
}

-(void)sendXMPPStreamStateChangeNotication:(NSInteger )state{
   
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:state],@"state", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPStreamConnectStateChangeNotiction object:nil userInfo:dic];
}


#pragma mark -获取好友列表
-(void)getFriendsList{
    XMPPRoomManager *manager=[XMPPRoomManager instance];
    [manager getFriendsList:KUserName completion:^(NSDictionary *data, BOOL isSucess) {
        if (isSucess) {
            NSArray *arr=[data objectForKey:@"value"];
            for (EFriends *obj in arr) {
                obj.isFriend=YES;
                if ([[EFriendsDB sharedEFriends]isExistFriends:obj]) {
                    [[EFriendsDB sharedEFriends]updateWithFriend:obj];
                }else{
                    [[EFriendsDB sharedEFriends]insertWithFriend:obj];
                }
                NSLog(@"好友List:userName=%@,nickName=%@",obj.userName, obj.nickName);
            }
        }
    }];
}

#pragma mark -获取房间列表
-(void)joinRoomList{
    XMPPRoomManager *manager=[XMPPRoomManager instance];
    XMPPRoomManager __weak *_manager=manager;
    [_manager getUserJoinRoomsListWithUserName:KUserName completion:^(NSDictionary *model, BOOL isSucess) {
        if (isSucess) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"[NSThread currentThread]==%@",[NSThread currentThread]);
                //房间列表
                NSArray *arr=[model objectForKey:@"value"];
                for (ERoom *object in arr) {
                    [[ERoomsDB sharedInstance]insertWithRoom:object];
                    [_manager joinRoomJid:object.jid];
                    NSLog(@"用户加入的群名:%@,群ID:%@,群描述:%@",object.name,object.jid,object.desc);
                }
            });
            
        }
    }];
}

#pragma mark -获取推送列表
-(void)getPushList{
    [[XMPPRoomManager instance]getPushList:KUserName completion:^(NSDictionary *data, BOOL isSucess) {
        NSLog(@"-------getPushList------back-----");
    }];
}

- (NSArray *)callbacksForGuid:(NSString *)guid
{
    __block NSArray *callbackForGuid;
    dispatch_sync(self.barrierQueue, ^{
        callbackForGuid = self.xmppCallBacks[guid];
    });
    return [callbackForGuid copy];
}
#pragma 移除GUID的Block和计时器
- (void)removeCallbacksForGuid:(NSString *)guid isTimeOut:(BOOL)isTimeOut
{
    dispatch_barrier_async(self.barrierQueue, ^{
        NSArray* callbackForGuid = self.xmppCallBacks[guid];
        for(NSDictionary* callback in callbackForGuid)
        {
            dispatch_source_t timer=callback[xTimeOutSource];
            if(timer){
                dispatch_source_cancel(timer);
            }
            SDDispatchQueueRelease(timer);
            if(isTimeOut)
            {
                XMPPCompletedBlock completed=callback[xCompletedCallbackKey];
                if(completed)
                {
                    NSMutableDictionary* dic=[NSMutableDictionary new];
                    [dic setObject:@"TimeOut" forKey:@"error"];
                    completed(dic,NO);
                }
            }
        }
        [self.xmppCallBacks removeObjectForKey:guid];
    });
}

#pragma mark - --------------------UIAlertView的代理方法----------------------
#pragma mark 账号多处登陆提示按钮
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1000) {
        switch (buttonIndex) {
            case 0:
                [CommonOperation goTOLogin];//重新登陆
                break;
            case 1:
                [[CommonOperation getId] loginout];//注销
                break;
            default:
                break;
        }
    }
}
@end