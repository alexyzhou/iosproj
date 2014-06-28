//
//  VJDMMessage.h
//  vjourney
//
//  Created by alex on 14-6-27.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    
    MessageTypeMe = false, // 自己发的
    MessageTypeOther = true //别人发得
    
} MessageType;


@interface VJDMMessage : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic) NSDate* time;
@property (nonatomic) BOOL type;
@property (nonatomic, retain) NSNumber* target_id;

-(NSString*)getDateString;

@end
