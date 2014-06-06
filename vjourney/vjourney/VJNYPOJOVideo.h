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
@property(nonatomic) NSInteger userId;
@property(nonatomic) NSInteger like;
@property(nonatomic) NSInteger watched;
@property(nonatomic) NSInteger channelId;
@property(nonatomic,strong) NSString* description;
@property(nonatomic,strong) NSString* url;
@property(nonatomic,strong) NSDate* time;
@property(nonatomic,strong) NSString* coverUrl;
@end
