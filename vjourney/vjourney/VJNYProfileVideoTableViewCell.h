//
//  VJNYProfileVideoTableViewCell.h
//  vjourney
//
//  Created by alex on 14-6-24.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class VJNYPOJOVideo;

@interface VJNYProfileVideoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *videoPlayerContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *videoCoverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayButtonImageView;

@property (strong, nonatomic) MPMoviePlayerController* videoPlayer;

//Custom Method
- (void)startPlayOrStopVideoWithURL:(NSURL*)url;
- (void)stopPlayVideo;

@end
