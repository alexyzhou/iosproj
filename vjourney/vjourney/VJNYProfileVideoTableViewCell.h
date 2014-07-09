//
//  VJNYProfileVideoTableViewCell.h
//  vjourney
//
//  Created by alex on 14-6-24.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VJNYUserProfileViewController.h"

@class VJNYPOJOVideo;

@interface VJNYProfileVideoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *videoPlayerContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *videoCoverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayButtonImageView;

@property (strong, nonatomic) MPMoviePlayerController* videoPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *channelCoverImageView;
@property (weak, nonatomic) IBOutlet UIButton *channelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *videoLikeButton;
- (IBAction)videoLikeAction:(id)sender;
- (IBAction)deleteVideoAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *videoDeleteButton;
- (IBAction)enterChannelAction:(id)sender;

@property (strong,nonatomic) id<VJNYUserProfileVideoHandleDelegate> delegate;
@property (strong,nonatomic) NSNumber* videoId;
@property (strong,nonatomic) NSNumber* channelId;

//Custom Method
- (BOOL)startPlayOrStopVideoWithURL:(NSURL*)url;
- (void)stopPlayVideo;

@end
