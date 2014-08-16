//
//  VJNYChannelReviewCell.m
//  vjourney
//
//  Created by alex on 14-8-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYChannelReviewCell.h"

@implementation VJNYChannelReviewCell

@synthesize channelId=_channelId;
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

- (IBAction)acceptAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(channelAcceptActionWithID:)]) {
        [_delegate channelAcceptActionWithID:_channelId];
    }
}

- (IBAction)rejectAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(channelRejectActionWithID:)]) {
        [_delegate channelRejectActionWithID:_channelId];
    }
}
@end
