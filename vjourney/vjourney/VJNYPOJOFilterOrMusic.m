//
//  VJNYPOJOFilter.m
//  vjourney
//
//  Created by alex on 14-6-15.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYPOJOFilterOrMusic.h"

@implementation VJNYPOJOFilterOrMusic

@synthesize title=_title;
@synthesize coverPath=_coverPath;
@synthesize fileName=_fileName;

- (id)initWithTitle:(NSString *)title AndCoverPath:(NSString *)coverPath AndFileName:(NSString*)fileName
{
    self = [super init];
    if (self) {
        // Custom initialization
        //_cover = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:coverPath withExtension:@"png"]]];
        _title = title;
        _coverPath = coverPath;
        _fileName = fileName;
    }
    return self;
}

@end
