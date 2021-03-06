//
//  VJNYVideoViewController.m
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoViewController.h"
#import "VJNYUserProfileViewController.h"
#import "VJNYLikedListViewController.h"
#import "VJNYChatViewController.h"
#import "VJNYVideoCardViewCell.h"
#import "VJNYUtilities.h"
#import "VJNYPOJOVideo.h"
#import "VJNYPOJOUser.h"
#import "ASIFormDataRequest.h"

#import <MediaPlayer/MediaPlayer.h>

@interface VJNYVideoViewController ()
{
    NSMutableDictionary *_userData;
    NSMutableArray *_videoData;
    NSDateFormatter *_dateFormatter;
    MPMoviePlayerController *_videoPlayer;
    UIImageView *_dragIndicatorImageView;
    long _dragVideoIndex;
    BOOL _isDragging;
    
    UIActivityIndicatorView* _activityIndicatorView;
    
    NSMutableDictionary* _likeVideoDic;
    
    UIView* _uploadBannerView;
}
- (void)playVideo:(NSString*)url;
- (NSMutableDictionary*)genUserVideoRequestDic;
@end

@implementation VJNYVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Gesture Handler

- (IBAction)tapToPlayOrPauseVideoAction:(UITapGestureRecognizer *)sender {
    
    if (_videoPlayer.contentURL != nil) {
        if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
            [_videoPlayer pause];
            _videoPlayButton.alpha = 1.0f;
        } else {
            [self playVideo:[_videoPlayer.contentURL absoluteString]];
        }
    }
}

- (IBAction)longPressHandler:(id)sender {
    
    if(_longPressRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //if needed do some initial setup or init of views here
        _isDragging = true;
        CGPoint p = [_longPressRecognizer locationInView:self.videoCollectionView];
        
        NSIndexPath *indexPath = [self.videoCollectionView indexPathForItemAtPoint:p];
        if (indexPath == nil){
            NSLog(@"couldn't find index path");
        } else {
            // get the cell at indexPath (the one you long pressed)
            VJNYVideoCardViewCell* cell = (VJNYVideoCardViewCell*)[self.videoCollectionView cellForItemAtIndexPath:indexPath];
            _dragVideoIndex = indexPath.row;
            UIImage* imageToShow = [VJNYUtilities imageWithView7:cell];
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
            [imageView setCenter:[_longPressRecognizer locationInView:self.view]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView setClipsToBounds:YES];
            imageView.layer.shadowOffset = CGSizeMake(3.0f, 2.0f);
            imageView.layer.shadowRadius = 3.0f;
            imageView.layer.shadowOpacity = 0.8f;
            imageView.layer.masksToBounds = NO;
            imageView.image = imageToShow;
            _dragIndicatorImageView = imageView;
            [self.view addSubview:_dragIndicatorImageView];
            _dragIndicatorImageView.alpha = 0.0f;
            [UIView animateWithDuration:0.1f animations:^(void){
                _dragIndicatorImageView.alpha = 1.0f;
            }];
        }
    }
    else if(_longPressRecognizer.state == UIGestureRecognizerStateChanged)
    {
        //move your views here.
        if (_isDragging) {
            CGPoint dragPoint = [_longPressRecognizer locationInView:self.view];
            [_dragIndicatorImageView setCenter:dragPoint];
            if ([self.videoMaskView pointInside:dragPoint withEvent:nil]) {
                self.videoMaskView.backgroundColor = [UIColor grayColor];
            } else if ([self.videoMaskView.backgroundColor isEqual:[UIColor grayColor]]){
                self.videoMaskView.backgroundColor = [UIColor clearColor];
            }
        }
    }
    else if(_longPressRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //else do cleanup
        _isDragging = false;
        if ([self.videoMaskView pointInside:[_longPressRecognizer locationInView:self.view] withEvent:nil]) {
            self.videoMaskView.backgroundColor = [UIColor clearColor];
            VJNYPOJOVideo* video = [_videoData objectAtIndex:_dragVideoIndex];
            [self playVideo:video.url];
            
            
            VJNYPOJOUser* user = [_userData objectForKey:video.userId];
            [VJNYDataCache loadImageForButton:_videoUserAvatarButton WithUrl:user.avatarUrl AndMode:2 AndIdentifier:[NSNumber numberWithLong:_dragVideoIndex] AndDelegate:self];
            [_videoUserAvatarButton setEnabled:YES];
            [_chatButton setEnabled:YES];
            [_seeLikedButton setEnabled:YES];
            
            if (_videoUserAvatarButton.hidden == YES) {
                [_videoUserAvatarButton setHidden:NO];
                [_chatButton setHidden:NO];
                [_seeLikedButton setHidden:NO];
                [_likeButton setHidden:NO];
            }
            
            // Http Request
            NSMutableDictionary* dic = [self genUserVideoRequestDic];
            [dic setObject:[[NSNumber numberWithBool:YES] stringValue] forKey:@"watch"];
            [VJNYHTTPHelper sendJSONRequest:@"video/watch" WithParameters:dic AndDelegate:self];
            
            NSNumber* likedValue = [_likeVideoDic objectForKey:video.vid];
            
            if (likedValue == nil) {
                [self.likeButton setEnabled:NO];
                [VJNYHTTPHelper sendJSONRequest:@"video/isLike" WithParameters:[self genUserVideoRequestDic] AndDelegate:self];
            } else {
                [self.likeButton setEnabled:YES];
                [self.likeButton setSelected:[likedValue boolValue]];
            }
        }
        [UIView animateWithDuration:0.2f animations:^(void){
            _dragIndicatorImageView.alpha = 0.0f;
        }completion:^(BOOL finished) {
            [_dragIndicatorImageView removeFromSuperview];
            _dragIndicatorImageView = nil;
        }];
        return;
    }
}

#pragma mark - Video Playback Handler

- (void)playVideo:(NSString*)url {
    NSLog(@"Video Playback: %@",url);
    
    _videoPlayButton.alpha = 0.0f;
    
    if (_videoPlayer == nil) {
        // 1 - Play the video
        _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
        // 2 - Prepare the Param
        _videoPlayer.view.frame = self.videoPlayerView.bounds;
        _videoPlayer.controlStyle = MPMovieControlStyleNone;
        _videoPlayer.repeatMode = MPMovieRepeatModeOne;
        [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
        [self.videoPlayerView addSubview:_videoPlayer.view];
        //[self.videoPlayerView insertSubview:_videoPlayer.view atIndex:0];
        //[self.videoPlayerView insertSubview:_videoPlayer.view belowSubview:_videoPlayButton];
        [self.videoPlayerView bringSubviewToFront:_videoPlayButton];
    }
    
    if (![[_videoPlayer.contentURL absoluteString] isEqual:url]) {
        [_videoPlayer stop];
        _videoPlayer.contentURL = [NSURL URLWithString:url];
    }
    _videoPlayButton.alpha = 0.0f;
    
    [_videoPlayer play];
    
    // 4 - Register for the playback finished notification
    /*[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];*/
}

// When the movie is done, release the controller.
/*-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    NSLog(@"video play finished");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
    //_videoPlayer = nil;
}*/

#pragma mark - View Main

-(void)initWithChannel:(VJNYPOJOChannel *)channel andIsFollow:(int)follow {
    _channel = channel;
    _isFollow = follow;
}

- (void)updateUITextViewForCenter:(UITextView*)object {
    
    UITextView *mTrasView = object;
    
    CGRect textRect = [object.text boundingRectWithSize:CGSizeMake(137.0f, CGFLOAT_MAX)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:object.font}
                                                                context:nil];
    
    CGFloat topCorrect = (250.0f - textRect.size.height);
    
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);
    
    mTrasView.contentOffset = (CGPoint){.x =0, .y = -topCorrect/2};
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [VJNYUtilities addRoundMaskForUIView:_creatorAvatarImageView];
    [VJNYDataCache loadImage:_channelCoverImageView WithUrl:_channel.coverUrl AndMode:4 AndIdentifier:[NSIndexPath indexPathForRow:0 inSection:0] AndDelegate:self];
    
    _videoUserAvatarButton.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    [VJNYUtilities addRoundMaskForUIView:_videoUserAvatarButton];
    [_videoUserAvatarButton setEnabled:NO];
    [_chatButton setEnabled:NO];
    [_seeLikedButton setEnabled:NO];
    
    [_videoUserAvatarButton setHidden:YES];
    [_chatButton setHidden:YES];
    [_seeLikedButton setHidden:YES];
    [_likeButton setHidden:YES];
    
    _uploadBannerView = nil;
    
    self.title = _channel.name;
    _isDragging = false;
    _dragVideoIndex = -1;
    [_likeButton setEnabled:NO];
    _likeVideoDic = [NSMutableDictionary dictionary];
    
    _activityIndicatorView = nil;
    _videoPlayButton.alpha = 0.0f;
    _videoCollectionView.backgroundColor = [UIColor clearColor];
    _videoMaskView.alpha = 0.4f;
    [VJNYUtilities addShadowForUIView:_videoCollectionView];
    
    // 1.初始化数据
    _videoData = [NSMutableArray array];
    _userData = [NSMutableDictionary dictionary];
    
    //self.videoCollectionView.backgroundColor = [UIColor blackColor];
    //self.videoCollectionView.contentInset = UIEdgeInsetsMake(5.0f, 4.0f, 5.0f, 4.0f);
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"HH:mm,yyyy-MM-dd"];
    
    [VJNYHTTPHelper getJSONRequest:[NSString stringWithFormat:@"video/latest/channel/%zd",[_channel.cid intValue]] WithParameters:nil AndDelegate:self];
    
    if (_isFollow == -1) {
        // we need to contact the server
        [self switchToProgressIndicatorForRightButton];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
        [dic setObject:[_channel.cid stringValue] forKey:@"channelId"];
        [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
        
        [VJNYHTTPHelper sendJSONRequest:@"channel/isFollow" WithParameters:dic AndDelegate:self];
        
    } else if (_isFollow == 1) {
        [self switchToUploadButtonForRightButton];
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(clickToUploadAction:)];
    }
    
    
    // Fetch Data
    // User Info
    [VJNYHTTPHelper getJSONRequest:[@"user/info/" stringByAppendingString:[_channel.creatorUserId stringValue]] WithParameters:nil AndDelegate:self];
    // Video Count
    [VJNYHTTPHelper getJSONRequest:[@"video/countByUser/" stringByAppendingString:[_channel.creatorUserId stringValue]] WithParameters:nil AndDelegate:self];
    
    _channelDescriptionLabel.text = _channel.description;
    _channelDescriptionLabel.alpha = 0.0f;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationController.navigationBar.translucent = NO;
}
-(void)viewDidAppear:(BOOL)animated {
    [self updateUITextViewForCenter:_channelDescriptionLabel];
    [UIView animateWithDuration:0.1f animations:^{
        _channelDescriptionLabel.alpha = 1.0f;
    }];
    
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //self.navigationController.navigationBar.translucent = YES;
    if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_videoPlayer stop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Configuration

- (void)switchToProgressIndicatorForRightButton {
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    [self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicatorView];
    [_activityIndicatorView startAnimating];
}

- (void)switchToFollowButtonForRightButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"button_follow.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(clickToFollowAction:)];
}

- (void)switchToUploadButtonForRightButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"button_camera.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(clickToUploadAction:)];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:[VJNYUtilities segueVideoCapturePage]]) {
        UINavigationController* controller = segue.destinationViewController;
        VJNYVideoCaptureViewController* videoController = [controller.viewControllers objectAtIndex:0];
        videoController.delegate = sender;
        videoController.captureMode = GeneralMode;
    } else if ([segue.identifier isEqual:[VJNYUtilities segueLikedListPage]]) {
        VJNYLikedListViewController* controller = segue.destinationViewController;
        controller.videoId = sender;
    }
}


#pragma mark - UICollectionView Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_videoData count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VJNYVideoCardViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VJNYUtilities videoCellIdentifier] forIndexPath:indexPath];
    
    VJNYPOJOVideo* video = [_videoData objectAtIndex:indexPath.row];
    VJNYPOJOUser* ownerUser = [_userData objectForKey:[video userId]];
    
    cell.nameView.text = ownerUser.name;
    cell.timeView.text = [VJNYUtilities formatDataString:video.time];
    cell.descriptionView.text = video.description;
    
    cell.likeAndWatchView.text = [NSString stringWithFormat:@"%@/%@",[video.like stringValue],[video.watched stringValue]];
    
    [VJNYDataCache loadImage:cell.avatarView WithUrl:ownerUser.avatarUrl AndMode:0 AndIdentifier:indexPath AndDelegate:self];
    [VJNYDataCache loadImage:cell.coverView WithUrl:video.coverUrl AndMode:1 AndIdentifier:indexPath AndDelegate:self];
    
    //cell.contentView.layer.borderColor = [[UIColor blueColor] CGColor];//[[UIColor colorWithRed:1 green: 0.6 blue:0.8 alpha:1] CGColor];
    //cell.contentView.layer.borderWidth = 1.0f;
    
    //cell.layer.shadowOffset = CGSizeMake(3.0f, 2.0f);
    //cell.layer.shadowRadius = 3.0f;
    //cell.layer.shadowOpacity = 0.8f;
    //cell.layer.masksToBounds = NO;
    
    return cell;
}

/*-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(140, collectionView.frame.size.height-10);
}*/

#pragma mark - Custom Methods

- (NSMutableDictionary*)genUserVideoRequestDic {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    VJNYPOJOVideo* video = [_videoData objectAtIndex:_dragVideoIndex];
    [dic setObject:[video.vid stringValue] forKey:@"videoId"];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    return dic;
}

#pragma mark - Cache Handler
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    
    if (mode < 2) {
        NSIndexPath* path = (NSIndexPath*)identifier;
        
        VJNYVideoCardViewCell* cell = (VJNYVideoCardViewCell*)[self.videoCollectionView cellForItemAtIndexPath:path];
        if (mode == 0) {
            //avatar
            cell.avatarView.image = data;
        } else if (mode == 1) {
            //cover
            cell.coverView.image = data;
        }
    } else if (mode == 2) {
        long originIndex = [identifier longValue];
        if (originIndex == _dragVideoIndex) {
            // we are still in the same video
            [_videoUserAvatarButton setBackgroundImage:data forState:UIControlStateNormal];
        }
    } else if (mode == 3) {
        _creatorAvatarImageView.image = data;
    } else if (mode == 4) {
        _channelCoverImageView.image = data;
    }
}

#pragma mark - Video Upload Delegate

- (void) videoReadyForUploadWithVideoData:(NSData*)videoData AndCoverData:(NSData*)coverData AndPostValue:(NSMutableDictionary*)dic AndShareOptions:(NSMutableDictionary *)options {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[options objectForKey:@"weibo"] boolValue]) {
            [VJNYHTTPHelper sendShareToSocialPlatformWithContent:[dic objectForKey:@"description"] andImage:coverData AndType:ShareTypeSinaWeibo];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[options objectForKey:@"fb"] boolValue]) {
            [VJNYHTTPHelper sendShareToSocialPlatformWithContent:[dic objectForKey:@"description"] andImage:coverData AndType:ShareTypeFacebook];
        }
    });
    
    
    //[VJNYUtilities showProgressAlertViewToView:self.view];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:@"add/video"]];
    
    // Success
    [request addData:videoData withFileName:@"test.mov" andContentType:@"video/quicktime" forKey:@"file"];
    [request addData:coverData withFileName:@"test.jpg" andContentType:@"image/jpeg" forKey:@"cover"];
    //[request setData:filedata forKey:@"file"];
    //[request setPostValue:@"test.mov" forKey:@"fileName"];
    
    
    [dic setObject:[_channel.cid stringValue] forKey:@"channelId"];
    [dic setObject:[[NSNumber numberWithUnsignedInteger:videoData.length] stringValue] forKey:@"videoLength"];
    [dic setObject:[[NSNumber numberWithUnsignedInteger:coverData.length] stringValue] forKey:@"coverLength"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    
    [request addPostValue:jsonString forKey:@"description"];
    
    [request setDelegate:self];
    [request startAsynchronous];
    
    [request setUploadProgressDelegate:self];
    
    
    // Set Upload Banner
    _uploadBannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    [_uploadBannerView setBackgroundColor:[UIColor blueColor]];
    [_uploadBannerView setAlpha:0.5f];
    [self.navigationController.view addSubview:_uploadBannerView];
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (void)setProgress:(float)newProgress {
    NSLog(@"%f",newProgress);
    _uploadBannerView.frame = CGRectMake(0, 0, 320.0f*newProgress, 20);
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"videoAndUser/Latest"]) {
        if (result.result == Success) {
            for (NSArray* arr in result.response) {
                VJNYPOJOUser* user = [arr objectAtIndex:0];
                if ([_userData objectForKey:user.uid]==nil) {
                    [_userData setObject:user forKey:user.uid];
                }
                [_videoData addObject:[arr objectAtIndex:1]];
            }
            [self.videoCollectionView reloadData];
        }
    } else if ([result.action isEqualToString:@"channel/IsFollow"]) {
        if (result.result == Success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_activityIndicatorView stopAnimating];
                
                if ([result.response boolValue] == true) {
                    [self switchToUploadButtonForRightButton];
                    _isFollow = 1;
                } else {
                    [self switchToFollowButtonForRightButton];
                    _isFollow = 0;
                }
            });
        }
    } else if ([result.action isEqualToString:@"channel/Follow"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityIndicatorView stopAnimating];
            
            if (result.result == Success) {
                [self switchToUploadButtonForRightButton];
                _isFollow = 1;
            } else {
                [self switchToFollowButtonForRightButton];
                _isFollow = 0;
            }
        });
    } else if ([result.action isEqualToString:@"add/video"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[VJNYUtilities dismissProgressAlertViewFromView:self.view];
            if (result.result == Success) {
                //[VJNYUtilities showAlert:@"Success" andContent:@"Upload Succeed!"];
                [UIView animateWithDuration:0.5f animations:^{
                    [_uploadBannerView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [_uploadBannerView removeFromSuperview];
                    _uploadBannerView = nil;
                    [self.navigationItem.rightBarButtonItem setEnabled:YES];
                }];
#pragma mark - TODO
                [_videoData removeAllObjects];
                [_userData removeAllObjects];
                [VJNYHTTPHelper getJSONRequest:[NSString stringWithFormat:@"video/latest/channel/%zd",[_channel.cid intValue]] WithParameters:nil AndDelegate:self];
            } else {
                [VJNYUtilities showAlertWithNoTitle:[NSString stringWithFormat:@"Upload Failed!, Reason:%d",result.result]];
            }
        });
    } else if ([result.action isEqualToString:@"video/IsLike"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.result == Success) {
                NSNumber* video_id = [result.response objectForKey:@"videoId"];
                NSNumber* likedResult = [result.response objectForKey:@"result"];
                [_likeVideoDic setObject:likedResult forKey:video_id];
                
                VJNYPOJOVideo* video = [_videoData objectAtIndex:_dragVideoIndex];
                if ([video.vid isEqualToNumber:video_id]) {
                    [_likeButton setEnabled:YES];
                    [_likeButton setSelected:[likedResult boolValue]];
                }
            }
        });
    } else if ([result.action isEqualToString:@"user/Info"]) {
        
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if (result.result == Success) {
                 VJNYPOJOUser* user = result.response;
                 _creatorNameLabel.text = user.name;
                 _creatorDescriptionLabel.text = user.description;
                 [VJNYDataCache loadImage:_creatorAvatarImageView WithUrl:user.avatarUrl AndMode:3 AndIdentifier:[NSIndexPath indexPathForRow:0 inSection:0] AndDelegate:self];
             }
             
         });
        
    } else if ([result.action isEqualToString:@"video/CountByUser"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (result.result == Success) {
                NSNumber* _storyCount = [result.response objectForKey:@"count"];
                NSNumber* _totalLike = [result.response objectForKey:@"like_count"];
                
                if (_storyCount != nil) {
                    _creatorVideoCountLabel.text = [_storyCount stringValue];
                } else {
                    _creatorVideoCountLabel.text = @"0";
                }
                if (_totalLike != nil) {
                    _creatorLikeCountLabel.text = [_totalLike stringValue];
                } else {
                    _creatorLikeCountLabel.text = @"0";
                }
                
            }
            
        });
    }
    
    // 当以二进制形式读取返回内容时用这个方法
    //NSData *responseData = [request responseData];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

#pragma mark - Custom Button Events

- (void)clickToFollowAction:(UIBarButtonItem *)sender {
    
    [self switchToProgressIndicatorForRightButton];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    [dic setObject:[_channel.cid stringValue] forKey:@"channelId"];
    
    [VJNYHTTPHelper sendJSONRequest:@"channel/follow" WithParameters:dic AndDelegate:self];
}
- (void)clickToUploadAction:(UIBarButtonItem *)sender {
    
    [self performSegueWithIdentifier:[VJNYUtilities segueVideoCapturePage] sender:self];
    
}

- (IBAction)clickToLikeVideoAction:(UIButton*)sender {
    if (_dragVideoIndex != -1) {
        if (sender.selected == NO) {
            [sender setSelected:YES];
        } else {
            [sender setSelected:NO];
        }
        NSMutableDictionary* dic = [self genUserVideoRequestDic];
        [dic setObject:[[NSNumber numberWithBool:sender.selected] stringValue] forKey:@"like"];
        [VJNYHTTPHelper sendJSONRequest:@"video/like" WithParameters:dic AndDelegate:self];
        VJNYPOJOVideo* video = [_videoData objectAtIndex:_dragVideoIndex];
        [_likeVideoDic setObject:[NSNumber numberWithBool:sender.selected] forKey:video.vid];
    }
}

- (IBAction)clickToChatAction:(id)sender {
    
    if (_dragVideoIndex != -1) {
        
        VJNYChatViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardChatDetailPage]];
        
        VJNYVideoCardViewCell* cell = (VJNYVideoCardViewCell*)[self.videoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_dragVideoIndex inSection:0]];
        VJNYPOJOVideo* video = [_videoData objectAtIndex:_dragVideoIndex];
        VJNYPOJOUser* user = [_userData objectForKey:video.userId];
        
        controller.target_avatar = cell.avatarView.image;
        controller.target_id = user.uid;
        controller.target_name = user.name;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

- (IBAction)clickToSeeWatchedAction:(id)sender {
    
    if (_dragVideoIndex != -1) {
        VJNYPOJOVideo* video = [_videoData objectAtIndex:_dragVideoIndex];
        [self performSegueWithIdentifier:[VJNYUtilities segueLikedListPage] sender:video.vid];
    }
    
}

- (IBAction)clickToSeeUserProfileAction:(id)sender {
    
    if (_dragVideoIndex != -1) {
        VJNYPOJOVideo* video = [_videoData objectAtIndex:_dragVideoIndex];
        VJNYPOJOUser* user = [_userData objectForKey:video.userId];
        
        UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardUserProfilePage]];
        
        VJNYUserProfileViewController* profileController = [controller.viewControllers  objectAtIndex:0];
        profileController.userId = user.uid;
        profileController.pushed = YES;
        
        [self presentViewController:controller animated:YES completion:nil];
        //[self.navigationController pushViewController:controller animated:YES];
    }

}

@end
