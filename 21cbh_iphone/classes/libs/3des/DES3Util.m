//
//  DES3Util.m
//  lx100-gz
//
//  Created by  ¡¯∑Â on 12-9-17.
//  Copyright 2012 http://blog.csdn.net/lyq8479. All rights reserved.
//


#import "DES3Util.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"


#define gkey            KSkey  //与服务端的skey一致
#define gIv             @"01234567"


@implementation DES3Util


// º”√‹∑Ω∑®
+ (NSString*)encrypt:(NSString*)plainText {
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t plainTextBufferSize = [data length];
    
    const void *vplainText = (const void *)[data bytes];
    
    
    
    CCCryptorStatus ccStatus;
    
    uint8_t *bufferPtr = NULL;
    
    size_t bufferPtrSize = 0;
    
    size_t movedBytes = 0;
    
    
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    
    
    const void *vkey = (const void *) [gkey UTF8String];
    
    const void *vinitVec = (const void *) [gIv UTF8String];
    
    
    
    ccStatus = CCCrypt(kCCEncrypt,
                       
                       kCCAlgorithm3DES,
                       
                       kCCOptionPKCS7Padding,
                       
                       vkey,
                       
                       kCCKeySize3DES,
                       
                       vinitVec,
                       
                       vplainText,
                       
                       plainTextBufferSize,
                       
                       (void *)bufferPtr,
                       
                       bufferPtrSize,
                       
                       &movedBytes);
    
    
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    
    NSString *result = [GTMBase64 stringByEncodingData:myData];
    //NSString *result = [CommonFunc base64StringFromText:[[NSString alloc] initWithData:myData encoding:NSASCIIStringEncoding]];
    return result;
}


// Ω‚√‹∑Ω∑®
+ (NSString*)decrypt:(NSString*)encryptText {
    
    NSData *encryptData = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    //NSData *encryptData = [CommonFunc textFromBase64String:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    size_t plainTextBufferSize = [encryptData length];
    
    const void *vplainText = [encryptData bytes];
    
    
    
    CCCryptorStatus ccStatus;
    
    uint8_t *bufferPtr = NULL;
    
    size_t bufferPtrSize = 0;
    
    size_t movedBytes = 0;
    
    
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    
    
    const void *vkey = (const void *) [gkey UTF8String];
    
    const void *vinitVec = (const void *) [gIv UTF8String];
    
    
    
    ccStatus = CCCrypt(kCCDecrypt,
                       
                       kCCAlgorithm3DES,
                       
                       kCCOptionPKCS7Padding,
                       
                       vkey,
                       
                       kCCKeySize3DES,
                       
                       vinitVec,
                       
                       vplainText,
                       
                       plainTextBufferSize,
                       
                       (void *)bufferPtr,
                       
                       bufferPtrSize,
                       
                       &movedBytes);
    
    
    
    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                       
                                                                     length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding] ;
    
    return result;
}


@end