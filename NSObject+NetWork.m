//
//  NSObject+NetWork.m
//  test
//
//  Created by zhubch on 14-10-30.
//  Copyright (c) 2014年 zhubch. All rights reserved.
//

#import "NSObject+NetWork.h"
#import <objc/runtime.h>

@implementation NSObject (NetWork)

-(NSDictionary *)dictionary
{
    
    Class clazz = [self class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL s = NSSelectorFromString([NSString stringWithUTF8String:propertyName]);
        id value;
        if ([self respondsToSelector:s]) {
            value = [self performSelector:s];
        }
        
        if(value ==nil){
            [valueArray addObject:[NSNull null]];
        } else {
            [valueArray addObject:value];
        }
        
    }
    
    free(properties);
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    
    return dic;
}

- (NSString *)json
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self dictionary] options:0 error:nil];
    __autoreleasing NSString *json = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json;
}

@end
