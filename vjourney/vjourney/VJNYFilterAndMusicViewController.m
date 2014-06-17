//
//  VJNYFilterAndMusicViewController.m
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYFilterAndMusicViewController.h"
#import "VJNYVideoShareViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VJNYFilterCardCell.h"
#import "VJNYUtilities.h"
#import "VJNYPOJOFilter.h"
#import "GPUImage.h"

typedef NS_ENUM(NSInteger, VJNYFilterMode) {
    VJNYFilterModeFilter = 0,
    VJNYFilterModeMusic = 1
};

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@interface VJNYFilterAndMusicViewController () {
    MPMoviePlayerController* _videoPlayer;
    NSMutableArray* _filterArray;
    NSMutableArray* _musicArray;
    
    VJNYFilterMode _filterMode;
    
    long _dragVideoIndex;
    BOOL _isDragging;
    UIImageView *_dragIndicatorImageView;
    
    GPUImageMovie *_movieFile;
    GPUImageOutput<GPUImageInput> *_filter;
    GPUImageMovieWriter *_movieWriter;
    GPUImageRotationMode _movieRotation;
    NSTimer* _movieProcessingTimer;
    float _lastProcess;
    
    BOOL _hasFilter;
}

- (void)generateVideoRotation;

@end


@implementation VJNYFilterAndMusicViewController

@synthesize inputPath=_inputPath;

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
    _isDragging = false;
    _hasFilter = false;
    
    // Parameters
    [self generateVideoRotation];
    
    // Set up VideoPlayer
    //_videoPlayerContainerView.backgroundColor = [UIColor clearColor];
    _videoPlayer = [[MPMoviePlayerController alloc] init];
    
    _videoPlayer.contentURL = _inputPath;
    _videoPlayer.view.frame = self.videoPlayerContainerView.bounds;
    _videoPlayer.controlStyle = MPMovieControlStyleNone;
    _videoPlayer.repeatMode = MPMovieRepeatModeNone;
    [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
    [self.videoPlayerContainerView addSubview:_videoPlayer.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
    // Set up VideoPlayer Play Button
    _playLogoView.alpha = 0.0f;
    [self.videoPlayerContainerView bringSubviewToFront:_playLogoView];
    
    [_videoPlayer play];
    
    // Set up Filter And Music Arrays
    _filterMode = VJNYFilterModeFilter;
    _filterArray = [NSMutableArray array];
    _musicArray = [NSMutableArray array];
    
    // Prepare Filter
    [_filterArray addObject:[[VJNYPOJOFilter alloc] initWithTitle:@"crossprocess" AndCoverPath:@"logo"]];
    [_filterArray addObject:[[VJNYPOJOFilter alloc] initWithTitle:@"02" AndCoverPath:@"logo"]];
    [_filterArray addObject:[[VJNYPOJOFilter alloc] initWithTitle:@"17" AndCoverPath:@"logo"]];
    [_filterArray addObject:[[VJNYPOJOFilter alloc] initWithTitle:@"aqua" AndCoverPath:@"logo"]];
    
    // Set up Collection View
    _filterCardCollectionView.layer.shadowOffset = CGSizeMake(1.0f, -4.0f);
    _filterCardCollectionView.layer.shadowRadius = 5.0f;
    _filterCardCollectionView.layer.shadowOpacity = 0.5f;
    _filterCardCollectionView.layer.masksToBounds = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_videoPlayer.contentURL != nil) {
        [_videoPlayer play];
        _playLogoView.alpha = 0.0f;
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_videoPlayer stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqual:[VJNYUtilities segueVideoSharePage]]) {
        VJNYVideoShareViewController*  controller = segue.destinationViewController;
        controller.inputPath = sender;
    }
}


#pragma mark - Collection View Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_filterMode == VJNYFilterModeFilter) {
        return [_filterArray count];
    } else if (_filterMode == VJNYFilterModeMusic){
        return [_musicArray count];
    }
    return 0;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VJNYFilterCardCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VJNYUtilities filterCardCellIdentifier] forIndexPath:indexPath];
    
    VJNYPOJOFilter* filter;
    
    if (_filterMode == VJNYFilterModeFilter) {
        filter = [_filterArray objectAtIndex:indexPath.row];
    } else if (_filterMode == VJNYFilterModeMusic) {
        filter = [_musicArray objectAtIndex:indexPath.row];
    }
    
    //cell.backgroundImage.image = filter.cover;
    cell.backgroundImage.backgroundColor = [UIColor redColor];
    cell.titleLabel.text = filter.title;
    
    return cell;
}

#pragma mark - Video Playback Handler
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    _playLogoView.alpha = 1.0f;
    /*MPMoviePlayerController* theMovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];*/
    //[_videoPlayer stop];
    //[_videoPlayer.view removeFromSuperview];
    //_videoPlayer = nil;
}

#pragma mark - Video Filter handler
-(void)applyFilter:(int)filterIndex {
    [VJNYUtilities showProgressAlertView];
    [_videoPlayer stop];
    _playLogoView.alpha = 0.0f;
    
    VJNYPOJOFilter* filter = [_filterArray objectAtIndex:filterIndex];
    
    NSURL *sampleURL = _inputPath;
    
    _movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _movieFile.runBenchmark = NO;
    _movieFile.playAtActualSpeed = NO;
    _filter = [[GPUImageToneCurveFilter alloc] initWithACV:filter.title];
    //    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    [_filter setInputRotation:_movieRotation atIndex:0];
    
    [_movieFile addTarget:_filter];
    
    // Only rotate the video for display, leave orientation the same for recording
    //GPUImageView *filterView = (GPUImageView *)self.view;
    //[filter addTarget:filterView];
    
    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToMovie = [VJNYUtilities videoFilterTempPath];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 640.0)];
    [_filter addTarget:_movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    _movieWriter.shouldPassthroughAudio = YES;
    //_movieWriter.encodingLiveVideo = NO;
    _movieFile.audioEncodingTarget = _movieWriter;
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    [_movieWriter startRecording];
    [_movieFile startProcessing];
    
    _lastProcess = -1.0f;
    
    _movieProcessingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
     target:self
     selector:@selector(retrievingProgress)
     userInfo:nil
     repeats:YES];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    [_movieWriter setCompletionBlock:^{
        [weakSelf->_filter removeTarget:weakSelf->_movieWriter];
        //weakSelf->_movieFile.audioEncodingTarget = nil;
        [weakSelf->_movieWriter finishRecording];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf->_videoPlayer.contentURL = [NSURL fileURLWithPath:[VJNYUtilities videoFilterTempPath]];
            [weakSelf->_videoPlayer play];
            weakSelf->_hasFilter = true;
            [VJNYUtilities dismissProgressAlertView];
            //[timer invalidate];
            //self.progressLabel.text = @"100%";
        });
    }];
}

- (void)retrievingProgress {
    if (_lastProcess == _movieFile.progress && _movieFile.progress > 0.5f) {
        // need to manually terminate
        NSLog(@"Manually!");
        [_movieFile endProcessing];
        [_movieProcessingTimer invalidate];
        _movieProcessingTimer = nil;
    } else {
        _lastProcess = _movieFile.progress;
        NSLog(@"Process:%f",_movieFile.progress);
    }
}

- (void)generateVideoRotation {
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_inputPath options:nil];
    
    AVAssetTrack *videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    CGAffineTransform txf = videoAssetTrack.preferredTransform;
    
    float angle = atan2(txf.b, txf.a);
    angle = RADIANS_TO_DEGREES(angle);
    _movieRotation = kGPUImageNoRotation;
    if (angle == 90) {
        _movieRotation = kGPUImageRotateRight;
    } else if (angle == -90) {
        _movieRotation = kGPUImageRotateLeft;
    } else if (angle == 180) {
        _movieRotation = kGPUImageRotate180;
    }
}

#pragma mark - Custom Button Handler

- (IBAction)selectFilterModeAction:(id)sender {
    
    _filterMode = [(UISegmentedControl*)sender selectedSegmentIndex];
    
}

- (IBAction)tapToPlayOrPauseAction:(id)sender {
    
    if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_videoPlayer pause];
        _playLogoView.alpha = 1.0f;
    } else {
        [_videoPlayer play];
        _playLogoView.alpha = 0.0f;
    }
    
}

- (IBAction)pressToSelectFilterAction:(UILongPressGestureRecognizer *)_longPressRecognizer {
    
    if(_longPressRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //if needed do some initial setup or init of views here
        _isDragging = true;
        CGPoint p = [_longPressRecognizer locationInView:self.filterCardCollectionView];
        
        NSIndexPath *indexPath = [self.filterCardCollectionView indexPathForItemAtPoint:p];
        if (indexPath == nil){
            NSLog(@"couldn't find index path");
        } else {
            // get the cell at indexPath (the one you long pressed)
            VJNYFilterCardCell* cell = (VJNYFilterCardCell*)[self.filterCardCollectionView cellForItemAtIndexPath:indexPath];
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
            if ([self.dragReceiverView pointInside:dragPoint withEvent:nil]) {
                self.dragReceiverView.backgroundColor = [UIColor lightGrayColor];
                self.dragReceiverView.alpha = 0.5f;
            } else if (self.dragReceiverView.alpha == 0.5f){
                self.dragReceiverView.backgroundColor = [UIColor clearColor];
                self.dragReceiverView.alpha = 1.0f;
            }
        }
    }
    else if(_longPressRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //else do cleanup
        _isDragging = false;
        if ([self.dragReceiverView pointInside:[_longPressRecognizer locationInView:self.view] withEvent:nil]) {
            [self applyFilter:(int)_dragVideoIndex];
            self.dragReceiverView.backgroundColor = [UIColor clearColor];
            self.dragReceiverView.alpha = 1.0f;
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

- (IBAction)doneFilterAction:(id)sender {
    if (_hasFilter == false) {
        [self performSegueWithIdentifier:[VJNYUtilities segueVideoSharePage] sender:_inputPath];
    } else {
        [self performSegueWithIdentifier:[VJNYUtilities segueVideoSharePage] sender:[NSURL fileURLWithPath:[VJNYUtilities videoFilterTempPath]]];
    }
    
}
@end
