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
#import "VJNYPOJOFilterOrMusic.h"
#import "GPUImage.h"

typedef NS_ENUM(NSInteger, VJNYFilterMode) {
    VJNYFilterModeFilter = 0,
    VJNYFilterModeMusic = 1
};

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@interface VJNYFilterAndMusicViewController () {
    AVPlayer* _videoPlayer;
    AVAudioPlayer* _musicPlayer;
    
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
    int _currentMusicIndex;
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
    _currentMusicIndex = 0;
    
    // Parameters
    [self generateVideoRotation];
    
    // Set up VideoPlayer
    //_videoPlayerContainerView.backgroundColor = [UIColor clearColor];
    _musicPlayer = nil;
    _videoPlayer = [[AVPlayer alloc] initWithURL:_inputPath];
    AVPlayerLayer* videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_videoPlayer];
    
    videoPlayerLayer.frame = self.videoPlayerContainerView.layer.bounds;
    [self.videoPlayerContainerView.layer addSublayer:videoPlayerLayer];
    
    //_videoPlayer = [[MPMoviePlayerController alloc] init];
    /*
    _videoPlayer.contentURL = _inputPath;
    _videoPlayer.view.frame = self.videoPlayerContainerView.bounds;
    _videoPlayer.controlStyle = MPMovieControlStyleNone;
    _videoPlayer.repeatMode = MPMovieRepeatModeNone;
    [_videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
    [self.videoPlayerContainerView addSubview:_videoPlayer.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
     */
    
    _videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_videoPlayer currentItem]];
    
    // Set up VideoPlayer Play Button
    _playLogoView.alpha = 0.0f;
    [self.videoPlayerContainerView bringSubviewToFront:_playLogoView];
    
    [self startMoviePlayer];
    
    // Set up Filter And Music Arrays
    _filterMode = VJNYFilterModeFilter;
    _filterArray = [NSMutableArray array];
    _musicArray = [NSMutableArray array];
    
    // Prepare Filter
    [_filterArray addObject:[[VJNYPOJOFilterOrMusic alloc] initWithTitle:@"crossprocess" AndCoverPath:@"logo" AndFileName:@"crossprocess"]];
    [_filterArray addObject:[[VJNYPOJOFilterOrMusic alloc] initWithTitle:@"02" AndCoverPath:@"logo" AndFileName:@"02"]];
    [_filterArray addObject:[[VJNYPOJOFilterOrMusic alloc] initWithTitle:@"17" AndCoverPath:@"logo" AndFileName:@"17"]];
    [_filterArray addObject:[[VJNYPOJOFilterOrMusic alloc] initWithTitle:@"aqua" AndCoverPath:@"logo" AndFileName:@"aqua"]];
    
    // Prepare Music
    [_musicArray addObject:[[VJNYPOJOFilterOrMusic alloc] initWithTitle:@"original" AndCoverPath:@"logo" AndFileName:@""]];
    [_musicArray addObject:[[VJNYPOJOFilterOrMusic alloc] initWithTitle:@"rock" AndCoverPath:@"logo" AndFileName:@"bgm_rock_sample"]];
    [_musicArray addObject:[[VJNYPOJOFilterOrMusic alloc] initWithTitle:@"orchestra" AndCoverPath:@"logo" AndFileName:@"bgm_orchestra_sample"]];
    [_musicArray addObject:[[VJNYPOJOFilterOrMusic alloc] initWithTitle:@"piano" AndCoverPath:@"logo" AndFileName:@"bgm_piano_sample"]];
    [_musicArray addObject:[[VJNYPOJOFilterOrMusic alloc] initWithTitle:@"village" AndCoverPath:@"logo" AndFileName:@"bgm_village_sample"]];
    
    // Set up Collection View
    _filterCardCollectionView.layer.shadowOffset = CGSizeMake(1.0f, -4.0f);
    _filterCardCollectionView.layer.shadowRadius = 5.0f;
    _filterCardCollectionView.layer.shadowOpacity = 0.5f;
    _filterCardCollectionView.layer.masksToBounds = NO;
    
    // Set up Sound Stuff
    _muteOriginalSoundSwitch.hidden = YES;
    _originalSoundLabel.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //if (_videoPlayer. != nil) {
    [self startMoviePlayer];
    //}
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_videoPlayer pause];
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
    
    VJNYPOJOFilterOrMusic* filter;
    
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

#pragma mark - Video Player Helper

-(void)stopMoviePlayer {
    self.playLogoView.alpha = 1.0f;
    [_videoPlayer pause];
    [[_videoPlayer currentItem] seekToTime:kCMTimeZero];
    [self stopMusicPlayer];
}

-(void)startMoviePlayer {
    self.playLogoView.alpha = 0.0f;
    [_videoPlayer play];
    if (_musicPlayer != nil) {
        [_musicPlayer play];
    }
}

-(void)stopMusicPlayer {
    if (_musicPlayer != nil) {
        [_musicPlayer stop];
        _musicPlayer.currentTime = 0;
    }
}

-(void)changeMoviePlayerWithMute:(BOOL)mute {
    
    AVAsset *asset = [[_videoPlayer currentItem] asset];
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    
    // Mute all the audio tracks
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
        if (mute) {
            [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
        } else {
            [audioInputParams setVolume:1.0 atTime:kCMTimeZero];
        }
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    
    [[_videoPlayer currentItem] setAudioMix:audioZeroMix];

}

#pragma mark - Video Playback Handler
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    _playLogoView.alpha = 1.0f;
    [_videoPlayer pause];
    [[_videoPlayer currentItem] seekToTime:kCMTimeZero];
    [self stopMusicPlayer];
    /*MPMoviePlayerController* theMovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];*/
    //[_videoPlayer stop];
    //[_videoPlayer.view removeFromSuperview];
    //_videoPlayer = nil;
}

#pragma mark - Video Filter handler
-(void)applyFilter:(int)filterIndex {
    [VJNYUtilities showProgressAlertViewToView:self.view];
    //[_videoPlayer pause];
    [self stopMoviePlayer];
    _playLogoView.alpha = 0.0f;
    
    VJNYPOJOFilterOrMusic* filter = [_filterArray objectAtIndex:filterIndex];
    
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
    
    _movieProcessingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(retrievingProgress) userInfo:nil repeats:YES];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    __unsafe_unretained typeof(UIView*) weakSelfView = self.view;
    
    [_movieWriter setCompletionBlock:^{
        [weakSelf->_filter removeTarget:weakSelf->_movieWriter];
        //weakSelf->_movieFile.audioEncodingTarget = nil;
        [weakSelf->_movieWriter finishRecording];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf->_videoPlayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:[VJNYUtilities videoFilterTempPath]]]];
            //weakSelf->_videoPlayer.contentURL = ];
            [weakSelf startMoviePlayer];
            weakSelf->_hasFilter = true;
            [VJNYUtilities dismissProgressAlertViewFromView:weakSelfView];
            //[timer invalidate];
            //self.progressLabel.text = @"100%";
        });
    }];
}

- (void)retrievingProgress {
    if (_lastProcess == _movieFile.progress && _movieFile.progress > 0.8f) {
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

#pragma mark - Video Music Handler

- (void)selectMusic:(int)musicIndex {
    
    if (_currentMusicIndex == musicIndex) {
        return;
    }
    
    //[_videoPlayer stop];
    [self stopMoviePlayer];
    
    if (musicIndex == 0) {
        // remove any sound
        _musicPlayer = nil;
        [self startMoviePlayer];
    } else {
        VJNYPOJOFilterOrMusic* filter = [_musicArray objectAtIndex:musicIndex];
        
        NSURL* soundUrl = [[NSBundle mainBundle] URLForResource:filter.fileName withExtension:@"m4a"];
        _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
        //audioPlayer.delegate = self;
        //audioPlayer.volume = 1.0;
        
        [self startMoviePlayer];
    }
    
    _currentMusicIndex = musicIndex;
}

- (void)applyMusicAndExport {
    
    if (_currentMusicIndex == 0 && _muteOriginalSoundSwitch.on) {
        // didn't select any music
        if (_hasFilter == false) {
            [self performSegueWithIdentifier:[VJNYUtilities segueVideoSharePage] sender:_inputPath];
        } else {
            [self performSegueWithIdentifier:[VJNYUtilities segueVideoSharePage] sender:[NSURL fileURLWithPath:[VJNYUtilities videoFilterTempPath]]];
        }
    } else {
        
        [VJNYUtilities showProgressAlertViewToView:self.view];
        //[_videoPlayer stop];
        [self stopMoviePlayer];
        _playLogoView.alpha = 0.0f;
        
        NSURL *sampleURL;
        
        if (_hasFilter == false) {
            sampleURL = _inputPath;
        } else {
            sampleURL = [NSURL fileURLWithPath:[VJNYUtilities videoFilterTempPath]];
        }
        
        // 1. Original Video
        AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:sampleURL options:nil];
        
        // 2. Music Asset
        
        // 3.1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        // 3.2 - Video track
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        
        // 3.3 - Insert Video part
        CMTime interval = kCMTimeZero;
        
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        if (_muteOriginalSoundSwitch.on) {
            AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                 preferredTrackID:kCMPersistentTrackID_Invalid];
            [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                 ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:interval error:nil];
        }
        
        if (_currentMusicIndex != 0) {
            AVMutableCompositionTrack *thirdTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                 preferredTrackID:kCMPersistentTrackID_Invalid];
            
            int musicIndex = _currentMusicIndex;
            VJNYPOJOFilterOrMusic* filter = [_musicArray objectAtIndex:musicIndex];
            AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:[[NSBundle mainBundle] URLForResource:filter.fileName withExtension:@"m4a"] options:nil];
            AVAssetTrack* songTrack = [songAsset.tracks objectAtIndex:0];
            [thirdTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:songTrack atTime:kCMTimeZero error:nil];
        }
        
        // 4 - Get path
        NSString *paths = [VJNYUtilities videoFilterOutputPath];
        [VJNYUtilities checkAndDeleteFileForPath:paths];
        NSURL *url = [NSURL fileURLWithPath:paths];
        // 5 - Create exporter
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL=url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = NO;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
            });
        }];
        
    }
}

-(void)exportDidFinish:(AVAssetExportSession*)session {
    [VJNYUtilities dismissProgressAlertViewFromView:self.view];
    if (session.status == AVAssetExportSessionStatusCompleted) {
        [self performSegueWithIdentifier:[VJNYUtilities segueVideoSharePage] sender:session.outputURL];
    } else {
        NSLog(@"%@",session.error.localizedDescription);
    }
    
}


#pragma mark - Custom Button Handler

- (IBAction)selectFilterModeAction:(id)sender {
    
    _filterMode = [(UISegmentedControl*)sender selectedSegmentIndex];
    [self.filterCardCollectionView reloadData];
    
    _muteOriginalSoundSwitch.hidden = (_filterMode != VJNYFilterModeMusic);
    _originalSoundLabel.hidden = (_filterMode != VJNYFilterModeMusic);
    
}

- (IBAction)tapToPlayOrPauseAction:(id)sender {
    /*
    if (_videoPlayer.playbackState == MPMoviePlaybackStatePlaying) {
     
     */
    
    if ([_videoPlayer rate] != 0.0) {
        [_videoPlayer pause];
        if (_musicPlayer != nil) {
            [_musicPlayer pause];
        }
        _playLogoView.alpha = 1.0f;
    } else {
        [self startMoviePlayer];
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
            
            if (_filterMode == VJNYFilterModeFilter) {
                [self applyFilter:(int)_dragVideoIndex];
            } else {
                [self selectMusic:(int)_dragVideoIndex];
            }
            
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
    [self applyMusicAndExport];
}
- (IBAction)changeMuteSettingAction:(id)sender {
    [self changeMoviePlayerWithMute:!(_muteOriginalSoundSwitch.on)];
}
@end
