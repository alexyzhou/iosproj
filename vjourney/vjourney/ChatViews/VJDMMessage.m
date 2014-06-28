//
//  VJDMMessage.m
//  vjourney
//
//  Created by alex on 14-6-27.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJDMMessage.h"
#import "VJNYUtilities.h"

@implementation VJDMMessage

@dynamic content;
@dynamic time;
@dynamic type;
@dynamic target_id;

-(NSString*)getDateString {
    return [VJNYUtilities formatDataString:self.time];
}

@end
