//
//  DownloadManager.h
//  DownloadTest
//
//  Created by zhubch on 14-12-5.
//  Copyright (c) 2014年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BadNetWork,//网络异常
    FialedToWrittingFile, //写入文件失败
    DidCanceled //被取消下载
}Error;

@protocol DownloadDelegate <NSObject>

@optional

- (void)downloadProgress:(float)percentage Total:(long long) size;

- (void)downloadFailedWithCode:(Error)code;

- (void)downloadFinished;

@end

@interface DownloadManager : NSObject

@property (nonatomic,strong) NSString* url;

/**
 *  不要绝对路径，document目录以后的路径就够了
 */
@property (nonatomic,strong) NSString* filePath;

@property (nonatomic,assign,readonly) BOOL isDownloading;

@property (nonatomic,strong) id <DownloadDelegate> delegate;

- (instancetype)initWithUrl:(NSString*)url FilePath:(NSString*)path;

- (void)startDownload;

- (void)cancel;

@end

@interface DownloadManager (FileAttribute)

+ (NSString*)fullPathForPath:(NSString*)path;

+ (NSString*)documentPath;

+ (long long) fileSizeAtPath:(NSString*) filePath;

+ (float)folderSizeAtPath:(NSString*) folderPath;

+ (float)getFreeDiskSpace;

@end
