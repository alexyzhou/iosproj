//
//  VJNYProfileVideoTableViewCell.m
//  vjourney
//
//  Created by alex on 14-6-24.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYProfileVideoTableViewCell.h"

@implementation VJNYProfileVideoTableViewCell

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

// When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    NSLog(@"video play finished");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
    [_videoPlayer stop];
    _videoCoverImageView.alpha = 1.0f;
    _videoPlayButtonImageView.alpha = 1.0f;
    [_videoPlayer.view removeFromSuperview];
    _videoPlayer = nil;
}

#pragma mark - Custom Methods

- (BOOL)startPlayOrStopVideoWithURL:(NSURL*)url {
    
    if (_videoPlayer != nil && _videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_videoPlayer pause];
        _videoPlayButtonImageView.alpha = 1.0f;
        return false;
    }
    
    _videoCoverImageView.alpha = 0.0f;
    _videoPlayButtonImageView.alpha = 0.0f;
    
    //NSLog(@"Video Playback: %@",url);
    
    if (_videoPlayer == nil) {
        // 1 - Play the video
        _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
        // 2 - Prepare the Param
        _videoPlayer.view.frame = self.videoPlayerContainerView.bounds;
        _videoPlayer.controlStyle = MPMovieControlStyleNone;
        _videoPlayer.repeatMode = MPMovieRepeatModeNone;
        [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
        [self.videoPlayerContainerView insertSubview:_videoPlayer.view atIndex:0];
    }
    
    [_videoPlayer play];
    
    // 4 - Register for the playback finished notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
    
    return true;
}
- (void)stopPlayVideo {
    if (_videoPlayer != nil && _videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self myMovieFinishedCallback:nil];
    }
}

@end
