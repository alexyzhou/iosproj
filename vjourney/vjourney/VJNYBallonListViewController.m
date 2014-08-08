//
//  VJNYBallonListViewController.m
//  vjourney
//
//  Created by alex on 14-6-22.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYBallonListViewController.h"
#import "VJNYVideoThumbnailViewCell.h"
#import "VJNYUserProfileViewController.h"
#import "VJNYChatViewController.h"
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJDMVoodoo.h"
#import "VJDMModel.h"
#import "VJDMUserAvatar.h"
#import "VJNYPOJOHttpResult.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VJNYBallonListViewController () {
    MPMoviePlayerController* _videoPlayer;
    NSMutableArray* _ballonArray;
    
    UIImageView *_dragIndicatorImageView;
    long _dragVideoIndex;
    BOOL _isDragging;
}

@end

@implementation VJNYBallonListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [VJNYUtilities initBgImageForNaviBarWithTabView:self.navigationController];
    
    self.userAvatarButtonView.enabled = NO;
    self.chatButtonView.enabled = NO;
    self.sendBackButtonView.enabled = NO;
    
    self.userAvatarButtonView.hidden = YES;
    self.chatButtonView.hidden= YES;
    self.sendBackButtonView.hidden = YES;
    
    // Set up variables
    _ballonArray = [NSMutableArray array];
    _isDragging = false;
    
    // Set up UI
    //_cardContainerView.backgroundColor = [UIColor whiteColor];
    _videoPlayButton.alpha = 0.0f;
    [VJNYUtilities addShadowForUIView:_cardContainerView];
    
    _ballonArray = [[[VJDMModel sharedInstance] getVoodooList] mutableCopy];
    
    if (self.navigationController.viewControllers[0]==self) {
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToShowSliderAction:)];
        [self.videoMaskView addGestureRecognizer:panGesture];
        [self.videoMaskView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissSliderAction:)];
        [self.videoMaskView addGestureRecognizer:tapGesture];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self myMovieFinishedCallback:nil];
    }
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.viewControllers[0] == self) {
        [self.navigationController.navigationBar setHidden:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - longPressHandler

- (IBAction)longPressHandler:(UILongPressGestureRecognizer*)sender {
    
    UILongPressGestureRecognizer* _longPressRecognizer = sender;
    
    if(_longPressRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //if needed do some initial setup or init of views here
        _isDragging = true;
        CGPoint p = [_longPressRecognizer locationInView:self.cardContainerView];
        
        NSIndexPath *indexPath = [self.cardContainerView indexPathForItemAtPoint:p];
        if (indexPath == nil){
            NSLog(@"couldn't find index path");
        } else {
            // get the cell at indexPath (the one you long pressed)
            VJNYVideoThumbnailViewCell* cell = (VJNYVideoThumbnailViewCell*)[self.cardContainerView cellForItemAtIndexPath:indexPath];
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
            VJDMVoodoo* video = [_ballonArray objectAtIndex:_dragVideoIndex];
            [self playVideo:video.url];
            
            _userAvatarButtonView.enabled = YES;
            _chatButtonView.enabled = YES;
            _sendBackButtonView.enabled = YES;
            
            self.userAvatarButtonView.hidden = NO;
            self.chatButtonView.hidden= NO;
            self.sendBackButtonView.hidden = NO;
            
            VJDMUserAvatar* avatar = (VJDMUserAvatar*)[[VJDMModel sharedInstance] getUserAvatarByUserID:video.userId];
            
            if (avatar == nil) {
                [VJNYHTTPHelper getJSONRequest:[@"user/avatarUrl/" stringByAppendingString:[video.userId stringValue]] WithParameters:nil AndDelegate:self];
            } else {
                [VJNYDataCache loadImageForButton:_userAvatarButtonView WithUrl:avatar.avatarUrl AndMode:0 AndIdentifier:video.userId AndDelegate:self];
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

- (IBAction)tapToPlayAction:(UITapGestureRecognizer *)sender {
    if (_videoPlayer.contentURL != nil) {
        if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
            [_videoPlayer pause];
            _videoPlayButton.alpha = 1.0f;
        } else {
            [self playVideo:[_videoPlayer.contentURL absoluteString]];
        }
    }
}



- (IBAction)panToDragVideoCardAction:(UIPanGestureRecognizer *)sender {
    
    UIPanGestureRecognizer* gesture = sender;
    CGPoint translation = [gesture translationInView:self.view];
    [gesture setTranslation:CGPointZero inView:self.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        /*
         [self.rightSlider setAlpha:1.0f];
         [_topMaskView setAlpha:1.0f];
         [_bottomMaskView setAlpha:1.0f];
         */
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint originCenter = self.cardContainerView.center;
        originCenter.y += translation.y;
        
        if (originCenter.y + self.cardContainerView.frame.size.height/2 < self.view.frame.size.height) {
            originCenter.y -= translation.y/3.0f*2.0f;
        } else if (originCenter.y > 64.0f + self.videoMaskView.frame.size.height + 30 + self.cardContainerView.frame.size.height/2) {
            originCenter.y -= translation.y;
        }
        
        self.cardContainerView.center = originCenter;
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        if (self.cardContainerView.frame.origin.y + self.cardContainerView.frame.size.height/4.0f*3.0f < self.view.frame.size.height) {
            [UIView animateWithDuration:0.2f animations:^{
                self.cardContainerView.center = CGPointMake(self.cardContainerView.center.x, self.view.frame.size.height - self.cardContainerView.frame.size.height/2);
            }];
        } else {
            [UIView animateWithDuration:0.2f animations:^{
                self.cardContainerView.center = CGPointMake(self.cardContainerView.center.x, 64.0f + self.videoMaskView.frame.size.height + 30 + self.cardContainerView.frame.size.height/2);
            }];
        }
        
    }
    
}

- (IBAction)tapToViewUserInfoAction:(id)sender {
    
    if (_dragVideoIndex != -1) {
        VJDMVoodoo* video = [_ballonArray objectAtIndex:_dragVideoIndex];
        
        UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardUserProfilePage]];
        
        VJNYUserProfileViewController* profileController = [controller.viewControllers  objectAtIndex:0];
        profileController.userId = video.userId;
        profileController.pushed = YES;
        
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    
}

- (IBAction)tapToChatAction:(id)sender {
    
    if (_dragVideoIndex != -1) {
        
        VJNYChatViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardChatDetailPage]];
        
        VJDMVoodoo* video = [_ballonArray objectAtIndex:_dragVideoIndex];
        
        controller.target_avatar = [self.userAvatarButtonView imageForState:UIControlStateNormal];
        controller.target_id = video.userId;
        controller.target_name = video.userName;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

- (IBAction)tapToSendbackVoodooAction:(id)sender {
    
    if (_dragVideoIndex != -1) {
        
        VJDMVoodoo* video = [_ballonArray objectAtIndex:_dragVideoIndex];
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
        [dic setObject:[video.vid stringValue] forKey:@"whisperId"];
        [VJNYHTTPHelper sendJSONRequest:@"whisper/return" WithParameters:dic AndDelegate:self];
        
        [[VJDMModel sharedInstance] removeManagedObject:video];
        [[VJDMModel sharedInstance] saveChanges];
        
        [_ballonArray removeObjectAtIndex:_dragVideoIndex];
        [_cardContainerView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_dragVideoIndex inSection:0]]];
        
        [_videoPlayer stop];
        _videoPlayer.contentURL = nil;
        [self myMovieFinishedCallback:nil];
        
        _userAvatarButtonView.enabled = NO;
        _chatButtonView.enabled = NO;
        _sendBackButtonView.enabled = NO;
        
        _dragVideoIndex = -1;
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self.view];
    BOOL isVerticalPan = (fabsf(translation.x) < fabsf(translation.y));
    return isVerticalPan && !_isDragging && (self.cardContainerView.frame.origin.y+self.cardContainerView.frame.size.height > self.view.frame.size.height);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Video Playback Handler

- (void)playVideo:(NSString*)url {
    NSLog(@"Video Playback: %@",url);
    
    if (_videoPlayer == nil) {
        // 1 - Play the video
        _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
        // 2 - Prepare the Param
        _videoPlayer.view.frame = self.videoPlayerContainerView.bounds;
        _videoPlayer.controlStyle = MPMovieControlStyleNone;
        _videoPlayer.repeatMode = MPMovieRepeatModeNone;
        [_videoPlayer setScalingMode:MPMovieScalingModeFill];
        [self.videoPlayerContainerView addSubview:_videoPlayer.view];
        [self.videoPlayerContainerView bringSubviewToFront:_videoPlayButton];
    }
    
    if (![[_videoPlayer.contentURL absoluteString] isEqual:url]) {
        [_videoPlayer stop];
        _videoPlayer.contentURL = [NSURL URLWithString:url];
    }
    _videoPlayButton.alpha = 0.0f;
    
    [_videoPlayer play];
    
    // 4 - Register for the playback finished notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
     name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
}

-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    NSLog(@"Finished Playback!");
    self.videoPlayButton.alpha = 1.0f;
    MPMoviePlayerController* theMovie = _videoPlayer;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UICollectionView Handler


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_ballonArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VJNYVideoThumbnailViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VJNYUtilities ballonCardCellIdentifier] forIndexPath:indexPath];
    cell.delegate = self;
    
    VJDMVoodoo* whisper = [_ballonArray objectAtIndex:indexPath.row];
    
    [VJNYDataCache loadImage:cell.imageView WithUrl:whisper.coverUrl AndMode:0 AndIdentifier:indexPath AndDelegate:self];
    
    return cell;
}

#pragma mark - Cache Handler
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    
    if (mode == 1) {
        VJDMVoodoo* video = [_ballonArray objectAtIndex:_dragVideoIndex];
        if (video.userId == identifier) {
            _userAvatarButtonView.imageView.image = data;
        }
    } else if (mode == 0) {
        NSIndexPath* indexPath = identifier;
        if ([[self.cardContainerView indexPathsForVisibleItems] containsObject:indexPath]) {
            VJNYVideoThumbnailViewCell* cell = (VJNYVideoThumbnailViewCell*)[self.cardContainerView cellForItemAtIndexPath:indexPath];
            cell.imageView.image = [data imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }

}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"user/AvatarUrl"]) {
        if (result.result == Success) {
            //
            VJDMUserAvatar* avatar = result.response;
            
            if (avatar != nil) {
                VJDMVoodoo* video = [_ballonArray objectAtIndex:_dragVideoIndex];
                if ([video.userId isEqualToNumber:avatar.userId]) {
                    [VJNYDataCache loadImageForButton:_userAvatarButtonView WithUrl:avatar.avatarUrl AndMode:0 AndIdentifier:avatar.userId AndDelegate:self];
                }
            }
        }
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

#pragma mark - Custom Methods

- (IBAction)showSliderAction:(id)sender {
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTriggerSliderAction:)]) {
        [_slideDelegate subViewDidTriggerSliderAction:self.view];
    }
}

- (IBAction)panToShowSliderAction:(UIPanGestureRecognizer *)sender {
    
    UIPanGestureRecognizer* gesture = sender;
    CGPoint translation = [gesture translationInView:self.view];
    [gesture setTranslation:CGPointZero inView:self.view];
    
    //NSLog(@"PanGesture:x-%f,y-%f",translation.x,translation.y);
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidDragSliderAction:AndGestureState:AndView:)]) {
        [_slideDelegate subViewDidDragSliderAction:translation AndGestureState:gesture.state AndView:self.view];
    }
    
}

- (IBAction)tapToDismissSliderAction:(UITapGestureRecognizer *)sender {
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTapOutsideSlider:)]) {
        [_slideDelegate subViewDidTapOutsideSlider:self.view];
    }
    
}

- (void)tapToDeleteBallonWithTableViewCell:(UICollectionViewCell *)cell {
    
    NSIndexPath* path = [_cardContainerView indexPathForCell:cell];
    
    VJDMVoodoo* video = [_ballonArray objectAtIndex:path.row];
    
    [[VJDMModel sharedInstance] removeManagedObject:video];
    [[VJDMModel sharedInstance] saveChanges];
    
    [_ballonArray removeObjectAtIndex:path.row];
    [_cardContainerView deleteItemsAtIndexPaths:@[path]];
    
    [_videoPlayer stop];
    _videoPlayer.contentURL = nil;
    [self myMovieFinishedCallback:nil];
    
    _userAvatarButtonView.enabled = NO;
    _chatButtonView.enabled = NO;
    _sendBackButtonView.enabled = NO;
    
    _dragVideoIndex = -1;
}

@end
