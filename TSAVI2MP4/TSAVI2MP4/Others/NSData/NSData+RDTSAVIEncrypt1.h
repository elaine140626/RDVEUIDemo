//
//  NSData+Encrypt.h
//  iOS-Categories (https://github.com/shaojiankui/iOS-Categories)
//
//  Created by Jakey on 14/12/15.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (RDTSAVIEncrypt)

/**
 *  利用AES加密数据
 *
 *  @param key key
 *  @param iv  iv description
 *
 *  @return data
 */
- (NSData *)rdTSAVI_encryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv;
/**
 *  @brief  利用AES解密据
 *
 *  @param key key
 *  @param iv  iv
 *
 *  @return 解密后数据
 */
- (NSData *)rdTSAVI_decryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv;

/**
 *  利用3DES加密数据
 *
 *  @param key key
 *  @param iv  iv description
 *
 *  @return data
 */
- (NSData *)rdTSAVI_encryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;
/**
 *  @brief   利用3DES解密数据
 *
 *  @param key key
 *  @param iv  iv
 *
 *  @return 解密后数据
 */
- (NSData *)rdTSAVI_decryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;

/**
 *  @brief  NSData 转成UTF8 字符串
 *
 *  @return 转成UTF8 字符串
 */
- (NSString *)rdTSAVI_UTF8String;


@end