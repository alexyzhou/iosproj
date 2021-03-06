//
//  VJNYPOJOHttpResult.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYPOJOHttpResult.h"
#import "VJDMModel.h"
#import "VJDMUser.h"
#import "VJDMMessage.h"
#import "VJDMNotification.h"
#import "VJDMThread.h"
#import "VJDMVoodoo.h"
#import "VJDMUserAvatar.h"

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
    
    NSLog(@"Action-%@",resultObj.action);
    
    if ([resultObj.action isEqualToString:@"login"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            [VJNYPOJOUser sharedInstance].uid = [userDic objectForKey:@"id"];
            [VJNYPOJOUser sharedInstance].name = [userDic objectForKey:@"name"];
            [VJNYPOJOUser sharedInstance].username = [userDic objectForKey:@"username"];
            [VJNYPOJOUser sharedInstance].avatarUrl = (NSString*)[VJNYUtilities filterNSNullForObject:[userDic objectForKey:@"avatarUrl"]];
            [VJNYPOJOUser sharedInstance].token = [userDic objectForKey:@"token"];
            [VJNYPOJOUser sharedInstance].gender = [userDic objectForKey:@"gender"];
            [VJNYPOJOUser sharedInstance].age = [userDic objectForKey:@"age"];
            [VJNYPOJOUser sharedInstance].coverUrl = [userDic objectForKey:@"coverUrl"];
            [VJNYPOJOUser sharedInstance].description = [userDic objectForKey:@"description"];
            
            VJDMUser* user = (VJDMUser*)[[VJDMModel sharedInstance] getCurrentUser];
            if (user == nil) {
                user = (VJDMUser*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMUser"];
            }
            user.uid = [VJNYPOJOUser sharedInstance].uid;
            user.name = [VJNYPOJOUser sharedInstance].name;
            user.username = [VJNYPOJOUser sharedInstance].username;
            user.avatars_url = (NSString*)[VJNYUtilities filterNSNullForObject:[userDic objectForKey:@"avatarUrl"]];
            user.token = [VJNYPOJOUser sharedInstance].token;
            user.gender = (NSString*)[VJNYUtilities filterNSNullForObject:[VJNYPOJOUser sharedInstance].gender];
            user.age = (NSNumber*)[VJNYUtilities filterNSNullForObject:[VJNYPOJOUser sharedInstance].age];
            user.cover_url = (NSString*)[VJNYUtilities filterNSNullForObject:[userDic objectForKey:@"coverUrl"]];
            user.user_description = [VJNYPOJOUser sharedInstance].description;
            
            [[VJDMModel sharedInstance] saveChanges];
            
            resultObj.response = [VJNYPOJOUser sharedInstance];
            
        }
    } else if ([resultObj.action isEqualToString:@"user/Info"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            VJNYPOJOUser* user = [[VJNYPOJOUser alloc] init];
            user.uid = [userDic objectForKey:@"id"];
            user.name = [userDic objectForKey:@"name"];
            
            user.avatarUrl = (NSString*)[VJNYUtilities filterNSNullForObject:[userDic objectForKey:@"avatarUrl"]];
            
            user.gender = [userDic objectForKey:@"gender"];
            user.age = [userDic objectForKey:@"age"];
            user.coverUrl = [userDic objectForKey:@"coverUrl"];
            user.description = [userDic objectForKey:@"description"];
            
            resultObj.response = user;
        }
    } else if ([resultObj.action isEqualToString:@"user/AvatarUrl"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            VJDMUserAvatar* userAvatar = (VJDMUserAvatar*)[[VJDMModel sharedInstance] getUserAvatarByUserID:[userDic objectForKey:@"id"]];
            if (userAvatar == nil) {
                userAvatar = (VJDMUserAvatar*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMUserAvatar"];
                userAvatar.userId = [userDic objectForKey:@"id"];
            }
            userAvatar.avatarUrl = (NSString*)[VJNYUtilities filterNSNullForObject:[userDic objectForKey:@"avatarUrl"]];
            
            [[VJDMModel sharedInstance] saveChanges];
            resultObj.response = userAvatar;
        }
    } else if ([resultObj.action isEqualToString:@"channel/Latest"] || [resultObj.action isEqualToString:@"channel/Promo"] || [resultObj.action isEqualToString:@"channel/Review"]|| [resultObj.action isEqualToString:@"channel/Hot"] || [resultObj.action isEqualToString:@"channel/Latest/Query/Name"]) {
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
                channel.coverUrl = [objDic objectForKey:@"coverUrl"];
                
                [resultObj.response addObject:channel];
            }
        }
    } else if ([resultObj.action isEqualToString:@"channel/LatestByUser"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSArray * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            resultObj.response = [[NSMutableArray alloc] init];
            NSMutableArray* channelArray = [NSMutableArray array];
            NSMutableDictionary* unReadDic = [NSMutableDictionary dictionary];
            
            for (NSString* objStr in userDic) {
                VJNYPOJOChannel* channel = [[VJNYPOJOChannel alloc] init];
                //NSLog(@"%@",objStr);
                
                NSDictionary * originDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                if ([originDic objectForKey:@"channel"] && [originDic objectForKey:@"unread"]) {
                    NSDictionary * objDic = [NSJSONSerialization JSONObjectWithData:[[originDic objectForKey:@"channel"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                    
                    channel.cid = [objDic objectForKey:@"id"];
                    channel.name = [objDic objectForKey:@"name"];
                    channel.description = [objDic objectForKey:@"description"];
                    channel.creatorUserId = [objDic objectForKey:@"creatorUserId"];
                    channel.createTime = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[objDic objectForKey:@"createTime"] intValue]];
                    channel.videoCount = [objDic objectForKey:@"videoCount"];
                    channel.promotion = [objDic objectForKey:@"promotion"];
                    channel.coverUrl = [objDic objectForKey:@"coverUrl"];
                    
                    [channelArray addObject:channel];
                    [unReadDic setObject:[originDic objectForKey:@"unread"] forKey:channel.cid];
                } else {
                    channel.cid = [originDic objectForKey:@"id"];
                    channel.name = [originDic objectForKey:@"name"];
                    channel.description = [originDic objectForKey:@"description"];
                    channel.creatorUserId = [originDic objectForKey:@"creatorUserId"];
                    channel.createTime = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[originDic objectForKey:@"createTime"] intValue]];
                    channel.videoCount = [originDic objectForKey:@"videoCount"];
                    channel.promotion = [originDic objectForKey:@"promotion"];
                    channel.coverUrl = [originDic objectForKey:@"coverUrl"];
                    
                    [channelArray addObject:channel];
                }
                
                
                
                //[resultObj.response addObject:channel];
            }
            
            [resultObj.response addObject:channelArray];
            [resultObj.response addObject:unReadDic];
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
                video.url = [videoDic objectForKey:@"url"];
                video.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[videoDic objectForKey:@"time"] intValue]];
                video.userId = [videoDic objectForKey:@"userId"];
                video.like = [videoDic objectForKey:@"like"];
                video.watched = [videoDic objectForKey:@"watched"];
                video.channelId= [videoDic objectForKey:@"channelId"];
                video.coverUrl = [videoDic objectForKey:@"coverUrl"];
                
                user.uid = [userDic objectForKey:@"id"];
                user.name = [userDic objectForKey:@"name"];
                user.avatarUrl = (NSString*)[VJNYUtilities filterNSNullForObject:[userDic objectForKey:@"avatarUrl"]];
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
                VJNYPOJOChannel* channel = [[VJNYPOJOChannel alloc] init];
                
                NSDictionary * objDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                NSString* userStr = [objDic objectForKey:@"channel"];
                NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                NSString* videoStr = [objDic objectForKey:@"video"];
                NSDictionary * videoDic = [NSJSONSerialization JSONObjectWithData:[videoStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                video.vid = [videoDic objectForKey:@"id"];
                video.description = [videoDic objectForKey:@"description"];
                video.url = [videoDic objectForKey:@"url"];
                video.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[videoDic objectForKey:@"time"] intValue]];
                video.userId = [videoDic objectForKey:@"userId"];
                video.like = [videoDic objectForKey:@"like"];
                video.watched = [videoDic objectForKey:@"watched"];
                video.channelId= [videoDic objectForKey:@"channelId"];
                video.coverUrl = [videoDic objectForKey:@"coverUrl"];
                
                channel.cid = [userDic objectForKey:@"id"];
                channel.name = [userDic objectForKey:@"name"];
                channel.coverUrl = [userDic objectForKey:@"coverUrl"];
                
                NSArray* array = [NSArray arrayWithObjects:video, channel, nil];
                
                [resultObj.response addObject:array];
            }
        }
    } else if ([resultObj.action isEqualToString:@"video/LikeList"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSArray * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            resultObj.response = [[NSMutableArray alloc] init];
            
            for (NSString* objStr in userDic) {
                
                NSDictionary * videoDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                [resultObj.response addObject:videoDic];
            }
        }
    } else if ([resultObj.action isEqualToString:@"notif/Chat/Get"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSArray * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            //resultObj.response = [[NSMutableArray alloc] init];
            
            NSNumber* hasNewEntry = [NSNumber numberWithBool:NO];
            
            for (NSString* objStr in userDic) {
                
                if ([hasNewEntry boolValue] == false) {
                    hasNewEntry = [NSNumber numberWithBool:YES];
                }
                
                VJDMMessage* message = (VJDMMessage*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMMessage"];
                
                NSDictionary * objDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                NSString* userStr = [objDic objectForKey:@"user"];
                NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                NSString* chatStr = [objDic objectForKey:@"chatRecord"];
                NSDictionary * chatDic = [NSJSONSerialization JSONObjectWithData:[chatStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                
                message.content = [chatDic objectForKey:@"content"];
                message.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[chatDic objectForKey:@"time"] intValue]];
                message.target_id = chatDic[@"fromUserId"];
                message.type = MessageTypeOther;
                
                //[resultObj.response addObject:message];
                
                VJDMThread* thread = (VJDMThread*)[[VJDMModel sharedInstance] getThreadByTargetID:message.target_id];
                
                if (thread == nil) {
                    thread = (VJDMThread*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMThread"];
                    thread.target_id = message.target_id;
                    thread.target_name = userDic[@"name"];
                    
                    VJDMUserAvatar* userAvatar = (VJDMUserAvatar*)[[VJDMModel sharedInstance] getUserAvatarByUserID:thread.target_id];
                    if (userAvatar == nil) {
                        userAvatar = (VJDMUserAvatar*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMUserAvatar"];
                        userAvatar.userId = thread.target_id;
                    }
                    userAvatar.avatarUrl = (NSString*)[VJNYUtilities filterNSNullForObject:userDic[@"avatarUrl"]];
            
                    thread.last_message = message.content;
                    thread.last_time = message.time;
                } else {
                    if (thread.last_time.timeIntervalSince1970 < message.time.timeIntervalSince1970) {
                        thread.last_message = message.content;
                        thread.last_time = message.time;
                    }
                }
            }
            [[VJDMModel sharedInstance] saveChanges];
            
            resultObj.response = hasNewEntry;
        }
    } else if ([resultObj.action isEqualToString:@"notif/SysNotif/Get"]) {
        if (result==Success) {
            NSString* userJson = [dict objectForKey:@"response"];
            
            NSArray * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            resultObj.response = [[NSMutableArray alloc] init];
            
            NSNumber* hasNewEntry = [NSNumber numberWithBool:NO];
            
            for (NSString* objStr in userDic) {
                
                if ([hasNewEntry boolValue] == false) {
                    hasNewEntry = [NSNumber numberWithBool:YES];
                }
                
                VJDMNotification* notif = (VJDMNotification*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMNotification"];
                
                NSDictionary * objDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                NSString* userStr = [objDic objectForKey:@"user"];
                NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                NSString* notifStr = [objDic objectForKey:@"notification"];
                NSDictionary * notifDic = [NSJSONSerialization JSONObjectWithData:[notifStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                
                notif.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[notifDic objectForKey:@"time"] intValue]];
                notif.content = notifDic[@"content"];
                notif.type = [notifDic[@"type"] intValue];
                notif.sender_id = notifDic[@"senderId"];
                
                VJDMUserAvatar* userAvatar = (VJDMUserAvatar*)[[VJDMModel sharedInstance] getUserAvatarByUserID:notif.sender_id];
                if (userAvatar == nil) {
                    userAvatar = (VJDMUserAvatar*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMUserAvatar"];
                    userAvatar.userId = notif.sender_id;
                }
                userAvatar.avatarUrl = (NSString*)[VJNYUtilities filterNSNullForObject:userDic[@"avatarUrl"]];
                
            }
            [[VJDMModel sharedInstance] saveChanges];
            
            resultObj.response = hasNewEntry;
        }
    } else if ([resultObj.action isEqualToString:@"video/Hot/User"]) {
        if (result==Success) {
            NSString* objStr = [dict objectForKey:@"response"];
            
            VJNYPOJOVideo* video = [[VJNYPOJOVideo alloc] init];
            
            NSDictionary * videoDic = [NSJSONSerialization JSONObjectWithData:[objStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            video.vid = [videoDic objectForKey:@"id"];
            video.description = [videoDic objectForKey:@"description"];
            video.url = [videoDic objectForKey:@"url"];
            video.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[videoDic objectForKey:@"time"] intValue]];
            video.userId = [videoDic objectForKey:@"userId"];
            video.like = [videoDic objectForKey:@"like"];
            video.watched = [videoDic objectForKey:@"watched"];
            video.channelId= [videoDic objectForKey:@"channelId"];
            video.coverUrl = [videoDic objectForKey:@"coverUrl"];
            
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
            
            NSDictionary * objDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            NSString* userStr = [objDic objectForKey:@"user"];
            NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            NSString* whisperStr = [objDic objectForKey:@"voodoo"];
            NSDictionary * whisperDic = [NSJSONSerialization JSONObjectWithData:[whisperStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            
            //VJNYPOJOWhisper* whisper = [[VJNYPOJOWhisper alloc] init];
            
            VJDMVoodoo* whisper = (VJDMVoodoo*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMVoodoo"];
            
            whisper.vid = [whisperDic objectForKey:@"id"];
            whisper.url = [whisperDic objectForKey:@"url"];
            whisper.coverUrl = [whisperDic objectForKey:@"coverUrl"];
            whisper.userId = [whisperDic objectForKey:@"userId"];
            whisper.time = [NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[whisperDic objectForKey:@"time"] intValue]];
            whisper.userName = [userDic objectForKey:@"name"];
            
            [[VJDMModel sharedInstance] saveChanges];
            
            resultObj.response = whisper;
        }
    } else {
        NSString* userJson = [dict objectForKey:@"response"];
        
        NSDictionary * userDic = [NSJSONSerialization JSONObjectWithData:[userJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
        
        resultObj.response = userDic;
    }
    
    NSLog(@"Action-%@-FINISHED!",resultObj.action);
    
    return resultObj;
}

@end
