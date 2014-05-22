//
//  VJNYDSChannelSource.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VJNYPOJOChannel.h"
@interface VJNYDSChannelSource : NSObject<UITableViewDataSource>
@property(nonatomic,strong) NSMutableArray* data;

- (VJNYDSChannelSource*)initWithArrayOfChannels:(NSMutableArray*)arrData;
@end
