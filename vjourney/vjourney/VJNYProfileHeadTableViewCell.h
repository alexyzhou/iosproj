//
//  VJNYProfileHeadTableViewCell.h
//  vjourney
//
//  Created by alex on 14-6-24.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VJNYProfileHeadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *videoPlayerContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *userCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *storyCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backButtonImageView;

@property (strong, nonatomic) MPMoviePlayerController* videoPlayer;

//Customs
- (void)startPlayVideoWithURL:(NSURL*)url;
- (void)stopPlayVideo;

@end
