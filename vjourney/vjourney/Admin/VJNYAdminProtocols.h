//
//  VJNYAdminProtocols.h
//  vjourney
//
//  Created by alex on 14-8-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VJNYAdminChannelReviewDelegate <NSObject>

- (void)channelAcceptActionWithID:(NSNumber*)cid;
- (void)channelRejectActionWithID:(NSNumber*)cid;

@end
