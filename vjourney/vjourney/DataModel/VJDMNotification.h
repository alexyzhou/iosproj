//
//  VJDMNotification.h
//  vjourney
//
//  Created by alex on 14-6-28.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    
    VJNYNotificationTypeGeneral = 0, // Other
    VJNYNotificationTypeLike = 1 //{name} like your vjourney
    
} VJNYNotificationType;


@interface VJDMNotification : NSManagedObject

@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * content;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) NSNumber * sender_id;
@property (nonatomic, retain) NSString * sender_avatar_url;

- (NSString*)contentStringByType;

@end
