//
//  HttpRequest.h
//  test
//
//  Created by zhubch on 14-10-29.
//  Copyright (c) 2014年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kServerUrl @"http://192.168.1.58:8080/%@"
//

@protocol RequestDelegate;

typedef enum : NSUInteger {
    Timeout,//网络超时
    WrongRequest,//请求错误
    Other,//其他错误
} ErrorCode;

/**
 *  请求完成的回调block
 *
 *  @param response 响应的data
 */
typedef void(^CompletedCallBack)(NSData *response);

/**
 *  请求失败的回调block
 *
 *  @param errorCode 错误码
 */
typedef void(^FailedCallBack)(ErrorCode code);


@interface HttpRequest : NSObject

@property (strong,nonatomic) NSString *url;

/**
 *  Json请求体
 */
@property (strong,nonatomic) NSString *jsonBody;

@property (copy,nonatomic) CompletedCallBack completedCallBack;

@property (copy,nonatomic) FailedCallBack failedCallBack;

@property (weak,nonatomic) id<RequestDelegate> delegate;

/**
 *  是否正在请求
 */
@property (assign,nonatomic,readonly) BOOL isLoading;

/**
 *  实例化对象
 *
 *  @param url      完整的URL
 *  @param method   请求方式。默认GET请求
 *  @param useCache 是否优先使用缓存
 *
 *  @return 
 */
- (id)initWithUrl:(NSString*)url Method:(NSString*)method UseCache:(BOOL) useCache;

- (void)start;

/**
 *  发起一个get请求
 *
 *  @param url      URL
 *  @param useCache 是否优先使用缓存
 *  @param callBack 请求完成后调用的block
 */
+ (void)getWithUrl:(NSString*)url UseCache:(BOOL)useCache CallBack:(CompletedCallBack)callBack;

/**
 *  发起一个post请求
 *
 *  @param url      URL
 *  @param body     请求体，Json字符串
 *  @param callBack 请求完成后调用的block
 */
+ (void)postWithUrl:(NSString*)url Body:(NSString*)body CallBack:(CompletedCallBack)callBack;

@end

/**
 *  声明了一些请求有关的回调方法
 */
@protocol RequestDelegate <NSObject>

- (void)request:(HttpRequest *)request CompletedWithResponse:(NSData*) response;

- (void)request:(HttpRequest *)request FailedWithError:(ErrorCode)code;

- (void)request:(HttpRequest *)request recievedNewData:(NSData*)newData;

@end
