//
//  VJNYPOJOChannel.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VJNYPOJOChannel : NSObject

@property(nonatomic, strong) NSNumber* cid;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* description;
@property(nonatomic, strong) NSNumber* creatorUserId;
@property(nonatomic, strong) NSDate* createTime;
@property(nonatomic, strong) NSNumber* videoCount;
@property(nonatomic, strong) NSNumber* promotion;
@property(nonatomic, strong) NSString* coverUrl;

@end
