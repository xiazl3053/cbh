//
//  NSString+Code.h
//   
//
//  Created by gzty1 on 12-3-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSString (Code)
- (NSString*)md5;
- (NSString *)doCipher:(NSString *)key operation:(CCOperation)encryptOrDecrypt;
- (NSString*)tripleDESWithKey:(NSString*)key;
- (NSString*)tripleDESWithKey:(NSString*)key compress:(BOOL)compress;
- (NSString*)decodeTripleDESWithKey:(NSString*)key;
- (NSData*)gzip;
- (NSString*)urlEncode;
- (NSString*)urlDecode;
-(int)characterCount;
-(BOOL)isEqualToStringCaseInsensitive:(NSString *)aString;
//把键值数组字符串解析到字典中，形如a=1&b=2&c=3的字符串
- (NSDictionary *)parametersWithSeparator:(NSString *)separator delimiter:(NSString *)delimiter;
@end
