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
    VJNYNotificationTypeLike = 1, //{name} liked your vjourney
    VJNYNotificationTypeChat = 2 //{name} sent you a message
    
} VJNYNotificationType;


@interface VJDMNotification : NSManagedObject

@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * content;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) NSNumber * sender_id;

- (NSString*)contentStringByType;

@end
