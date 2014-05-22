//
//  VJNYPOJOHttpResult.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYPOJOHttpResult.h"

@implementation VJNYPOJOHttpResult

@synthesize result=_result;
@synthesize action=_action;
@synthesize response=_response;

+(VJNYPOJOHttpResult*)resultFromResponseString:(NSString*)response {
    
    VJNYPOJOHttpResult* resultObj = [[VJNYPOJOHttpResult alloc] init];
    
    NSError *err = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
    // access the directionary
    int result = [(NSNumber*)[dict objectForKey:@"result"] intValue];
    resultObj.result = result;
    resultObj.action = [dict objectForKey:@"action"];
    resultObj.response = NULL;
    
    if ([resultObj.action isEqualToString:@"login"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            
            [VJNYPOJOUser instance].uid = [(NSNumber*)[userDic objectForKey:@"id"] intValue];
            [VJNYPOJOUser instance].name = [userDic objectForKey:@"name"];
            [VJNYPOJOUser instance].avatar_url = [userDic objectForKey:@"avatars_url"];
            [VJNYPOJOUser instance].token = [userDic objectForKey:@"token"];
            
            resultObj.response = [VJNYPOJOUser instance];
            
        }
    } else if ([resultObj.action isEqualToString:@"channel/Hot"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSArray * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            resultObj.response = [[NSMutableArray alloc] init];
            
            for (NSString* objStr in userDic) {
                VJNYPOJOChannel* channel = [[VJNYPOJOChannel alloc] init];
                //NSLog(@"%@",objStr);
                
                NSDictionary * objDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                channel.cid = [(NSNumber*)[objDic objectForKey:@"id"] intValue];
                channel.name = [objDic objectForKey:@"name"];
                channel.description = [objDic objectForKey:@"description"];
                channel.creatorUserId = [(NSNumber*)[objDic objectForKey:@"creatorUserId"] intValue];
                channel.createTime = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[objDic objectForKey:@"createTime"] intValue]];
                channel.videoCount = [(NSNumber*)[objDic objectForKey:@"videoCount"] intValue];
                
                [resultObj.response addObject:channel];
            }
        }
    } else if ([resultObj.action isEqualToString:@"video/Latest"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSArray * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            resultObj.response = [[NSMutableArray alloc] init];
            
            for (NSString* objStr in userDic) {
                VJNYPOJOVideo* video = [[VJNYPOJOVideo alloc] init];
                //NSLog(@"%@",objStr);
                
                NSDictionary * objDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                video.vid = [(NSNumber*)[objDic objectForKey:@"id"] intValue];
                video.description = [objDic objectForKey:@"description"];
                video.url = [objDic objectForKey:@"url"];
                video.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[objDic objectForKey:@"time"] intValue]];
                video.user_id = [(NSNumber*)[objDic objectForKey:@"user_id"] intValue];
                video.like = [(NSNumber*)[objDic objectForKey:@"like"] intValue];
                video.channel_id= [(NSNumber*)[objDic objectForKey:@"channel_id"] intValue];
                
                [resultObj.response addObject:video];
            }
        }
    }
    return resultObj;
}

@end
