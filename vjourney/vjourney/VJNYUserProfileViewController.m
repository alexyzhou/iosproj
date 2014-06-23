//
//  VJNYUserProfileViewController.m
//  vjourney
//
//  Created by alex on 14-6-23.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYUserProfileViewController.h"
#import "VJNYProfileHeadTableViewCell.h"
#import "VJNYProfileVideoTableViewCell.h"
#import "VJNYPOJOVideo.h"
#import "VJNYPOJOUser.h"
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"

@interface VJNYUserProfileViewController () {
    NSMutableArray* _videoData;
    VJNYPOJOUser* _myUser;
    NSNumber* _storyCount;
    NSNumber* _totalLike;
    VJNYPOJOVideo* _hotVideo;
    
}

@end

@implementation VJNYUserProfileViewController

@synthesize userId=_userId;

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
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 49.0f, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 49.0f, 0)];
    
    _myUser = nil;
    _storyCount = nil;
    _totalLike = nil;
    _hotVideo = nil;
    _videoData = [NSMutableArray array];
    
    // Fetch Data
    // User Info
    [VJNYHTTPHelper getJSONRequest:[@"user/info/" stringByAppendingString:[_userId stringValue]] WithParameters:nil AndDelegate:self];
    // Video Count
    [VJNYHTTPHelper getJSONRequest:[@"video/countByUser/" stringByAppendingString:[_userId stringValue]] WithParameters:nil AndDelegate:self];
    // Videos
    [VJNYHTTPHelper getJSONRequest:[@"video/latest/user/" stringByAppendingString:[_userId stringValue]] WithParameters:nil AndDelegate:self];
    // Hot Video
    [VJNYHTTPHelper getJSONRequest:[@"video/hot/user/" stringByAppendingString:[_userId stringValue]] WithParameters:nil AndDelegate:self];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_videoData count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        VJNYProfileHeadTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:[VJNYUtilities profileHeadCellIdentifier]];
        
        cell.videoPlayer = nil;
        
        [self initMyUser];
        [self initVideoCountAndLike];
        //[self playPopularVideo];
        return cell;
    } else {
        
        VJNYProfileVideoTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:[VJNYUtilities profileVideoCellIdentifier]];
        cell.videoPlayer = nil;
        VJNYPOJOVideo* video = [_videoData objectAtIndex:indexPath.row-1];
        [VJNYDataCache loadImage:cell.videoCoverImageView WithUrl:video.coverUrl AndMode:1 AndIdentifier:indexPath AndDelegate:self];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 360;
    } else {
        return 161;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    CGFloat scrollValue = scrollView.contentOffset.y;
    
    if (scrollValue > cell.videoPlayerContainerView.bounds.size.height) {
        [cell stopPlayVideo];
    } else {
        [cell startPlayVideoWithURL:[NSURL URLWithString:[_hotVideo url]]];
    }
    
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > 0) {
        VJNYProfileVideoTableViewCell* cell = (VJNYProfileVideoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        VJNYPOJOVideo* video = [_videoData objectAtIndex:indexPath.row-1];
        [cell startPlayOrStopVideoWithURL:[NSURL URLWithString:video.url]];
    }
}*/

#pragma mark - Cache Handler
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    
    if (mode == 0) {
        // My User Avatar
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.userAvatarImageView.image = data;
    } else if (mode == 1) {
        NSIndexPath* indexPath = identifier;
        VJNYProfileVideoTableViewCell* cell = (VJNYProfileVideoTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.videoCoverImageView.image = data;
    }
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([result.action isEqualToString:@"user/Info"]) {
            if (result.result == Success) {
                _myUser = result.response;
                [self initMyUser];
            }
        } else if ([result.action isEqualToString:@"video/CountByUser"]) {
            if (result.result == Success) {
                _storyCount = [result.response objectForKey:@"count"];
                _totalLike = [result.response objectForKey:@"like_count"];
                [self initVideoCountAndLike];
            }
        } else if ([result.action isEqualToString:@"video/Latest/User"]) {
            if (result.result == Success) {
                _videoData = result.response;
                [self.tableView reloadData];
            }
        } else if ([result.action isEqualToString:@"video/Hot/User"]) {
            if (result.result == Success) {
                _hotVideo = result.response;
                [self playPopularVideo];
            }
        }
    });
    
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

- (void)initMyUser {
    
    VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (_myUser != nil) {
        cell.userNameLabel.text = _myUser.name;
        cell.userDescriptionLabel.text = @"Artist of Life";
        [VJNYDataCache loadImage:cell.userAvatarImageView WithUrl:_myUser.avatarUrl AndMode:0 AndIdentifier:[NSIndexPath indexPathForRow:0 inSection:0] AndDelegate:self];
    }
}

- (void)initVideoCountAndLike {
    VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (_storyCount != nil) {
        cell.storyCountLabel.text = [_storyCount stringValue];
    }
    if (_totalLike != nil) {
        cell.likeCountLabel.text = [_totalLike stringValue];
    }
}

- (void)playPopularVideo {
    VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (_hotVideo != nil) {
        if ([[self.tableView visibleCells] containsObject:cell]) {
            [cell startPlayVideoWithURL:[NSURL URLWithString:_hotVideo.url]];
        }
    }
}

@end
