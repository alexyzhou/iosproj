//
//  VJNYProfileHeadTableViewCell.m
//  vjourney
//
//  Created by alex on 14-6-24.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYProfileHeadTableViewCell.h"

@implementation VJNYProfileHeadTableViewCell

@synthesize videoPlayer=_videoPlayer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Custom Methods

- (void)startPlayVideoWithURL:(NSURL*)url {

    if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        return;
    }
    
    if (_videoPlayer == nil) {
        // 1 - Play the video
        _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
        // 2 - Prepare the Param
        _videoPlayer.view.frame = self.videoPlayerContainerView.bounds;
        _videoPlayer.controlStyle = MPMovieControlStyleNone;
        _videoPlayer.repeatMode = MPMovieRepeatModeOne;
        [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
        [self.videoPlayerContainerView addSubview:_videoPlayer.view];
    }
    
    [_videoPlayer play];
}
- (void)stopPlayVideo {
    if (_videoPlayer != nil && _videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_videoPlayer pause];
    }
}

@end
