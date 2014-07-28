//
//  VJDMVoodoo.h
//  vjourney
//
//  Created by alex on 14-7-5.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VJDMVoodoo : NSManagedObject

@property (nonatomic, retain) NSNumber * vid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * coverUrl;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userName;

@end
