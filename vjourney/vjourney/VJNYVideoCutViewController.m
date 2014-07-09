//
//  VJNYVideoCutViewController.m
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoCutViewController.h"
#import "VJNYFilterAndMusicViewController.h"
#import "VJNYUtilities.h"
#import "VJNYVideoThumbnailViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface VJNYVideoCutViewController () {
    MPMoviePlayerController* _videoPlayer;
    UIImageView* _coverImageView;
    AVAsset* _originalVideoAsset;
    UIInterfaceOrientation _videoOrientation;
    AVAssetImageGenerator* _thumbnailImageGenerator;
    NSMutableDictionary* _thumbnailCache;
    CGFloat _timePerFrame;
    NSArray* _reqTimeArray;
    NSMutableDictionary* _actualTimeArray;
    
    //For Slider
    CGFloat _leftPosition;
    CGFloat _rightPosition;
    CGFloat _minGap;
    
    UIView* _leftMaskView;
    UIView* _rightMaskView;
    UIView* _topMaskView;
    UIView* _bottomMaskView;
    BOOL _firstTimeLoad;
    //CGFloat _maxGap;
    dispatch_queue_t _coverChangeQueue;
}

- (UIImage*)generateThumbnailByTime:(Float64)timePoint;
- (void)updateCoverImage;
- (CGFloat)getLeftTime;
- (CGFloat)getRightTime;
@end

@implementation VJNYVideoCutViewController

//static CGFloat MAX_TIME_RANGE = 6.0f;
static CGFloat MIN_TIME_RANGE = 2.0f;

@synthesize selectedVideoURL=_selectedVideoURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    //[super viewWillDisappear:animated];
    //[self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    //self.navigationController.navigationBar.translucent = YES;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    // Set up VideoPlayer
    _videoPlayer = [[MPMoviePlayerController alloc] init];
    
    _videoPlayer.contentURL = _selectedVideoURL;
    _videoPlayer.view.frame = self.videoPlayBackView.bounds;
    _videoPlayer.controlStyle = MPMovieControlStyleNone;
    _videoPlayer.repeatMode = MPMovieRepeatModeNone;
    [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
    [self.videoPlayBackView addSubview:_videoPlayer.view];
    
    // Set up ImageGenerator
    _originalVideoAsset = [[AVURLAsset alloc] initWithURL:_selectedVideoURL options:nil];
    AVAssetTrack* track = [[_originalVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGAffineTransform txf = [track preferredTransform];
    _videoOrientation = [VJNYUtilities orientationByPreferredTransform:txf];
    //CGSize videoSize = [track naturalSize];
    
    _thumbnailImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_originalVideoAsset];
    _thumbnailImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    _thumbnailImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    _thumbnailImageGenerator.maximumSize = CGSizeMake(_videoPlayBackView.frame.size.width*2, _videoPlayBackView.frame.size.height*2);
    _thumbnailCache = [NSMutableDictionary dictionary];
    
    // Set up Cover Image
    _coverImageView = [[UIImageView alloc] initWithFrame:self.videoPlayBackView.bounds];
    _coverImageView.image = [self generateThumbnailByTime:0];
    [self.videoPlayBackView addSubview:_coverImageView];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startPlayVideoAction:)];
    [_coverImageView addGestureRecognizer:tapGesture];
    [_coverImageView setUserInteractionEnabled:YES];
    
    [self.videoPlayBackView bringSubviewToFront:self.videoPlayButton];
    
    _leftMaskView = nil;
    _rightMaskView = nil;
    _topMaskView = nil;
    _bottomMaskView = nil;
    _firstTimeLoad = true;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_firstTimeLoad == true) {
        _firstTimeLoad = false;
        // Set up Thumbnails
        
        CGSize rect = self.videoThumbnailCollectionView.bounds.size;
        CGFloat numberOfThumbnails = (rect.width / rect.height);
        
        if (CMTimeGetSeconds(_originalVideoAsset.duration) < [VJNYUtilities maxCaptureTime]) {
            _timePerFrame = CMTimeGetSeconds(_originalVideoAsset.duration) / (numberOfThumbnails+1);
        } else {
            _timePerFrame = [VJNYUtilities maxCaptureTime] / numberOfThumbnails;
        }
        
        NSMutableArray* _timeArray = [NSMutableArray array];
        NSInteger numberOfImgs = CMTimeGetSeconds(_originalVideoAsset.duration) / _timePerFrame;
        
        for (int i = 0; i < numberOfImgs; i++) {
            [_timeArray addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(i*_timePerFrame, _originalVideoAsset.duration.timescale)]];
            //NSLog(@"%d-%f",i,CMTimeGetSeconds([[_timeArray objectAtIndex:i] CMTimeValue]));
        }
        _reqTimeArray = _timeArray;
        _actualTimeArray = [NSMutableDictionary dictionaryWithCapacity:[_timeArray count]];
        
        [_thumbnailImageGenerator generateCGImagesAsynchronouslyForTimes:_reqTimeArray completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,AVAssetImageGeneratorResult result, NSError *error) {
            
            if (result == AVAssetImageGeneratorSucceeded) {
                UIImage* imageView= [VJNYUtilities uiImageByCGImage:image WithOrientation:_videoOrientation AndScale:2.0f];
                
                NSUInteger imageNo = [_reqTimeArray indexOfObject:[NSValue valueWithCMTime:requestedTime]];
                //NSLog(@"%f-%f",CMTimeGetSeconds(requestedTime),CMTimeGetSeconds(actualTime));
                //NSLog(@"%d-%f",imageNo,CMTimeGetSeconds(actualTime));
                [_actualTimeArray setObject:[NSValue valueWithCMTime:actualTime] forKey:[NSNumber numberWithUnsignedInteger:imageNo]];
                NSIndexPath* path = [NSIndexPath indexPathForItem:imageNo inSection:0];
                [_thumbnailCache setObject:imageView forKey:path];
                
                if ([[self.videoThumbnailCollectionView indexPathsForVisibleItems] containsObject:path]) {
                    VJNYVideoThumbnailViewCell* cell = (VJNYVideoThumbnailViewCell*)[self.videoThumbnailCollectionView cellForItemAtIndexPath:path];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imageView.image = imageView;
                    });
                }
            }
        }];
        
        // Set up Sliders
        
        // Parameters
        _minGap = self.videoThumbnailCollectionView.frame.size.height * (MIN_TIME_RANGE / _timePerFrame);
        //_maxGap = self.videoThumbnailCollectionView.frame.size.height * (MAX_TIME_RANGE / _timePerFrame);
        _coverChangeQueue = dispatch_queue_create("Change Cover Image Queue", nil);
        /*CGRect sliderLeftRect = self.leftSlider.frame;
         sliderLeftRect.size.width = _minGap / 3;
         [_leftSlider setFrame:sliderLeftRect];
         [_rightSlider setFrame:sliderLeftRect];*/
        
        UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
        [self.leftSlider addGestureRecognizer:leftPan];
        [self.leftSlider setUserInteractionEnabled:YES];
        CGFloat totalWidth = self.view.frame.size.width;
        self.leftSlider.center = CGPointMake(totalWidth/4, self.leftSlider.center.y);
        _leftPosition = self.leftSlider.frame.origin.x;
        
        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
        [self.rightSlider addGestureRecognizer:rightPan];
        [self.rightSlider setUserInteractionEnabled:YES];
        
        self.rightSlider.center = CGPointMake(totalWidth*3/4, self.rightSlider.center.y);
        _rightPosition = self.rightSlider.frame.origin.x+self.rightSlider.frame.size.width;
        
        CGRect containerRect = _videoThumbnailCollectionView.frame;
        
        if (_leftMaskView == nil) {
            _leftMaskView = [[UIView alloc] initWithFrame:CGRectZero];
            [_leftMaskView setBackgroundColor:[UIColor blackColor]];
            [_leftMaskView setAlpha:0.7f];
            [self.view addSubview:_leftMaskView];
        }
        
        if (_rightMaskView == nil) {
            _rightMaskView = [[UIView alloc] initWithFrame:CGRectZero];
            [_rightMaskView setBackgroundColor:[UIColor blackColor]];
            [_rightMaskView setAlpha:0.7f];
            [self.view addSubview:_rightMaskView];
        }
        
        if (_topMaskView == nil) {
            _topMaskView = [[UIView alloc] initWithFrame:CGRectZero];
            [_topMaskView setBackgroundColor:[UIColor whiteColor]];
            [_topMaskView setAlpha:0.4f];
            [self.view addSubview:_topMaskView];
        }
        
        if (_bottomMaskView == nil) {
            _bottomMaskView = [[UIView alloc] initWithFrame:CGRectZero];
            [_bottomMaskView setBackgroundColor:[UIColor whiteColor]];
            [_bottomMaskView setAlpha:0.4f];
            [self.view addSubview:_bottomMaskView];
        }
        
        [_leftSlider setAlpha:0.4f];
        [_rightSlider setAlpha:0.4f];
        
        [_leftMaskView setFrame:CGRectMake(containerRect.origin.x, containerRect.origin.y, _leftPosition - containerRect.origin.x, containerRect.size.height)];
        [_rightMaskView setFrame:CGRectMake(_rightPosition, containerRect.origin.y, containerRect.size.width - _rightPosition, containerRect.size.height)];
        
        [_topMaskView setFrame:CGRectMake(self.leftSlider.frame.origin.x+self.leftSlider.frame.size.width, self.leftSlider.frame.origin.y, self.rightSlider.frame.origin.x - self.leftSlider.frame.origin.x - self.leftSlider.frame.size.width, self.leftSlider.frame.size.width/2)];
        [_bottomMaskView setFrame:CGRectMake(self.leftSlider.frame.origin.x+self.leftSlider.frame.size.width, self.leftSlider.frame.origin.y+self.leftSlider.frame.size.height-self.leftSlider.frame.size.width/2, self.rightSlider.frame.origin.x - self.leftSlider.frame.origin.x - self.leftSlider.frame.size.width, self.leftSlider.frame.size.width/2)];
        
    } else {
        NSLog(@"Re-Organize!");
        self.leftSlider.center = CGPointMake(_leftPosition+self.leftSlider.frame.size.width/2, self.leftSlider.center.y);
        NSLog(@"%f",self.leftSlider.center.x);
        self.rightSlider.center = CGPointMake(_rightPosition-self.rightSlider.frame.size.width/2, self.rightSlider.center.y);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

- (UIImage*)generateThumbnailByTime:(Float64)timePoint {
    NSError *error;
    CMTime actualTime;
    CGImageRef imageRef = [_thumbnailImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(timePoint, _originalVideoAsset.duration.timescale) actualTime:&actualTime error:&error];
    return [VJNYUtilities uiImageByCGImage:imageRef WithOrientation:_videoOrientation AndScale:2.0f];
    //return [[UIImage alloc] initWithCGImage:imageRef];
}

- (void)updateCoverImage {
    dispatch_async(_coverChangeQueue, ^{
        UIImage* newImage = [self generateThumbnailByTime:[self getLeftTime]];
        dispatch_async(dispatch_get_main_queue(), ^{
            _coverImageView.alpha = 1.0f;
            _coverImageView.image = newImage;
        });
    });
}

- (CGFloat)getLeftTime {
    
    NSIndexPath* path = [_videoThumbnailCollectionView indexPathForItemAtPoint:[self.view convertPoint:_leftSlider.center toView:_videoThumbnailCollectionView]];
    UICollectionViewCell* cell = [_videoThumbnailCollectionView cellForItemAtIndexPath:path];
    
    CGFloat startTimePoint = CMTimeGetSeconds([[_actualTimeArray objectForKey:[NSNumber numberWithUnsignedInteger:path.row]] CMTimeValue]);
    CGFloat relativeX = [self.view convertPoint:_leftSlider.center toView:_videoThumbnailCollectionView].x;
    
    // [Bug] last one?
    CGFloat nextTimePoint = CMTimeGetSeconds([[_actualTimeArray objectForKey:[NSNumber numberWithUnsignedInteger:path.row+1]] CMTimeValue]);
    
    CGFloat offsetTimePoint = (nextTimePoint - startTimePoint) * ((relativeX - cell.frame.origin.x) / cell.frame.size.width);
    
    return startTimePoint + offsetTimePoint;
}

- (CGFloat)getRightTime {
    
    NSIndexPath* path = [_videoThumbnailCollectionView indexPathForItemAtPoint:[self.view convertPoint:_rightSlider.center toView:_videoThumbnailCollectionView]];
    UICollectionViewCell* cell = [_videoThumbnailCollectionView cellForItemAtIndexPath:path];
    
    CGFloat startTimePoint = CMTimeGetSeconds([[_actualTimeArray objectForKey:[NSNumber numberWithUnsignedInteger:path.row]] CMTimeValue]);
    CGFloat relativeX = [self.view convertPoint:_rightSlider.center toView:_videoThumbnailCollectionView].x;
    
    // [Bug] last one?
    CGFloat nextTimePoint = CMTimeGetSeconds([[_actualTimeArray objectForKey:[NSNumber numberWithUnsignedInteger:path.row+1]] CMTimeValue]);
    
    CGFloat offsetTimePoint = (nextTimePoint - startTimePoint) * ((relativeX - cell.frame.origin.x) / cell.frame.size.width);
    
    return startTimePoint + offsetTimePoint;
}

#pragma mark - Video Playback Handler
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    _coverImageView.alpha = 1.0f;
    self.videoPlayButton.alpha = 1.0f;
    MPMoviePlayerController* theMovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    [_videoPlayer stop];
    [_videoPlayer.view removeFromSuperview];
    _videoPlayer = nil;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqual:[VJNYUtilities segueVideoFilterPage]]) {
        VJNYFilterAndMusicViewController* controller = [segue destinationViewController];
        controller.inputPath = sender;
    }
}


#pragma mark - UICollectionView Handler


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return CMTimeGetSeconds(_originalVideoAsset.duration) / _timePerFrame;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VJNYVideoThumbnailViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VJNYUtilities videoThumbnailCellIdentifier] forIndexPath:indexPath];
    
    UIImage* image = [_thumbnailCache objectForKey:indexPath];
    /*if (image == nil) {
        image = [self generateThumbnailByTime:(_timePerFrame * indexPath.row)];
        [_thumbnailCache setObject:image forKey:indexPath];
    }*/
    
    cell.imageView.image = image;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.videoThumbnailCollectionView.frame.size.height, self.videoThumbnailCollectionView.frame.size.height);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updateCoverImage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateCoverImage];
}


#pragma mark - Button Event Handler

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        /*
        [self.leftSlider setAlpha:1.0f];
        [_topMaskView setAlpha:1.0f];
        [_bottomMaskView setAlpha:1.0f];
         */
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self.view];
        
        _leftPosition += translation.x;
        if (_leftPosition < 0) {
            _leftPosition = 0;
        } else if (_rightPosition - _leftPosition < _minGap) {// || _rightPosition - _leftPosition > _maxGap) {
            _leftPosition -= translation.x;
        }
        [gesture setTranslation:CGPointZero inView:self.view];
        self.leftSlider.center = CGPointMake(_leftPosition+self.leftSlider.frame.size.width/2, self.leftSlider.center.y);
        CGRect containerRect = _videoThumbnailCollectionView.frame;
        [_leftMaskView setFrame:CGRectMake(containerRect.origin.x, containerRect.origin.y, _leftPosition - containerRect.origin.x, containerRect.size.height)];
        [_topMaskView setFrame:CGRectMake(self.leftSlider.frame.origin.x+self.leftSlider.frame.size.width, _topMaskView.frame.origin.y, self.rightSlider.frame.origin.x - self.leftSlider.frame.origin.x - self.leftSlider.frame.size.width, _topMaskView.frame.size.height)];
        [_bottomMaskView setFrame:CGRectMake(self.leftSlider.frame.origin.x+self.leftSlider.frame.size.width, _bottomMaskView.frame.origin.y, self.rightSlider.frame.origin.x - self.leftSlider.frame.origin.x - self.leftSlider.frame.size.width, _bottomMaskView.frame.size.height)];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        /*
        [self.leftSlider setAlpha:0.4f];
        [_topMaskView setAlpha:0.4f];
        [_bottomMaskView setAlpha:0.4f];
         */
        [self updateCoverImage];
    }
    
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        /*
        [self.rightSlider setAlpha:1.0f];
        [_topMaskView setAlpha:1.0f];
        [_bottomMaskView setAlpha:1.0f];
         */
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self.view];
        
        _rightPosition += translation.x;
        if (_rightPosition > self.view.frame.size.width) {
            _rightPosition -= translation.x;
        } else if (_rightPosition - _leftPosition < _minGap) {// || _rightPosition - _leftPosition > _maxGap) {
            _rightPosition -= translation.x;
        }
        [gesture setTranslation:CGPointZero inView:self.view];
        //CGRect originRect = self.rightSlider.frame;
        //originRect.origin.x = _rightPosition;
        //[self.rightSlider setFrame:originRect];
        self.rightSlider.center = CGPointMake(_rightPosition-self.rightSlider.frame.size.width/2, self.rightSlider.center.y);
        CGRect containerRect = _videoThumbnailCollectionView.frame;
        [_rightMaskView setFrame:CGRectMake(_rightPosition, containerRect.origin.y, containerRect.size.width - _rightPosition, containerRect.size.height)];
        [_topMaskView setFrame:CGRectMake(self.leftSlider.frame.origin.x+self.leftSlider.frame.size.width, _topMaskView.frame.origin.y, self.rightSlider.frame.origin.x - self.leftSlider.frame.origin.x - self.leftSlider.frame.size.width, _topMaskView.frame.size.height)];
        [_bottomMaskView setFrame:CGRectMake(self.leftSlider.frame.origin.x+self.leftSlider.frame.size.width, _bottomMaskView.frame.origin.y, self.rightSlider.frame.origin.x - self.leftSlider.frame.origin.x - self.leftSlider.frame.size.width, _bottomMaskView.frame.size.height)];
        //[self.view setNeedsLayout];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        /*
        [self.rightSlider setAlpha:0.4f];
        [_topMaskView setAlpha:0.4f];
        [_bottomMaskView setAlpha:0.4f];
        */
    }
    
}

- (void)startPlayVideoAction:(UITapGestureRecognizer *)gesture {
    if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_videoPlayer pause];
        _videoPlayButton.alpha = 1.0f;
    } else {
        if (_videoPlayer == nil) {
            _videoPlayer = [[MPMoviePlayerController alloc] init];
            
            _videoPlayer.contentURL = _selectedVideoURL;
            _videoPlayer.view.frame = self.videoPlayBackView.bounds;
            _videoPlayer.controlStyle = MPMovieControlStyleNone;
            _videoPlayer.repeatMode = MPMovieRepeatModeNone;
            [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
            [self.videoPlayBackView addSubview:_videoPlayer.view];
            [self.videoPlayBackView bringSubviewToFront:_coverImageView];
            [self.videoPlayBackView bringSubviewToFront:_videoPlayButton];
        }
        [_videoPlayer setInitialPlaybackTime:[self getLeftTime]];
        [_videoPlayer setEndPlaybackTime:[self getRightTime]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
        [_videoPlayer play];
        [self performSelector:@selector(hideCoverImage) withObject:nil afterDelay:0.2];
    }
}

- (void)hideCoverImage {
    _coverImageView.alpha = 0.0f;
    self.videoPlayButton.alpha = 0.0f;
}
- (IBAction)trimVideoAction:(id)sender {
    
    [VJNYUtilities showProgressAlertViewToView:self.view];
    
    NSURL *videoFileUrl = _selectedVideoURL;
    
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        
        NSURL *furl = [NSURL fileURLWithPath:[VJNYUtilities videoCutOutputPath]];
        [VJNYUtilities checkAndDeleteFileForPath:[VJNYUtilities videoCutOutputPath]];
        
        exportSession.outputURL = furl;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds([self getLeftTime], anAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds([self getRightTime]-[self getLeftTime], anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [VJNYUtilities dismissProgressAlertViewFromView:self.view];
                        [self performSegueWithIdentifier:[VJNYUtilities segueVideoFilterPage] sender:exportSession.outputURL];
                    });
                    
                    break;
            }
        }];
        
    }
    
}
@end
