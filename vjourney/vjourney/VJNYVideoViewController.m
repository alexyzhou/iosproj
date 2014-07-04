//
//  VJNYVideoViewController.m
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoViewController.h"
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
            [UIView animateWithDuration:0.2 animations:^(void){
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
            
            _videoUserAvatarView.alpha = 1.0f;
            _videoUserNameView.alpha = 1.0f;
            
            VJNYPOJOUser* user = [_userData objectForKey:video.userId];
            [VJNYDataCache loadImage:_videoUserAvatarView WithUrl:user.avatarUrl AndMode:2 AndIdentifier:[NSNumber numberWithLong:_dragVideoIndex] AndDelegate:self];
            _videoUserNameView.text = user.name;
            
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
        //[self.videoPlayerView addSubview:_videoPlayer.view];
        [self.videoPlayerView insertSubview:_videoPlayer.view atIndex:0];
        //[self.videoPlayerView bringSubviewToFront:_videoPlayButton];
    }
    
    if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_videoPlayer stop];
        _videoPlayer.contentURL = [NSURL URLWithString:url];
    }
    
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

-(void)initWithChannelID:(NSNumber*)channelID andName:(NSString*)name andIsFollow:(int)follow {
    _channelID = channelID;
    _channelName = name;
    _isFollow = follow;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _channelName;
    _isDragging = false;
    _dragVideoIndex = -1;
    [_likeButton setEnabled:NO];
    _likeVideoDic = [NSMutableDictionary dictionary];
    
    _activityIndicatorView = nil;
    _videoPlayButton.alpha = 0.0f;
    _videoUserAvatarView.alpha = 0.0f;
    _videoUserNameView.alpha = 0.0f;
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
    
    [VJNYHTTPHelper getJSONRequest:[NSString stringWithFormat:@"video/latest/channel/%zd",[_channelID intValue]] WithParameters:nil AndDelegate:self];
    
    if (_isFollow == -1) {
        // we need to contact the server
        [self switchToProgressIndicatorForRightButton];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
        [dic setObject:[_channelID stringValue] forKey:@"channelId"];
        [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
        
        [VJNYHTTPHelper sendJSONRequest:@"channel/isFollow" WithParameters:dic AndDelegate:self];
        
    } else if (_isFollow == 1) {
        [self switchToUploadButtonForRightButton];
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(clickToUploadAction:)];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationController.navigationBar.translucent = NO;
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
    cell.timeView.text = [_dateFormatter stringFromDate:video.time];
    cell.descriptionView.text = video.description;
    
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
            _videoUserAvatarView.image = data;
        }
    }
}

#pragma mark - Video Upload Delegate

- (void) videoReadyForUploadWithVideoData:(NSData*)videoData AndCoverData:(NSData*)coverData AndPostValue:(NSMutableDictionary*)dic {
    
    [VJNYUtilities showProgressAlertViewToView:self.view];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:@"add/video"]];
    
    // Success
    [request addData:videoData withFileName:@"test.mov" andContentType:@"video/quicktime" forKey:@"file"];
    [request addData:coverData withFileName:@"test.jpg" andContentType:@"image/jpeg" forKey:@"cover"];
    //[request setData:filedata forKey:@"file"];
    //[request setPostValue:@"test.mov" forKey:@"fileName"];
    
    
    [dic setObject:[_channelID stringValue] forKey:@"channelId"];
    
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
            [VJNYUtilities dismissProgressAlertViewFromView:self.view];
            if (result.result == Success) {
                [VJNYUtilities showAlert:@"Success" andContent:@"Upload Succeed!"];
#pragma mark - TODO
                [_videoData removeAllObjects];
                [_userData removeAllObjects];
                [VJNYHTTPHelper getJSONRequest:[NSString stringWithFormat:@"video/latest/channel/%zd",[_channelID intValue]] WithParameters:nil AndDelegate:self];
            } else {
                [VJNYUtilities showAlertWithNoTitle:[NSString stringWithFormat:@"Login Failed!, Reason:%d",result.result]];
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
    [dic setObject:[_channelID stringValue] forKey:@"channelId"];
    
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
        controller.target_avatar_url = [VJNYHTTPHelper pathUrlByRemovePrefix:user.avatarUrl];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

- (IBAction)clickToSeeWatchedAction:(id)sender {
}

@end
