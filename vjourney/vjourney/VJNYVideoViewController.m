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
    
    if (_longPressRecognizer.state == UIGestureRecognizerStateEnded) {
        _isDragging = false;
        return;
    }
    
    if (_isDragging) {
        return;
    } else {
        _isDragging = true;
        CGPoint p = [_longPressRecognizer locationInView:self.videoCollectionView];
        
        NSIndexPath *indexPath = [self.videoCollectionView indexPathForItemAtPoint:p];
        if (indexPath == nil){
            NSLog(@"couldn't find index path");
        } else {
            // get the cell at indexPath (the one you long pressed)
            
            VJNYPOJOVideo* video = [_videoData objectAtIndex:indexPath.row];
            
            [self playVideo:video.url];
            
        }
    }
}

#pragma mark - Video Playback Handler

- (void)playVideo:(NSString*)url {
    NSLog(@"Video Playback: %@",url);
    // 3 - Play the video
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
    [self presentMoviePlayerViewControllerAnimated:theMovie];
    // 4 - Register for the playback finished notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    _isDragging = false;
}

// When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    [self dismissMoviePlayerViewControllerAnimated];
    MPMoviePlayerController* theMovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}

-(void)initWithChannelID:(NSInteger)channelID andName:(NSString*)name {
    _channelID = channelID;
    _channelName = name;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _channelName;
    _isDragging = false;
    
    // 1.初始化数据
    _videoData = [NSMutableArray array];
    _userData = [NSMutableDictionary dictionary];
    
    self.videoCollectionView.backgroundColor = [UIColor clearColor];
    self.videoCollectionView.contentInset = UIEdgeInsetsMake(5.0f, 4.0f, 5.0f, 4.0f);
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"HH:mm,yyyy-MM-dd"];
    
    [VJNYHTTPHelper getJSONRequest:[NSString stringWithFormat:@"video/latest/%d",_channelID] WithParameters:nil AndDelegate:self];
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
    VJNYPOJOUser* ownerUser = [_userData objectForKey:[NSNumber numberWithInt:[video userId]]];
    
    cell.nameView.text = ownerUser.name;
    cell.timeView.text = [_dateFormatter stringFromDate:video.time];
    cell.descriptionView.text = video.description;
    
    [self loadImage:cell.avatarView WithUrl:ownerUser.avatarUrl AndMode:0 AndIdentifier:indexPath];
    [self loadImage:cell.coverView WithUrl:video.coverUrl AndMode:1 AndIdentifier:indexPath];
    
    cell.contentView.layer.borderColor = [[UIColor purpleColor] CGColor];//[[UIColor colorWithRed:1 green: 0.6 blue:0.8 alpha:1] CGColor];
    cell.contentView.layer.borderWidth = 1.0f;
    
    cell.layer.shadowOffset = CGSizeMake(3.0f, 2.0f);
    cell.layer.shadowRadius = 3.0f;
    cell.layer.shadowOpacity = 0.8f;
    cell.layer.masksToBounds = NO;
    
    return cell;
}

/*-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(140, collectionView.frame.size.height-10);
}*/

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

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
                if ([_userData objectForKey:[NSNumber numberWithInt:user.uid]]==nil) {
                    [_userData setObject:user forKey:[NSNumber numberWithInt:user.uid]];
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
