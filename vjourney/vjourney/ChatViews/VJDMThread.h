//
//  VJDMThread.h
//  vjourney
//
//  Created by alex on 14-6-27.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VJDMThread : NSManagedObject

@property (nonatomic, retain) NSNumber * target_id;
@property (nonatomic, retain) NSString * target_name;
@property (nonatomic, retain) NSString * last_message;
@property (nonatomic, retain) NSDate * last_time;

@end
