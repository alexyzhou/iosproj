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
#import "VJNYPOJOHttpResult.h"
#import "VJNYHTTPResultCode.h"
#import "VJNYVideoCaptureViewController.h"

@interface VJNYVideoViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate,VJNYVideoUploadDelegate> {
    NSNumber* _channelID;
    NSString* _channelName;
    int _isFollow;
}
@property (weak, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayButton;
@property (weak, nonatomic) IBOutlet UIImageView *videoUserAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *videoUserNameView;
@property (weak, nonatomic) IBOutlet UIView *videoMaskView;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

- (IBAction)tapToPlayOrPauseVideoAction:(UITapGestureRecognizer *)sender;

- (IBAction)longPressHandler:(id)sender;
- (void)clickToFollowAction:(UIBarButtonItem *)sender;
- (void)clickToUploadAction:(UIBarButtonItem *)sender;
- (IBAction)clickToLikeVideoAction:(UIButton*)sender;
- (IBAction)clickToChatAction:(id)sender;
- (IBAction)clickToSeeWatchedAction:(id)sender;


-(void)initWithChannelID:(NSNumber*)channelID andName:(NSString*)name andIsFollow:(int)follow;

@end
