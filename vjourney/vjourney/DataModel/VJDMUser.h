//
//  VJDMUser.h
//  vjourney
//
//  Created by alex on 14-7-10.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VJDMUser : NSManagedObject

@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * avatars_url;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * cover_url;
@property (nonatomic, retain) NSString * user_description;

@end
