//
//  VJNYPojoUser.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VJNYPOJOUser : NSObject

@property(nonatomic) NSInteger uid;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* avatarUrl;
@property(nonatomic, strong) NSString* token;

+(VJNYPOJOUser*)instance;

@end
