//
//  CWPConstant.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

typedef NS_ENUM(NSUInteger, XMPPStreamConnectState) {
    XMPPStreamStateConnecting,
    XMPPStreamStateConnected,
    XMPPStreamStateDisConnect,
};

//线上正式openFire主机名和端口号

//线上测试openFire主机名和端口号
#define KXMPPHost @"183.60.127.14"//主机名
#define KXMPPPort 61205 //端口号

//线下测试openFire主机名和端口号
//#define KXMPPHost @"192.168.16.233"//主机名
//#define KXMPPPort 5222 //端口号


#define KXMPPDomain @"im.21cbh.com"//域名
#define KXMPPResource @"21APP"
#define kXMPPNewMsgNotifaction @"NewMsgNotifaction"
#define kXMPPFriendsNotifaction @"FriendsNotifaction"
#define kXMPPMsgStatusNotifaction @"MsgStatusNotifaction"
#define kXMPPFriendsChangeNotifaction @"FriendsChangeNotifaction"
#define kXMPPStreamConnectStateChangeNotiction @"kXMPPStreamConnectStateChangeNotiction"
#define kXMPPSessionChangeNotifaction @"SessionChangeNotifaction"