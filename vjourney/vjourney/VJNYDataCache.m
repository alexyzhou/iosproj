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
    NSMutableDictionary* _dataDelegateQueue;
    NSMutableDictionary* _dataIdentifierQueue;
    NSMutableDictionary* _requestIsPromo;
    NSMutableArray* _visitQueue;
}
-(void)loadImage:(NSString*)url;
-(void)respondToDelegate:(NSArray*)params;
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataCache = [[NSMutableDictionary alloc] init];
        _dataDelegateQueue = [[NSMutableDictionary alloc] init];
        _dataIdentifierQueue = [[NSMutableDictionary alloc] init];
        _requestIsPromo = [[NSMutableDictionary alloc] init];
        _visitQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(UIImage*)dataByURL:(NSString*)url {
    [_visitQueue removeObject:url];
    [_visitQueue addObject:url];
    return [_dataCache objectForKey:url];
}

#pragma mark - Image Load

+ (void)loadImage:(UIImageView*)cell WithUrl:(NSString*)url AndMode:(int)mode AndIdentifier:(id)identifier AndDelegate:(id<VJNYDataCacheDelegate>)delegate {
    
    if (url == nil) {
        cell.image = nil;
        return;
    }
    
    UIImage* imageData = [[VJNYDataCache instance] dataByURL:url];
    if (imageData == nil) {
        [[VJNYDataCache instance] requestDataByURL:url WithDelegate:delegate AndIdentifier:identifier AndMode:mode];
        cell.image = nil;
    } else {
        cell.image = imageData;
    }
}
+ (void)loadImageForButton:(UIButton*)cell WithUrl:(NSString*)url AndMode:(int)mode AndIdentifier:(id)identifier AndDelegate:(id<VJNYDataCacheDelegate>)delegate {
    
    if (url == nil) {
        [cell setImage:nil forState:UIControlStateNormal];
        return;
    }
    
    UIImage* imageData = [[VJNYDataCache instance] dataByURL:url];
    if (imageData == nil) {
        [[VJNYDataCache instance] requestDataByURL:url WithDelegate:delegate AndIdentifier:identifier AndMode:mode];
        [cell setImage:nil forState:UIControlStateNormal];
    } else {
        [cell setImage:[imageData imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    }
    
}

-(UIImage*)loadImageInBackground:(NSString *)url {
    
    if (url == nil || [url isEqual:@""]) {
        return nil;
    }
    
    //NSLog(@"VJNYCache load image:%@",url);
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
    //NSLog(@"Finished loading Image");
    return imageData;
}

-(void)loadImage:(NSString*)url {

    UIImage* imageData = [self loadImageInBackground:url];
    
    // Image retrieved, call main thread method to update image, passing it the downloaded UIImage
    [self performSelectorOnMainThread:@selector(respondToDelegate:) withObject:[NSArray arrayWithObjects:imageData, url, nil] waitUntilDone:YES];
}

-(void)requestDataByURL:(NSString*)url WithDelegate:(id<VJNYDataCacheDelegate>)delegate AndIdentifier:(id)identifier AndMode:(int)mode {
    NSMutableArray* _requestArr = [_dataDelegateQueue objectForKey:url];
    if (_requestArr != nil) {
        [_requestArr addObject:delegate];
        [[_dataIdentifierQueue objectForKey:url] addObject:identifier];
        [[_requestIsPromo objectForKey:url] addObject:[NSNumber numberWithInt:mode]];
    } else {
        _requestArr = [[NSMutableArray alloc] initWithObjects:delegate, nil];
        NSMutableArray* _requestIdArr = [[NSMutableArray alloc] initWithObjects:identifier, nil];
        NSMutableArray* _requestIsPromoArr = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:mode], nil];
        [_dataDelegateQueue setObject:_requestArr forKey:url];
        [_dataIdentifierQueue setObject:_requestIdArr forKey:url];
        [_requestIsPromo setObject:_requestIsPromoArr forKey:url];
        [self performSelectorInBackground:@selector(loadImage:) withObject:url];
        //NSLog(@"request init");
    }
}

-(void)respondToDelegate:(NSArray*)params {
    UIImage* data = [params objectAtIndex:0];
    NSString* url = [params objectAtIndex:1];
    
    NSMutableArray *delegateArr = [_dataDelegateQueue objectForKey:url];
    NSMutableArray *identifierArr = [_dataIdentifierQueue objectForKey:url];
    NSMutableArray *isPromoArr = [_requestIsPromo objectForKey:url];
    
    for (int i = 0; i < [delegateArr count]; i++) {
        id identifier = [identifierArr objectAtIndex:i];
        id<VJNYDataCacheDelegate> delegate = (id<VJNYDataCacheDelegate>)[delegateArr objectAtIndex:i];
        int isPromo = [((NSNumber*)[isPromoArr objectAtIndex:i]) intValue];
        if ([delegate respondsToSelector:@selector(dataRequestFinished:WithIdentifier:AndMode:)]) {
            [delegate dataRequestFinished:data WithIdentifier:identifier AndMode:isPromo];
        }
        
    }
    
    [_dataDelegateQueue removeObjectForKey:url];
    [_dataIdentifierQueue removeObjectForKey:url];
}

@end
