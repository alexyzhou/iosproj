//
//  VJNYPojoUser.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VJNYPOJOUser : NSObject

@property(nonatomic, strong) NSNumber* uid;
@property(nonatomic, strong) NSString* username;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* avatarUrl;
@property(nonatomic, strong) NSString* token;
@property(nonatomic, strong) NSString* gender;
@property(nonatomic, strong) NSNumber* age;
@property(nonatomic, strong) NSString* coverUrl;
@property(nonatomic, strong) NSString* description;

+(VJNYPOJOUser*)sharedInstance;

-(void)insertIdentityToDirectory:(NSMutableDictionary*)dic;

+(void)insertAdminToDirectory:(NSMutableDictionary*)dic;
@end
