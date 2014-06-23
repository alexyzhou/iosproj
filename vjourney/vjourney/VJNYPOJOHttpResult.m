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
            
            [VJNYPOJOUser sharedInstance].uid = [userDic objectForKey:@"id"];
            [VJNYPOJOUser sharedInstance].name = [userDic objectForKey:@"name"];
            [VJNYPOJOUser sharedInstance].username = [userDic objectForKey:@"userName"];
            [VJNYPOJOUser sharedInstance].avatarUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[userDic objectForKey:@"avatarUrl"]];
            [VJNYPOJOUser sharedInstance].token = [userDic objectForKey:@"token"];
            [VJNYPOJOUser sharedInstance].gender = [userDic objectForKey:@"gender"];
            [VJNYPOJOUser sharedInstance].age = [userDic objectForKey:@"age"];
            
            resultObj.response = [VJNYPOJOUser sharedInstance];
            
        }
    } else if ([resultObj.action isEqualToString:@"user/Info"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            VJNYPOJOUser* user = [[VJNYPOJOUser alloc] init];
            user.uid = [userDic objectForKey:@"id"];
            user.name = [userDic objectForKey:@"name"];
            user.avatarUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[userDic objectForKey:@"avatarUrl"]];
            user.gender = [userDic objectForKey:@"gender"];
            user.age = [userDic objectForKey:@"age"];
            
            resultObj.response = user;
        }
    } else if ([resultObj.action isEqualToString:@"channel/Latest"] || [resultObj.action isEqualToString:@"channel/LatestByUser"] || [resultObj.action isEqualToString:@"channel/Promo"] || [resultObj.action isEqualToString:@"channel/Hot"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSArray * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            resultObj.response = [[NSMutableArray alloc] init];
            
            for (NSString* objStr in userDic) {
                VJNYPOJOChannel* channel = [[VJNYPOJOChannel alloc] init];
                //NSLog(@"%@",objStr);
                
                NSDictionary * objDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                channel.cid = [objDic objectForKey:@"id"];
                channel.name = [objDic objectForKey:@"name"];
                channel.description = [objDic objectForKey:@"description"];
                channel.creatorUserId = [objDic objectForKey:@"creatorUserId"];
                channel.createTime = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[objDic objectForKey:@"createTime"] intValue]];
                channel.videoCount = [objDic objectForKey:@"videoCount"];
                channel.promotion = [objDic objectForKey:@"promotion"];
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
                
                
                video.vid = [videoDic objectForKey:@"id"];
                video.description = [videoDic objectForKey:@"description"];
                video.url = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[videoDic objectForKey:@"url"]];
                video.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[videoDic objectForKey:@"time"] intValue]];
                video.userId = [videoDic objectForKey:@"userId"];
                video.like = [videoDic objectForKey:@"like"];
                video.watched = [videoDic objectForKey:@"watched"];
                video.channelId= [videoDic objectForKey:@"channelId"];
                video.coverUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[videoDic objectForKey:@"coverUrl"]];
                
                user.uid = [userDic objectForKey:@"id"];
                user.name = [userDic objectForKey:@"name"];
                user.avatarUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[userDic objectForKey:@"avatarUrl"]];
                user.token = [userDic objectForKey:@"token"];
                user.gender = [userDic objectForKey:@"gender"];
                user.age = [userDic objectForKey:@"age"];
                
                [resultObj.response addObject:[NSArray arrayWithObjects:user, video, nil]];
            }
        }
    } else if ([resultObj.action isEqualToString:@"video/Latest/User"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSArray * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            resultObj.response = [[NSMutableArray alloc] init];
            
            for (NSString* objStr in userDic) {
                
                VJNYPOJOVideo* video = [[VJNYPOJOVideo alloc] init];
                
                NSDictionary * videoDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                video.vid = [videoDic objectForKey:@"id"];
                video.description = [videoDic objectForKey:@"description"];
                video.url = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[videoDic objectForKey:@"url"]];
                video.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[videoDic objectForKey:@"time"] intValue]];
                video.userId = [videoDic objectForKey:@"userId"];
                video.like = [videoDic objectForKey:@"like"];
                video.watched = [videoDic objectForKey:@"watched"];
                video.channelId= [videoDic objectForKey:@"channelId"];
                video.coverUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[videoDic objectForKey:@"coverUrl"]];
                
                [resultObj.response addObject:video];
            }
        }
    } else if ([resultObj.action isEqualToString:@"video/Hot/User"]) {
        if (result==Success) {
            NSString* objStr = [dict objectForKey:@"response"];
            
            VJNYPOJOVideo* video = [[VJNYPOJOVideo alloc] init];
            
            NSDictionary * videoDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            video.vid = [videoDic objectForKey:@"id"];
            video.description = [videoDic objectForKey:@"description"];
            video.url = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[videoDic objectForKey:@"url"]];
            video.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[videoDic objectForKey:@"time"] intValue]];
            video.userId = [videoDic objectForKey:@"userId"];
            video.like = [videoDic objectForKey:@"like"];
            video.watched = [videoDic objectForKey:@"watched"];
            video.channelId= [videoDic objectForKey:@"channelId"];
            video.coverUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[videoDic objectForKey:@"coverUrl"]];
            
            resultObj.response = video;
        }
    } else if ([resultObj.action isEqualToString:@"channel/IsFollow"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            resultObj.response = [NSNumber numberWithBool:[[userDic objectForKey:@"result"] boolValue]];
        }
    } else if ([resultObj.action isEqualToString:@"whisper/Get"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            VJNYPOJOWhisper* whisper = [[VJNYPOJOWhisper alloc] init];
            whisper.wid = [userDic objectForKey:@"id"];
            whisper.url = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[userDic objectForKey:@"url"]];
            whisper.coverUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:[userDic objectForKey:@"coverUrl"]];
            whisper.userId = [userDic objectForKey:@"userId"];
            whisper.receiverId = [userDic objectForKey:@"receiverId"];
            whisper.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[userDic objectForKey:@"time"] intValue]];
            
            resultObj.response = whisper;
        }
    } else {
        NSString* userJson = [dict objectForKey:@"response"];
        
        NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
        
        resultObj.response = userDic;
    }
    return resultObj;
}

@end
