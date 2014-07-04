//
//  VJNYVideoCaptureViewController.m
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoCaptureViewController.h"
#import "VJNYFilterAndMusicViewController.h"
#import "VJNYUtilities.h"
#import "VJNYVideoCutViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface VJNYVideoCaptureViewController () {
    UIImagePickerController* _videoPickerController;
    
    //progress View
    float _totalProgress;
    NSMutableArray *_redProgressArray;
    UIView* _flashDotView;
    NSTimer *_holdTimer;
    BOOL _hasRecording;
    BOOL _isCapture;
    
    //button mode
    BOOL _isDeleteInConfirm;
    
    //video stuff
    AVCaptureVideoPreviewLayer *_previewLayer;
    ALAssetsLibrary *_assetLibrary;
    NSMutableArray *_capturedVideoArray;
    float _currentCaptureBeginTime;
    NSMutableArray *_capturedVideoLengthArray;
    
    float _progressToAdd;
}

- (void)changeFlashAction:(id)sender;
- (void)changeCameraDeviceAction:(id)sender;
- (void)flashViewAnimation;
- (void)addNewRedProgress;
- (void)addRecordingProgress;
- (void)restoreDeleteButton;
@end

@implementation VJNYVideoCaptureViewController

@synthesize delegate=_delegate;
@synthesize captureMode=_captureMode;

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
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_editing_head.jpg"] forBarMetrics:UIBarMetricsDefault];
    
    // VideoPicker
    _videoPickerController = [[UIImagePickerController alloc] init];
    _videoPickerController.delegate = self;
    _videoPickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    _videoPickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //[_videoPickerController.navigationBar setBarStyle:UIBarStyleBlack];
    //[_videoPickerController.navigationBar setTintColor:[UIColor blackColor]];
    [_videoPickerController setMediaTypes:[NSArray arrayWithObjects:@"public.movie", nil]];
    
    // Setup Navigation Bar
    UIBarButtonItem *rightFlashButton = [[UIBarButtonItem alloc] initWithTitle:@"Flash" style:UIBarButtonItemStylePlain target:self action:@selector(changeFlashAction:)];
    UIBarButtonItem *rightFlipButton = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStyleBordered target:self action:@selector(changeCameraDeviceAction:)];
    self.navigationItem.rightBarButtonItems = @[rightFlipButton,rightFlashButton];
    
    _isDeleteInConfirm = false;
    
    // Setup Capture
    [self _setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self _resetCapture];
    [[PBJVision sharedInstance] startPreview];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //[self.navigationController.navigationBar setHidden:NO];
    //[self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    //[self.navigationController.navigationBar setTintColor:[UIColor blueColor]];
    
    [[PBJVision sharedInstance] stopPreview];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Video Preparation
-(void)_setup
{
    //prepare video stuff
    _assetLibrary=[[ALAssetsLibrary alloc] init];
    _capturedVideoArray = [NSMutableArray array];
    _capturedVideoLengthArray = [NSMutableArray array];
    
    //prepare Progress View
    _redProgressArray = [NSMutableArray array];
    _hasRecording = false;
    _totalProgress=0;
    _progressToAdd = 0.2f;
    
    //min capture line
    UIView* minCaptureLine = [[UIView alloc] initWithFrame:CGRectMake([VJNYUtilities minCaptureTime] / 0.01f * _progressToAdd,0,1.0f,_progressContainerView.frame.size.height)];
    [minCaptureLine setBackgroundColor:[UIColor whiteColor]];
    [_progressContainerView addSubview:minCaptureLine];
    
    //flashDotView
    _flashDotView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, _progressContainerView.frame.size.height, _progressContainerView.frame.size.height)];
    _flashDotView.backgroundColor=[UIColor whiteColor];
    [_progressContainerView addSubview:_flashDotView];
    [self flashViewAnimation];
    
    //add AV layer
    _previewLayer=[[PBJVision sharedInstance] previewLayer];
    CGRect previewBounds=_previewView.layer.bounds;
    _previewLayer.bounds=previewBounds;
    _previewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    _previewLayer.position=CGPointMake(CGRectGetMidX(previewBounds), CGRectGetMidY(previewBounds));
    [_previewView.layer addSublayer:_previewLayer];
    
    //disable Delete Button
    _videoDeleteButton.enabled = NO;
}

- (void)addNewRedProgress {
    
    static float spacingBetweenProgress = 2.0f;
    
    float configureX = 0.0f;
    if ([_redProgressArray count] > 0) {
        UIView* lastView = [_redProgressArray lastObject];
        configureX = lastView.frame.origin.x + lastView.frame.size.width + spacingBetweenProgress;
    } else {
        _videoDeleteButton.enabled = YES;
        [_videoSelectionOrDoneButton setTitle:@"Done" forState:UIControlStateNormal];
        
        _videoSelectionOrDoneButton.enabled = NO;
    }
    UIView *redView=[[UIView alloc] initWithFrame:CGRectMake(configureX, 0, 0, _progressContainerView.frame.size.height)];
    redView.backgroundColor = [UIColor redColor];
    [_progressContainerView addSubview:redView];
    
    _flashDotView.center = CGPointMake(configureX + _flashDotView.frame.size.width/2, _flashDotView.center.y);
    [_redProgressArray addObject:redView];
    
    _currentCaptureBeginTime = _totalProgress;
}

-(void)addRecordingProgress {
    
    
    static float timeToAdd = 0.01f;
    
    CGRect lastFrame=((UIView *)[_redProgressArray lastObject]).frame;
    lastFrame.size.width+=_progressToAdd;
    ((UIView *)[_redProgressArray lastObject]).frame=lastFrame;
    
    _flashDotView.center = CGPointMake(_flashDotView.center.x + _progressToAdd, _flashDotView.center.y);
    
    _totalProgress+=timeToAdd;
    
    if (_totalProgress >= [VJNYUtilities minCaptureTime]) {
        _videoSelectionOrDoneButton.enabled = YES;
    }
    if (_totalProgress >= [VJNYUtilities maxCaptureTime]) {
        [self _endCapture];
        _videoCaptureButton.enabled = NO;
    }
}

- (void)flashViewAnimation {
    
    if (_flashDotView.alpha==1) {
        _flashDotView.alpha=0;
    }else
    {
        _flashDotView.alpha=1;
    }
    [self performSelector:@selector(flashViewAnimation) withObject:nil afterDelay:1];
}

- (void)restoreDeleteButton {
    [_videoDeleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    if ([_redProgressArray count] > 0) {
        [[_redProgressArray lastObject] setAlpha:1.0f];
    }
    _isDeleteInConfirm = false;
}

#pragma mark - Video Handler

-(void)_startCapture
{
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    
    [[PBJVision sharedInstance] startVideoCapture];
    
    [self addNewRedProgress];
    
    _holdTimer =[NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(addRecordingProgress) userInfo:nil repeats:YES];
}

-(void)_pauseCapture
{
    [[PBJVision sharedInstance] pauseVideoCapture];
    [_holdTimer invalidate];
    _holdTimer = nil;
}

-(void)_resumeCapture
{
    [[PBJVision sharedInstance] resumeVideoCapture];
    _holdTimer =[NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(addRecordingProgress) userInfo:nil repeats:YES];
}

-(void)_endCapture
{
    if (_isCapture) {
        [UIApplication sharedApplication].idleTimerDisabled=NO;
        [[PBJVision sharedInstance] endVideoCapture];
        [_holdTimer invalidate];
        _holdTimer = nil;
        
        NSLog(@"%f",_totalProgress);
        float lastLength = _totalProgress - _currentCaptureBeginTime;
        NSLog(@"%f",lastLength);
        [_capturedVideoLengthArray addObject:[NSNumber numberWithFloat:lastLength]];
        
        _isCapture = false;
    }
}

-(void)_resetCapture
{
    PBJVision *vision=[PBJVision sharedInstance];
    vision.delegate=self;
    [vision setCameraMode:PBJCameraModeVideo];
    [vision setCameraDevice:PBJCameraDeviceBack];
    [vision setCameraOrientation:PBJCameraOrientationPortrait];
    [vision setFocusMode:PBJFocusModeAutoFocus];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:[VJNYUtilities segueVideoCutPage]]) {
        VJNYVideoCutViewController* controller = [segue destinationViewController];
        controller.selectedVideoURL = (NSURL*)sender;
    } else if ([segue.identifier isEqual:[VJNYUtilities segueVideoFilterPage]]) {
        VJNYFilterAndMusicViewController* controller = [segue destinationViewController];
        controller.inputPath = sender;
    }
    
}

#pragma mark - Button Event Handler

- (IBAction)videoSelectAction:(id)sender {
    [self restoreDeleteButton];
    if (_hasRecording == NO) {
        
        [self presentViewController:_videoPickerController animated:YES completion:nil];
    } else {
        [self doneCaptureAction:sender];
    }
}

- (IBAction)videoDeleteAction:(id)sender {
    
    if (_isDeleteInConfirm == false) {
        _isDeleteInConfirm = true;
        [_videoDeleteButton setTitle:@"Yes?" forState:UIControlStateNormal];
        
        UIView* lastProgressView = [_redProgressArray lastObject];
        [lastProgressView setAlpha:0.5f];
    } else {
        NSString* lastVideoPath = [_capturedVideoArray lastObject];
        [VJNYUtilities checkAndDeleteFileForPath:lastVideoPath];
        [_capturedVideoArray removeLastObject];
        
        UIView* lastProgressView = [_redProgressArray lastObject];
        [lastProgressView removeFromSuperview];
        [_flashDotView setCenter:CGPointMake(_flashDotView.center.x - lastProgressView.frame.size.width, _flashDotView.center.y)];
        [_redProgressArray removeLastObject];
        
        _totalProgress -= [[_capturedVideoLengthArray lastObject] floatValue];
        [_capturedVideoLengthArray removeLastObject];
        
        if (_totalProgress < [VJNYUtilities minCaptureTime]) {
            _videoSelectionOrDoneButton.enabled = NO;
        }
        if (_totalProgress < [VJNYUtilities maxCaptureTime]) {
            _videoCaptureButton.enabled = YES;
        }
        
        if ([_capturedVideoArray count] == 0) {
            // removed all the videos
            _hasRecording = false;
            [_videoSelectionOrDoneButton setTitle:@"Import" forState:UIControlStateNormal];
            
            _videoSelectionOrDoneButton.enabled = YES;
            _videoDeleteButton.enabled = NO;
        }
        [self restoreDeleteButton];
    }
}

- (IBAction)startCaptureAction:(id)sender {
    [self restoreDeleteButton];
    _hasRecording = true;
    [self _startCapture];
}

- (IBAction)endCaptureInSideAction:(id)sender {
    [self _endCapture];
}

- (IBAction)endCaptureOutSideAction:(id)sender {
    [self _endCapture];
}

- (IBAction)cancelCaptureAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeFlashAction:(id)sender {
    [[PBJVision sharedInstance] switchFlashLight];
}

- (void)changeCameraDeviceAction:(id)sender {
    PBJVision *vision = [PBJVision sharedInstance];
    if (vision.cameraDevice == PBJCameraDeviceBack) {
        [vision setCameraDevice:PBJCameraDeviceFront];
    } else {
        [vision setCameraDevice:PBJCameraDeviceBack];
    }
}

- (void)doneCaptureAction:(id)sender {
    
    if ([_capturedVideoArray count] > 0) {
        
        //[[VJNYUtilities alertViewWithProgress] show];
        [VJNYUtilities showProgressAlertViewToView:self.view];
        
        NSArray* sortedArray = [_capturedVideoArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString*)obj2 compare:(NSString*)obj1];
        }];
        
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        // 2 - Video track
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                             preferredTrackID:kCMPersistentTrackID_Invalid];
        // 3 - Insert Video part
        CMTime interval = kCMTimeZero;
        for (NSString* tmpFilePath in sortedArray) {
            AVAsset* asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:tmpFilePath]];
            NSArray* trackArray = [asset tracksWithMediaType:AVMediaTypeVideo];
            [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:[trackArray objectAtIndex:0] atTime:interval error:nil];
            [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:interval error:nil];
            interval = CMTimeMake(CMTimeGetSeconds(interval)+CMTimeGetSeconds(asset.duration), asset.duration.timescale);
        }

        
        // 4 - Get path
        NSString *paths = [VJNYUtilities videoFilterInputPath];
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
        /*NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        
                    }
                });
            }];
        }*/
        [self performSegueWithIdentifier:[VJNYUtilities segueVideoFilterPage] sender:session.outputURL];
    } else {
        NSLog(@"%@",session.error.localizedDescription);
    }
    
}

#pragma mark - PBJVisionDelegate

- (void)visionSessionWillStart:(PBJVision *)vision {
}

- (void)visionSessionDidStart:(PBJVision *)vision {
    
}

- (void)visionSessionDidStop:(PBJVision *)vision {
    
}

- (void)visionPreviewDidStart:(PBJVision *)vision {
    
}

- (void)visionPreviewWillStop:(PBJVision *)vision {
    
}

- (void)visionModeWillChange:(PBJVision *)vision {
    
}

- (void)visionModeDidChange:(PBJVision *)vision {
}

- (void)vision:(PBJVision *)vision cleanApertureDidChange:(CGRect)cleanAperture {
    
}

- (void)visionWillStartFocus:(PBJVision *)vision {
    
}

- (void)visionDidStopFocus:(PBJVision *)vision {
    
}

// Capture Delegate

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    _isCapture = true;
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
    
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
    
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    [_capturedVideoArray addObject:[videoDict objectForKey:@"PBJVisionVideoPathKey"]];
    NSLog(@"%@",[_capturedVideoArray lastObject]);
}


#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // this is the file system url of the media
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL* videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    
    //AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    CMTime duration = asset.duration;
    float seconds = CMTimeGetSeconds(duration);
    NSLog(@"%f",seconds);
    if (seconds > [VJNYUtilities minCaptureTime]) {
        // send to cut
        [self performSegueWithIdentifier:[VJNYUtilities segueVideoCutPage] sender:videoUrl];
    } else {
        // send to filter
        [self performSegueWithIdentifier:[VJNYUtilities segueVideoFilterPage] sender:videoUrl];
    }
    
    //NSLog(@"%@",[videoUrl absoluteString]);
    // TODO: read in data at videoUrl and write upload it to your server
    
}

/*- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"ImagePicker Cancel!");
}*/
@end
