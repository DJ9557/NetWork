//
//  HttpRequest.m
//  test
//
//  Created by zhubch on 14-10-29.
//  Copyright (c) 2014年 zhubch. All rights reserved.
//

#import "HttpRequest.h"
#import <UIKit/UIKit.h>

@interface HttpRequest () <NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSMutableData *responseData;

@property (strong,nonatomic) NSMutableURLRequest *request;

@end


@implementation HttpRequest

- (id)initWithUrl:(NSString *)url Method:(NSString *)method UseCache:(BOOL)useCache
{
    if (self = [super init]) {
        if (url.length < 4) {
            NSLog(@"你确定这URL能用? ->> url=%@",url);
        }
        if (url.length > 4 && ![[url substringToIndex:4] isEqualToString:@"http"]) {
            self.url = [NSString stringWithFormat:kServerUrl,url];
        }else {
            self.url = url;
        }
        
//        NSLog(@"%@",self.url);
        _isLoading = NO;
        
        self.responseData = [[NSMutableData alloc]init];
        
        if (useCache){
            self.request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
        }else{
           self.request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
        }
        
        self.request.HTTPMethod = method;
        [self.request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
    
    return self;
}

- (void)start
{
    if (self.isLoading) {
        return;
    }
    
    if ([self.request.HTTPMethod isEqualToString:@"POST"]||[self.request.HTTPMethod isEqualToString:@"PUT"]) {
        self.request.HTTPBody = [self.jsonBody dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:self.request delegate:self];
    [conn start];
    
    _isLoading = YES;
}
    #pragma mark 简便类方法

+ (void)getWithUrl:(NSString *)url UseCache:(BOOL)useCache CallBack:(CompletedCallBack)callBack
{
    HttpRequest *request = [[HttpRequest alloc]initWithUrl:url Method:@"GET" UseCache:useCache];
    request.completedCallBack = callBack;
    [request start];
}

+ (void)postWithUrl:(NSString *)url Body:(NSString *)body CallBack:(CompletedCallBack)callBack
{
    HttpRequest *request = [[HttpRequest alloc]initWithUrl:url Method:@"POST" UseCache:NO];
    request.jsonBody = body;
    request.completedCallBack = callBack;
    [request start];
}

#pragma mark connectionData代理方法

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _isLoading = NO;

    if (self.completedCallBack) {
        self.completedCallBack(self.responseData);
    }
    
    [self.delegate request:self CompletedWithResponse:self.responseData];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{    
    if (self.completedCallBack) {
        self.completedCallBack(nil);
    }
    
    if (self.failedCallBack) {
        self.failedCallBack(Timeout);
    }
    
    if ([self.delegate respondsToSelector:@selector(request:FailedWithError:)]){
        [self.delegate request:self FailedWithError:Timeout];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

@end
