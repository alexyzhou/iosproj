//
//  VJNYVideoViewController.m
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoViewController.h"
#import "VJNYVideoCardViewCell.h"
#import "VJNYUtilities.h"
#import "VJNYPOJOVideo.h"
#import "VJNYPOJOUser.h"

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
}
- (void)loadImage:(UIImageView*)cell WithUrl:(NSString*)url AndMode:(int)mode AndIdentifier:(id)identifier;
- (void)playVideo:(NSString*)url;
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

#pragma mark - longPressHandler

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
            if ([self.videoPlayerView pointInside:dragPoint withEvent:nil]) {
                self.videoPlayerView.backgroundColor = [UIColor grayColor];
            } else if ([self.videoPlayerView.backgroundColor isEqual:[UIColor grayColor]]){
                self.videoPlayerView.backgroundColor = [UIColor blackColor];
            }
        }
    }
    else if(_longPressRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //else do cleanup
        _isDragging = false;
        if ([self.videoPlayerView pointInside:[_longPressRecognizer locationInView:self.view] withEvent:nil]) {
            VJNYPOJOVideo* video = [_videoData objectAtIndex:_dragVideoIndex];
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

#pragma mark - Video Playback Handler

- (void)playVideo:(NSString*)url {
    NSLog(@"Video Playback: %@",url);
    
    if (_videoPlayer == nil) {
        // 1 - Play the video
        _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
        // 2 - Prepare the Param
        _videoPlayer.view.frame = self.videoPlayerView.bounds;
        _videoPlayer.controlStyle = MPMovieControlStyleNone;
        _videoPlayer.repeatMode = MPMovieRepeatModeOne;
        [_videoPlayer setScalingMode:MPMovieScalingModeFill];
        [self.videoPlayerView addSubview:_videoPlayer.view];
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

-(void)initWithChannelID:(NSInteger)channelID andName:(NSString*)name {
    _channelID = channelID;
    _channelName = name;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _channelName;
    self.contentScrollView.contentSize = CGSizeMake(320, 504);
    _isDragging = false;
    
    // 1.初始化数据
    _videoData = [NSMutableArray array];
    _userData = [NSMutableDictionary dictionary];
    
    //self.videoCollectionView.backgroundColor = [UIColor blackColor];
    //self.videoCollectionView.contentInset = UIEdgeInsetsMake(5.0f, 4.0f, 5.0f, 4.0f);
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"HH:mm,yyyy-MM-dd"];
    
    [VJNYHTTPHelper getJSONRequest:[NSString stringWithFormat:@"video/latest/%zd",_channelID] WithParameters:nil AndDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    VJNYPOJOUser* ownerUser = [_userData objectForKey:[NSNumber numberWithLong:[video userId]]];
    
    cell.nameView.text = ownerUser.name;
    cell.timeView.text = [_dateFormatter stringFromDate:video.time];
    cell.descriptionView.text = video.description;
    
    [self loadImage:cell.avatarView WithUrl:ownerUser.avatarUrl AndMode:0 AndIdentifier:indexPath];
    [self loadImage:cell.coverView WithUrl:video.coverUrl AndMode:1 AndIdentifier:indexPath];
    
    cell.contentView.layer.borderColor = [[UIColor blueColor] CGColor];//[[UIColor colorWithRed:1 green: 0.6 blue:0.8 alpha:1] CGColor];
    cell.contentView.layer.borderWidth = 1.0f;
    
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

- (void)loadImage:(UIImageView*)cell WithUrl:(NSString*)url AndMode:(int)mode AndIdentifier:(id)identifier {
    
    UIImage* imageData = [[VJNYDataCache instance] dataByURL:url];
    if (imageData == nil) {
        [[VJNYDataCache instance] requestDataByURL:url WithDelegate:self AndIdentifier:identifier AndMode:mode];
        cell.image = nil;
    } else {
        cell.image = imageData;
    }
}

#pragma mark - Cache Handler
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    
    NSIndexPath* path = (NSIndexPath*)identifier;
    
    VJNYVideoCardViewCell* cell = (VJNYVideoCardViewCell*)[self.videoCollectionView cellForItemAtIndexPath:path];
    
    if (mode == 0) {
        //avatar
        cell.avatarView.image = data;
    } else if (mode == 1) {
        //cover
        cell.coverView.image = data;
    }
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
                if ([_userData objectForKey:[NSNumber numberWithLong:user.uid]]==nil) {
                    [_userData setObject:user forKey:[NSNumber numberWithLong:user.uid]];
                }
                [_videoData addObject:[arr objectAtIndex:1]];
            }
            [self.videoCollectionView reloadData];
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


@end
