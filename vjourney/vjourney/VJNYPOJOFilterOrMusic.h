//
//  VJNYPOJOFilter.h
//  vjourney
//
//  Created by alex on 14-6-15.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VJNYPOJOFilterOrMusic : NSObject

@property(strong,nonatomic) NSString* title;
@property(strong,nonatomic) NSString* coverPath;
@property(strong,nonatomic) NSString* fileName;

- (id)initWithTitle:(NSString *)title AndCoverPath:(NSString *)coverPath AndFileName:(NSString*)fileName;

@end
