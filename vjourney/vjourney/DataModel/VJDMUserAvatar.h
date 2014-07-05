//
//  VJDMUserAvatar.h
//  vjourney
//
//  Created by alex on 14-7-6.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VJDMUserAvatar : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * avatarUrl;

@end
