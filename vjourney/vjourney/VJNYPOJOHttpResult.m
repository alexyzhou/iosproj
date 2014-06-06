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
            [VJNYPOJOUser instance].avatarUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[userDic objectForKey:@"avatarUrl"]];
            [VJNYPOJOUser instance].token = [userDic objectForKey:@"token"];
            
            resultObj.response = [VJNYPOJOUser instance];
            
        }
    } else if ([resultObj.action isEqualToString:@"channel/Latest"] || [resultObj.action isEqualToString:@"channel/Promo"] || [resultObj.action isEqualToString:@"channel/Hot"]) {
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
                channel.promotion = [[objDic objectForKey:@"promotion"] boolValue];
                channel.coverUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[objDic objectForKey:@"coverUrl"]];
                
                [resultObj.response addObject:channel];
            }
        }
    } else if ([resultObj.action isEqualToString:@"videoAndUser/Latest"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSArray * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            resultObj.response = [[NSMutableArray alloc] init];
            
            for (NSString* objStr in userDic) {
                VJNYPOJOVideo* video = [[VJNYPOJOVideo alloc] init];
                VJNYPOJOUser* user = [[VJNYPOJOUser alloc] init];
                
                NSDictionary * objDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                NSString* userStr = [objDic objectForKey:@"user"];
                NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                NSString* videoStr = [objDic objectForKey:@"video"];
                NSDictionary * videoDic = [NSJSONSerialization JSONObjectWithData:[videoStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                
                video.vid = [(NSNumber*)[videoDic objectForKey:@"id"] intValue];
                video.description = [videoDic objectForKey:@"description"];
                video.url = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[videoDic objectForKey:@"url"]];
                video.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[videoDic objectForKey:@"time"] intValue]];
                video.userId = [(NSNumber*)[videoDic objectForKey:@"userId"] intValue];
                video.like = [(NSNumber*)[videoDic objectForKey:@"like"] intValue];
                video.watched = [(NSNumber*)[videoDic objectForKey:@"watched"] intValue];
                video.channelId= [(NSNumber*)[videoDic objectForKey:@"channelId"] intValue];
                video.coverUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[videoDic objectForKey:@"coverUrl"]];
                
                user.uid = [(NSNumber*)[userDic objectForKey:@"id"] intValue];
                user.name = [userDic objectForKey:@"name"];
                user.avatarUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[userDic objectForKey:@"avatarUrl"]];
                user.token = [userDic objectForKey:@"token"];
                
                [resultObj.response addObject:[NSArray arrayWithObjects:user, video, nil]];
            }
        }
    }
    return resultObj;
}

@end
