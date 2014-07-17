//
//  VJNYHTTPHelper.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYHTTPHelper.h"

@implementation VJNYHTTPHelper

static NSString* _remoteIpAddr = @"vjourney.duapp.com";

+(void)setIPAddr:(NSString*)ip {
    _remoteIpAddr = [NSString stringWithFormat:@"%@:8080",ip];
}

+(NSURL*)connectionUrlByAppendingRequest:(NSString*)request {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/%@",_remoteIpAddr,request]];
}
/*
+(NSString*)pathUrlPrefix {
    return [NSString stringWithFormat:@"http://%@/",_remoteIpAddr];
}
+(NSString*)pathUrlByRemovePrefix:(NSString*)fullUrl {
    NSString* prefix = [self pathUrlPrefix];
    if ([fullUrl length] > [prefix length]) {
        return [fullUrl substringFromIndex:prefix.length];
    } else {
        return nil;
    }
}
+(NSString*)checkAndSetPathUrlByAppendPrefixWithValue:(NSString*)value {
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return [[self pathUrlPrefix] stringByAppendingString:value];
    }
}
*/
+(NSString*)mediaPlayCodeWithURL:(NSString*)url andWidth:(NSInteger)width andHeight:(NSInteger)height {
    
    static NSString *embedHTML = @"\
    <!DOCTYPE HTML>\
    <html>\
    <head>\
    <script type=\"text/javascript\">\
    function playvideo() {\
    var myVideo=document.getElementsByTagName('video')[0];\
    if (myVideo.paused)\
    myVideo.play();\
    else\
    myVideo.pause();\
    }\
    </script>\
    <style TYPE=\"text/css\">\
    video {\
    image-fit: fill;\
    }\
    </style>\
    </head>\
    <video id=\"player\" x=\"0\" y=\"0\" webkit-playsinline width=\"%d\" height=\"%d\" loop=\"true\" onclick=\"playvideo()\">\
    <source src=\"%@\"/>\
    </video>\
    </body>\
    </html>";
    
    return [NSString stringWithFormat:embedHTML, width, height, url];
}

+(void)sendJSONRequest:(NSString*)target WithParameters:(NSMutableDictionary*)parameters AndDelegate:(id<ASIHTTPRequestDelegate>) delegate {
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:target]];
    
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    
    request.allowCompressedResponse = NO;
    request.useCookiePersistence = NO;
    request.shouldCompressRequestBody = NO;
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"%@",[request.url absoluteString]);
    NSLog(@"%@",jsonString);
    
    request.delegate = delegate;
    
    [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    [request startAsynchronous];
    
}

+(void)getJSONRequest:(NSString*)target WithParameters:(NSMutableDictionary*)parameters AndDelegate:(id<ASIHTTPRequestDelegate>) delegate {
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:target]];
    
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    [request setResponseEncoding:NSUTF8StringEncoding];
    
    request.allowCompressedResponse = NO;
    request.useCookiePersistence = NO;
    request.shouldCompressRequestBody = NO;
    
    if (parameters!=nil) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
        NSLog(@"%@",[request.url absoluteString]);
        NSLog(@"%@",jsonString);
        
        [request setPostBody:[NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    request.delegate = delegate;
    
    
    [request startAsynchronous];
}

#pragma mark - Social Platform Delegate

+ (BOOL)sendShareToSocialPlatformWithContent:(NSString *)content andImage:(NSData *)image AndType:(ShareType)st {
    
    id<ISSContent> issContent = [ShareSDK content:content defaultContent:@"" image:[ShareSDK imageWithData:image fileName:@"videoCover.jpg" mimeType:@"image/jpeg"] title:nil url:@"http://vjourneypolyu.wix.com/vjourneypolyu" description:@"test Description" mediaType:SSPublishContentMediaTypeNews];
    
    __block BOOL execResult;
    
    [ShareSDK shareContent:issContent type:st authOptions:nil statusBarTips:NO result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
        if (state == SSResponseStateSuccess) {
            execResult = true;
        } else if (state == SSResponseStateFail) {
            NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
            execResult = false;
        }
    }];
    
    return execResult;
}

@end
