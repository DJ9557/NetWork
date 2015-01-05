//
//  ImageCache.h
//
//  Created by qianfeng on 14-9-19.
//  Copyright (c) 2014年 zbc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  支持本地缓存和内存缓存
 */

@interface ImageCache : NSObject

+ (ImageCache*)defaultCache;

/**
 *  为imgView异步加载图片，优先从缓存加载
 *
 *  @param url     URL
 *  @param imgView 需要图片的imageView
 */
- (void)loadImageWithUrl:(NSString*)url ForImageView:(UIImageView*)imgView;

/**
 *  为button异步加载图片，优先从缓存加载
 *
 *  @param url    URL
 *  @param button 需要图片的按钮
 */
- (void)loadImageWithUrl:(NSString*)url ForButton:(UIButton*)button;

/**
 *  根据identifier尝试从内存中找到加载过的内存,找不到返回nil
 *
 *  @param identifier 标识符
 *
 *  @return 对应的image
 */
- (UIImage*)imageWithIdentifier:(NSString*)identifier;

/**
 *  暂时不用，但可能以后要用的可以先缓存下来
 *
 *  @param url 
 */
- (void)cacheImageWithUrl:(NSString*)url;

/**
 *  //内存紧张的时候缓存应该清掉,不会清掉本地缓存，只是在内存中释放暂时不用的
 */
- (void)clearCache;

@end

@interface UIImageView (NetWork)

/**
 *  为imageview异步加载图片
 *
 *  @param url         图片地址
 *  @param placeHolder 加载完成前显示的图片
 */
- (void)setImageWithUrl:(NSString*)url PlaceHolder:(UIImage*)placeHolder;

@end

@interface UIButton (NetWork)

/**
 *  为imageview异步加载图片
 *
 *  @param url         图片地址
 *  @param placeHolder 加载完成前显示的图片
 */
- (void)setImageWithUrl:(NSString*)url PlaceHolder:(UIImage*)placeHolder;

@end
