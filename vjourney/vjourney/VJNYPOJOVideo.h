//
//  VJNYPOJOVideo.h
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VJNYPOJOVideo : NSObject

@property(nonatomic) NSInteger vid;
@property(nonatomic) NSInteger user_id;
@property(nonatomic) NSInteger like;
@property(nonatomic) NSInteger channel_id;
@property(nonatomic,strong) NSString* description;
@property(nonatomic,strong) NSString* url;
@property(nonatomic,strong) NSDate* time;
@end
