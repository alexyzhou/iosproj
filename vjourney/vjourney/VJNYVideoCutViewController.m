//
//  VJNYVideoCutViewController.m
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoCutViewController.h"
#import "VJNYUtilities.h"
#import "VJNYVideoThumbnailViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface VJNYVideoCutViewController () {
    MPMoviePlayerController* _videoPlayer;
    UIImageView* _coverImageView;
    AVAsset* _originalVideoAsset;
    AVAssetImageGenerator* _thumbnailImageGenerator;
    NSMutableDictionary* _thumbnailCache;
    CGFloat _timePerFrame;
    NSArray* _reqTimeArray;
}

- (UIImage*)generateThumbnailByTime:(Float64)timePoint;

@end

@implementation VJNYVideoCutViewController

static CGFloat MAX_TIME_RANGE = 2.0f;

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
    self.navigationController.navigationBar.translucent = NO;
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
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
    [_videoPlayer setScalingMode:MPMovieScalingModeFill];
    [self.videoPlayBackView addSubview:_videoPlayer.view];
    
    // Set up ImageGenerator
    _originalVideoAsset = [[AVURLAsset alloc] initWithURL:_selectedVideoURL options:nil];
    _thumbnailImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_originalVideoAsset];
    if ([VJNYUtilities isRetina]){
        _thumbnailImageGenerator.maximumSize = CGSizeMake(self.videoThumbnailCollectionView.frame.size.height*2, self.videoThumbnailCollectionView.frame.size.height*2);
    } else {
        _thumbnailImageGenerator.maximumSize = CGSizeMake(self.videoThumbnailCollectionView.frame.size.height, self.videoThumbnailCollectionView.frame.size.height);
    }
    _thumbnailCache = [NSMutableDictionary dictionary];
    
    // Set up Cover Image
    _coverImageView = [[UIImageView alloc] initWithFrame:self.videoPlayBackView.bounds];
    _coverImageView.image = [self generateThumbnailByTime:0];
    [self.videoPlayBackView addSubview:_coverImageView];
    
    [self.videoPlayBackView bringSubviewToFront:self.videoPlayButton];
    
    // Set up Thumbnails
    
    if (CMTimeGetSeconds(_originalVideoAsset.duration) < MAX_TIME_RANGE) {
        _timePerFrame = CMTimeGetSeconds(_originalVideoAsset.duration);
    } else {
        CGSize rect = self.videoThumbnailCollectionView.frame.size;
        CGFloat numberOfThumbnails = (rect.width / rect.height);
        _timePerFrame = MAX_TIME_RANGE / numberOfThumbnails;
    }
    
    NSMutableArray* _timeArray = [NSMutableArray array];
    NSInteger numberOfImgs = CMTimeGetSeconds(_originalVideoAsset.duration) / _timePerFrame;
    
    for (int i = 0; i < numberOfImgs; i++) {
        [_timeArray addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(i*_timePerFrame, _originalVideoAsset.duration.timescale)]];
    }
    _reqTimeArray = _timeArray;
    
    [_thumbnailImageGenerator generateCGImagesAsynchronouslyForTimes:_reqTimeArray completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,AVAssetImageGeneratorResult result, NSError *error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            
            UIImage* imageView = [[UIImage alloc] initWithCGImage:image];
            int imageNo = [_reqTimeArray indexOfObject:[NSValue valueWithCMTime:requestedTime]];
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
    return [[UIImage alloc] initWithCGImage:[_thumbnailImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(timePoint, _originalVideoAsset.duration.timescale) actualTime:&actualTime error:&error]];
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


#pragma mark - Button Event Handler

- (IBAction)startPlayVideoAction:(id)sender {
    _coverImageView.alpha = 0.0f;
    self.videoPlayButton.alpha = 0.0f;
    [_videoPlayer play];
    
}
@end
