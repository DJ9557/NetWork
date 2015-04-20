//
//  NSObject+NetWork.h
//  test
//
//  Created by zhubch on 14-10-30.
//  Copyright (c) 2014年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  NSObject扩展,方便对象在网上络传输
 */
@interface NSObject (NetWork)

/**
 *  使用runtime特性将属性生成字典
 *
 *  @return 属性对应的字典
 */
- (NSDictionary*)dictionary;

/**
 *  直接把属性转成json
 *
 *  @return json字符串
 */
- (NSString*)json;

@end