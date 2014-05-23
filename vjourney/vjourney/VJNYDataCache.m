//
//  VJNYDataCache.m
//  vjourney
//
//  Created by alex on 14-5-23.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYDataCache.h"

@interface VJNYDataCache ()
{
    NSMutableDictionary* _dataCache;
    NSMutableArray* _visitQueue;
}
-(void)loadImage:(NSArray*)params;
-(void)loadImagePromo:(NSArray*)params;
-(void)respondToDelegate:(NSArray*)params;
-(void)respondPromoToDelegate:(NSArray*)params;
-(UIImage*)loadImageInBackground:(NSString*)url;
@end

@implementation VJNYDataCache

static VJNYDataCache* _instance = NULL;
static const int maxCacheCount = 20;

+(VJNYDataCache*)instance {
    if (_instance == NULL) {
        _instance = [[VJNYDataCache alloc] init];
    }
    return _instance;
}
-(UIImage*)dataByURL:(NSString*)url {
    [_visitQueue removeObject:url];
    [_visitQueue addObject:url];
    return [_dataCache objectForKey:url];
}

#pragma mark - Image Load

-(UIImage*)loadImageInBackground:(NSString *)url {
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage* imageData = [UIImage imageWithData:data];
    [_dataCache setObject:imageData forKey:url];
    [_visitQueue addObject:url];
    if ([_dataCache count] > maxCacheCount) {
        NSString* urlToRemove = [_visitQueue firstObject];
        if (urlToRemove != nil) {
            [_visitQueue removeObjectAtIndex:0];
            [_dataCache removeObjectForKey:urlToRemove];
        }
    }
    return imageData;
}

-(void)loadImage:(NSArray*)params {
    
    NSString* url = [params objectAtIndex:0];
    UIImage* imageData = [self loadImageInBackground:url];
    
    id identifier = [params objectAtIndex:1];
    id<VJNYDataCacheDelegate> delegate = (id<VJNYDataCacheDelegate>)[params objectAtIndex:2];
    // Image retrieved, call main thread method to update image, passing it the downloaded UIImage
    [self performSelectorOnMainThread:@selector(respondToDelegate:) withObject:[NSArray arrayWithObjects:imageData, identifier, delegate, nil] waitUntilDone:YES];
}

-(void)loadImagePromo:(NSArray *)params {
    NSString* url = [params objectAtIndex:0];
    UIImage* imageData = [self loadImageInBackground:url];
    
    id identifier = [params objectAtIndex:1];
    id<VJNYDataCacheDelegate> delegate = (id<VJNYDataCacheDelegate>)[params objectAtIndex:2];
    // Image retrieved, call main thread method to update image, passing it the downloaded UIImage
    [self performSelectorOnMainThread:@selector(respondPromoToDelegate:) withObject:[NSArray arrayWithObjects:imageData, identifier, delegate, nil] waitUntilDone:YES];
}

-(void)requestDataByURL:(NSString*)url WithDelegate:(id<VJNYDataCacheDelegate>)delegate AndIdentifier:(id)identifier {
    [self performSelectorInBackground:@selector(loadImage:) withObject:[NSArray arrayWithObjects:url,identifier,delegate, nil]];
}
-(void)requestPromoDataByURL:(NSString*)url WithDelegate:(id<VJNYDataCacheDelegate>)delegate AndIdentifier:(id)identifier {
    [self performSelectorInBackground:@selector(loadImagePromo:) withObject:[NSArray arrayWithObjects:url,identifier,delegate, nil]];
}

-(void)respondToDelegate:(NSArray*)params {
    UIImage* data = [params objectAtIndex:0];
    id identifier = [params objectAtIndex:1];
    id<VJNYDataCacheDelegate> delegate = (id<VJNYDataCacheDelegate>)[params objectAtIndex:2];
    if ([delegate respondsToSelector:@selector(dataRequestFinished:WithIdentifier:)]) {
        [delegate dataRequestFinished:data WithIdentifier:identifier];
    }
}
-(void)respondPromoToDelegate:(NSArray*)params {
    UIImage* data = [params objectAtIndex:0];
    id identifier = [params objectAtIndex:1];
    id<VJNYDataCacheDelegate> delegate = (id<VJNYDataCacheDelegate>)[params objectAtIndex:2];
    if ([delegate respondsToSelector:@selector(dataPromoRequestFinished:WithIdentifier:)]) {
        [delegate dataPromoRequestFinished:data WithIdentifier:identifier];
    }
}

@end
