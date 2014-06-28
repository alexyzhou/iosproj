//
//  VJDMNotification.m
//  vjourney
//
//  Created by alex on 14-6-28.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJDMNotification.h"


@implementation VJDMNotification

@dynamic time;
@dynamic content;
@dynamic type;
@dynamic sender_id;
@dynamic sender_avatar_url;

- (NSString*)contentStringByType {
    if (self.type == VJNYNotificationTypeGeneral) {
        return self.content;
    } else if (self.type == VJNYNotificationTypeLike) {
        return [self.content stringByAppendingString:@" Liked your Vjourney"];
    } else {
        return @"";
    }
}

@end
