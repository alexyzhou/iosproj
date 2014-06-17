//
//  VJNYPOJOFilter.m
//  vjourney
//
//  Created by alex on 14-6-15.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYPOJOFilter.h"

@implementation VJNYPOJOFilter

@synthesize title=_title;
@synthesize cover=_cover;

- (id)initWithTitle:(NSString *)title AndCoverPath:(NSString *)coverPath
{
    self = [super init];
    if (self) {
        // Custom initialization
        //_cover = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:coverPath withExtension:@"png"]]];
        _title = title;
    }
    return self;
}

@end
