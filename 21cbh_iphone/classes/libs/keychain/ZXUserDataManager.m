//
//  ZXUserDataManager.m
//  keychain的使用
//
//  Created by 周晓 on 14-6-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ZXUserDataManager.h"
#import "ZXKeyChain.h"

@implementation ZXUserDataManager

static NSString * const KEY_IN_KEYCHAIN = @"com.cbh21.shijiwang21";
static NSString * const KEY_PASSWORD = @"com.cbh21.shijiwang21.identifierNumber";

+(void)saveIdentifierNumber:(NSString *)identifierNumber
{
    NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
    [usernamepasswordKVPairs setObject:identifierNumber forKey:KEY_PASSWORD];
    [ZXKeyChain save:KEY_IN_KEYCHAIN data:usernamepasswordKVPairs];
}

+(id)readIdentifierNumber
{
    NSMutableDictionary *usernamepasswordKVPair = (NSMutableDictionary *)[ZXKeyChain load:KEY_IN_KEYCHAIN];
    return [usernamepasswordKVPair objectForKey:KEY_PASSWORD];
}

+(void)deleteIdentifierNumber
{
    [ZXKeyChain delete:KEY_IN_KEYCHAIN];
}

@end
