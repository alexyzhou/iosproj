//
//  VJNYVideoViewController.h
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYDataCache.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOChannel.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYHTTPResultCode.h"
#import "VJNYVideoCaptureViewController.h"

@interface VJNYVideoViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate,VJNYVideoUploadDelegate,ASIProgressDelegate> {
    VJNYPOJOChannel* _channel;
    int _isFollow;
}
@property (weak, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *videoUserAvatarButton;
@property (weak, nonatomic) IBOutlet UIView *videoMaskView;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *seeLikedButton;
@property (weak, nonatomic) IBOutlet UIImageView *creatorAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorVideoCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorLikeCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *channelDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *channelCoverImageView;

- (IBAction)tapToPlayOrPauseVideoAction:(UITapGestureRecognizer *)sender;

- (IBAction)longPressHandler:(id)sender;
- (void)clickToFollowAction:(UIBarButtonItem *)sender;
- (void)clickToUploadAction:(UIBarButtonItem *)sender;
- (IBAction)clickToLikeVideoAction:(UIButton*)sender;
- (IBAction)clickToChatAction:(id)sender;
- (IBAction)clickToSeeWatchedAction:(id)sender;
- (IBAction)clickToSeeUserProfileAction:(id)sender;


//-(void)initWithChannelID:(NSNumber*)channelID andName:(NSString*)name andIsFollow:(int)follow;
-(void)initWithChannel:(VJNYPOJOChannel*)channel andIsFollow:(int)follow;

@end
