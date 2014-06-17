//
//  VJNYPOJOFilter.h
//  vjourney
//
//  Created by alex on 14-6-15.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VJNYPOJOFilter : NSObject

@property(strong,nonatomic) NSString* title;
@property(strong,nonatomic) UIImage* cover;

- (id)initWithTitle:(NSString *)title AndCoverPath:(NSString *)coverPath;

@end
