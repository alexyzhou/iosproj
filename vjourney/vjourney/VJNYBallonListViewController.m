//
//  VJNYBallonListViewController.m
//  vjourney
//
//  Created by alex on 14-6-22.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYBallonListViewController.h"
#import "VJNYVideoThumbnailViewCell.h"
#import "VJNYUtilities.h"
#import "VJNYPOJOWhisper.h"
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

@synthesize whisper=_whisper;

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
    
    // Set up variables
    _ballonArray = [NSMutableArray array];
    _isDragging = false;
    
    // Set up UI
    _cardContainerView.backgroundColor = [UIColor whiteColor];
    _videoPlayButton.alpha = 0.0f;
    [VJNYUtilities addShadowForUIView:_cardContainerView];
    
    if (_whisper != nil) {
        // Add a new Whisper
        [_ballonArray addObject:_whisper];
    }
    
    // Read Ballon From CoreData
    // TODO...
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setOpaque:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setOpaque:NO];
    if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self myMovieFinishedCallback:nil];
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
            VJNYPOJOWhisper* video = [_ballonArray objectAtIndex:_dragVideoIndex];
            [self playVideo:video.url];
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

#pragma mark - Video Playback Handler

- (void)playVideo:(NSString*)url {
    NSLog(@"Video Playback: %@",url);
    
    _videoPlayButton.alpha = 0.0f;
    
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
    
    if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_videoPlayer stop];
        _videoPlayer.contentURL = [NSURL URLWithString:url];
    }
    
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
    
    VJNYPOJOWhisper* whisper = [_ballonArray objectAtIndex:indexPath.row];
    
    [VJNYDataCache loadImage:cell.imageView WithUrl:whisper.coverUrl AndMode:0 AndIdentifier:indexPath AndDelegate:self];
    
    return cell;
}

#pragma mark - Cache Handler
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    NSIndexPath* path = (NSIndexPath*)identifier;
    VJNYVideoThumbnailViewCell* cell = (VJNYVideoThumbnailViewCell*)[self.cardContainerView cellForItemAtIndexPath:path];
    if (mode == 0) {
        cell.imageView.image = data;
    }
}

@end
