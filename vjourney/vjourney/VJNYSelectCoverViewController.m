//
//  VJNYSelectCoverViewController.m
//  vjourney
//
//  Created by alex on 14-6-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYSelectCoverViewController.h"
#import "VJNYUtilities.h"
#import "VJNYVideoThumbnailViewCell.h"
#import <AVFoundation/AVFoundation.h>

@interface VJNYSelectCoverViewController () {
    AVAsset* _originalVideoAsset;
    UIInterfaceOrientation _videoOrientation;
    AVAssetImageGenerator* _thumbnailImageGenerator;
    NSMutableDictionary* _thumbnailCache;
    CGFloat _timePerFrame;
    NSArray* _reqTimeArray;
    NSMutableDictionary* _actualTimeArray;
    
    //For Slider
    CGFloat _sliderPosition;
    dispatch_queue_t _coverChangeQueue;
}

- (UIImage*)generateThumbnailByTime:(Float64)timePoint;
- (void)updateCoverImage;
- (CGFloat)getSliderTime;

@end

@implementation VJNYSelectCoverViewController

@synthesize inputPath=_inputPath;
@synthesize delegate=_delegate;

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
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // Set up ImageGenerator
    _originalVideoAsset = [[AVURLAsset alloc] initWithURL:_inputPath options:nil];
    AVAssetTrack* track = [[_originalVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGAffineTransform txf = [track preferredTransform];
    _videoOrientation = [VJNYUtilities orientationByPreferredTransform:txf];
    //CGSize videoSize = [track naturalSize];
    
    _thumbnailImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_originalVideoAsset];
    _thumbnailImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    _thumbnailImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    _thumbnailImageGenerator.maximumSize = CGSizeMake(_coverImageView.frame.size.width*2, _coverImageView.frame.size.height*2);
    _thumbnailCache = [NSMutableDictionary dictionary];
    
    _coverImageView.image = [self generateThumbnailByTime:0];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
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
    _coverChangeQueue = dispatch_queue_create("Change Cover Image Queue", nil);
    _sliderPosition = _sliderView.center.x;
    
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
    
}

- (void)updateCoverImage {
    dispatch_async(_coverChangeQueue, ^{
        UIImage* newImage = [self generateThumbnailByTime:[self getSliderTime]];
        dispatch_async(dispatch_get_main_queue(), ^{
            _coverImageView.alpha = 1.0f;
            _coverImageView.image = newImage;
        });
    });
}

- (CGFloat)getSliderTime {
    
    NSIndexPath* path = [_videoThumbnailCollectionView indexPathForItemAtPoint:[self.view convertPoint:_sliderView.center toView:_videoThumbnailCollectionView]];
    UICollectionViewCell* cell = [_videoThumbnailCollectionView cellForItemAtIndexPath:path];
    
    CGFloat startTimePoint = CMTimeGetSeconds([[_actualTimeArray objectForKey:[NSNumber numberWithUnsignedInteger:path.row]] CMTimeValue]);
    CGFloat relativeX = [self.view convertPoint:_sliderView.center toView:_videoThumbnailCollectionView].x;
    
    CGFloat nextTimePoint;
    if (path.row + 1 < [_actualTimeArray count]) {
        nextTimePoint = CMTimeGetSeconds([[_actualTimeArray objectForKey:[NSNumber numberWithUnsignedInteger:path.row+1]] CMTimeValue]);
    } else {
        nextTimePoint = CMTimeGetSeconds(_originalVideoAsset.duration);
    }
    
    CGFloat offsetTimePoint = (nextTimePoint - startTimePoint) * ((relativeX - cell.frame.origin.x) / cell.frame.size.width);
    
    return startTimePoint + offsetTimePoint;
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

- (IBAction)cancelAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(selectCoverDidCancel)]) {
        [self.delegate selectCoverDidCancel];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(selectCoverDidDoneWithImage:)]) {
        [self.delegate selectCoverDidDoneWithImage:_coverImageView.image];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dragSliderAction:(UIPanGestureRecognizer *)sender {
    
    UIPanGestureRecognizer* gesture = sender;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.sliderView setAlpha:1.0f];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self.view];
        
        _sliderPosition += translation.x;
        if (_sliderPosition < 0) {
            _sliderPosition = 0;
        } else if (_sliderPosition > self.view.bounds.size.width) {
            _sliderPosition -= translation.x;
        }
        [gesture setTranslation:CGPointZero inView:self.view];
        self.sliderView.center = CGPointMake(_sliderPosition, self.sliderView.center.y);
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.sliderView setAlpha:0.4f];
        [self updateCoverImage];
    }
    
}
@end
