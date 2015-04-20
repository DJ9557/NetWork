//
//  ZBCImageCache.m
//  test
//
//  Created by zhubch on 14-10-30.
//  Copyright (c) 2014年 zhubch. All rights reserved.
//

#import "ImageCache.h"
#import "HttpRequest.h"

static ImageCache *cache = nil;

@implementation ImageCache
{
    NSMutableDictionary *imgDic;
}

- (id)init
{
    if (self = [super init]) {
        imgDic = [[NSMutableDictionary alloc]init];
    }
    return self;
}

+ (ImageCache*)defaultCache
{
    if (cache == nil) {
        cache = [[ImageCache alloc]init];
    }
    return cache;
}

- (void)loadImageWithUrl:(NSString *)url ForButton:(UIButton *)button
{
    if (imgDic[url] != nil) {
        [button setImage:imgDic[url] forState:UIControlStateNormal];
        return;
    }
    [HttpRequest getWithUrl:url UseCache:YES Succese:^(NSData *response) {
        UIImage *img = [UIImage imageWithData:response];
        if (img != nil) {
            [imgDic setObject:img forKey:url];
            [button setImage:img forState:UIControlStateNormal];
        }
    } Failed:^(ErrorCode code) {
        //
    }];
}

- (void)loadImageWithUrl:(NSString *)url ForImageView:(UIImageView *)imgView
{
    if (![[url substringToIndex:4] isEqualToString:@"http"]) {
        url = [NSString stringWithFormat:kServerUrl,url];
    }
    if (imgDic[url] != nil) {
        imgView.image = imgDic[url];
        return;
    }
    NSString *path = [self pathFromUrl:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        imgView.image = [UIImage imageWithContentsOfFile:path];
        [imgDic setObject:imgView.image forKey:url];
        return;
    }
    [HttpRequest getWithUrl:url UseCache:YES Succese:^(NSData *response) {
        UIImage *img = [UIImage imageWithData:response];
        if (img != nil) {
            [imgDic setObject:img forKey:url];
            imgView.image = img;
            
            NSData *data = UIImagePNGRepresentation(img);
            
            if (data == nil) {
                data = UIImageJPEGRepresentation(img, 1);
            }
            [data writeToFile:path atomically:NO];
        }
    } Failed:^(ErrorCode code) {
        //
    }];
}

- (UIImage*)imageWithIdentifier:(NSString *)identifier
{
    UIImage *img = imgDic[identifier];
    if (img == nil) {
        NSString *path = [self pathFromUrl:identifier];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            img = [UIImage imageWithContentsOfFile:path];
            [imgDic setObject:img forKey:identifier];
        }
    }
    return img;
}

- (void)clearCache
{
    [imgDic removeAllObjects];
}

- (void)cacheImageWithUrl:(NSString *)url
{
    if (imgDic[url] != nil) {
        return;
    }
    NSString *path = [self pathFromUrl:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [imgDic setObject:[UIImage imageWithContentsOfFile:path] forKey:url];
        return;
    }
    [HttpRequest getWithUrl:url UseCache:YES Succese:^(NSData *response) {
        UIImage *img = [UIImage imageWithData:response];
        if (img != nil) {
            [imgDic setObject:img forKey:url];
            
            NSData *data = UIImagePNGRepresentation(img);
            
            if (data == nil) {
                data = UIImageJPEGRepresentation(img, 1);
            }
            [data writeToFile:path atomically:NO];
        }
    } Failed:^(ErrorCode code) {
        //
    }];
}

- (NSString*)pathFromUrl:(NSString*)url
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName =[NSString stringWithFormat:@"/%@", url];
    return [docPath stringByAppendingString:fileName];
}

@end

@implementation UIImageView (NetWork)

- (void)setImageWithUrl:(NSString *)url PlaceHolder:(UIImage *)placeHolder
{
    if (![[url substringToIndex:4] isEqualToString:@"http"]) {
        url = [NSString stringWithFormat:kServerUrl,url];
    }
    
    self.image = placeHolder;
    [[ImageCache defaultCache] loadImageWithUrl:url ForImageView:self];
}

@end

@implementation UIButton (NetWork)

- (void)setImageWithUrl:(NSString *)url PlaceHolder:(UIImage *)placeHolder
{
    if (![[url substringToIndex:4] isEqualToString:@"http"]) {
        url = [NSString stringWithFormat:kServerUrl,url];
    }
    
    [self setImage:placeHolder forState:UIControlStateNormal];
    [[ImageCache defaultCache] loadImageWithUrl:url ForButton:self];
}

@end


