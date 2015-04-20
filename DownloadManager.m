//
//  DownloadManager.m
//  DownloadTest
//
//  Created by zhubch on 14-12-5.
//  Copyright (c) 2014年 zhubch. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager () <NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSMutableData *responseData;

@property (strong,nonatomic) NSMutableURLRequest *request;

@property (strong,nonatomic) NSURLConnection *connection;

@property (assign,nonatomic) double total;

@end

@implementation DownloadManager

- (instancetype)initWithUrl:(NSString *)url FilePath:(NSString *)path
{
    self = [super init];
    
    if (self) {
        self.url = url;

        self.filePath = path;
        self.responseData = [NSMutableData data];
        self.request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    }
    
    return self;
}

- (void)setFilePath:(NSString *)filePath
{
    _filePath = [[DownloadManager documentPath] stringByAppendingString:filePath];
//    NSLog(@"%@",_filePath);
}

- (void)startDownload
{
    self.connection = [[NSURLConnection alloc]initWithRequest:self.request delegate:self];
    [self.connection start];
}

- (void)cancel
{
    if (self.connection) {
        [self.connection cancel];
        
        self.connection = nil;
    }
    
    _isDownloading = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    _isDownloading = YES;
    [self.responseData appendData:data];
    if (_total <=0 ) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(downloadProgress:Total:)]) {
        [self.delegate downloadProgress:((double)_responseData.length) / _total Total:_total];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.total = (double)response.expectedContentLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.responseData writeToFile:self.filePath atomically:YES]) {
        if ([self.delegate respondsToSelector:@selector(downloadFinished)]) {
            [self.delegate downloadFinished];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(downloadFailedWithCode:)]) {
            [self.delegate downloadFailedWithCode:FialedToWrittingFile];
        }
    }
    _isDownloading = NO;

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _isDownloading = NO;
    if ([self.delegate respondsToSelector:@selector(downloadFailedWithCode:)]) {
        [self.delegate downloadFailedWithCode:BadNetWork];
    }
}

@end

@implementation DownloadManager (FileAttribute)

+ (NSString *)fullPathForPath:(NSString *)path
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docPath stringByAppendingString:path];
}

+ (NSString *)documentPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (long long) fileSizeAtPath:(NSString*) filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (float ) folderSizeAtPath:(NSString*) folderPath{

    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

+ (float)getFreeDiskSpace {
    float totalSpace;
    float totalFreeSpace;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];

        totalSpace = [fileSystemSizeInBytes floatValue]/1024.0f/1024.0f;
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f;

    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

@end
