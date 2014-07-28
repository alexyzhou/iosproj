//
//  VJNYVideoThumbnailViewCell.m
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoThumbnailViewCell.h"

@implementation VJNYVideoThumbnailViewCell

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)deleteVideoAction:(id)sender {
    
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(tapToDeleteBallonWithTableViewCell:)]) {
            [_delegate tapToDeleteBallonWithTableViewCell:self];
        }
    }
    
}
@end
