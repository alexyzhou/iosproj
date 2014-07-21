//
//  VJNYUserProfileViewController.m
//  vjourney
//
//  Created by alex on 14-6-23.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYUserProfileViewController.h"
#import "VJNYVideoViewController.h"
#import "VJNYChatViewController.h"
#import "VJNYProfileHeadTableViewCell.h"
#import "VJNYProfileVideoTableViewCell.h"
#import "VJNYChannelTableViewCell.h"
#import "VJNYPOJOVideo.h"
#import "VJNYPOJOUser.h"
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"

#import "VJDMModel.h"
#import "VJDMUser.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "VPImageCropperViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>



@interface VJNYUserProfileViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,VPImageCropperDelegate> {
    NSMutableArray* _videoData;
    NSMutableDictionary* _channelInfoForVideo;
    NSMutableDictionary* _likeVideoDic;
    NSMutableArray* _channelData;
    VJNYPOJOUser* _myUser;
    NSNumber* _storyCount;
    NSNumber* _channelCount;
    NSNumber* _totalLike;
    
    NSNumber* _videoIdToDelete;
    
    NSMutableArray* _cellPlayingToStop;
    
    BOOL _isUploadingCover;
    BOOL _hasConfiguredTableHead;
    BOOL _isVideoListMode;
    
    UIView* _uploadBannerView;
}

@end

@implementation VJNYUserProfileViewController

@synthesize userId=_userId;
@synthesize pushed=_pushed;

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
    
    [self.tabBarController setHidesBottomBarWhenPushed:YES];
    self.navigationController.delegate = self;
    _uploadBannerView = nil;
    _isVideoListMode = true;
    
    [VJNYUtilities initBgImageForNaviBarWithTabView:self.navigationController];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 49.0f, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 49.0f, 0)];
    
    _myUser = nil;
    _storyCount = nil;
    _totalLike = nil;
    _channelCount = nil;
    _videoData = [NSMutableArray array];
    _channelData = [NSMutableArray array];
    _channelInfoForVideo = [NSMutableDictionary dictionary];
    _likeVideoDic = [NSMutableDictionary dictionary];
    
    // Fetch Data
    // User Info
    [VJNYHTTPHelper getJSONRequest:[@"user/info/" stringByAppendingString:[_userId stringValue]] WithParameters:nil AndDelegate:self];
    // Video Count
    [VJNYHTTPHelper getJSONRequest:[@"video/countByUser/" stringByAppendingString:[_userId stringValue]] WithParameters:nil AndDelegate:self];
    
    
    if ([_userId isEqualToNumber:[VJNYPOJOUser sharedInstance].uid]) {
        // myself
        NSLog(@"myself!");
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
        [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
        
        [VJNYHTTPHelper sendJSONRequest:@"video/latest/user" WithParameters:dic AndDelegate:self];
        [VJNYHTTPHelper sendJSONRequest:@"channel/latest/user" WithParameters:dic AndDelegate:self];
    } else {
        NSLog(@"other:%d",[_userId intValue]);
        // Videos
        [VJNYHTTPHelper getJSONRequest:[@"video/latest/user/" stringByAppendingString:[_userId stringValue]] WithParameters:nil AndDelegate:self];
        // Channels
        [VJNYHTTPHelper getJSONRequest:[@"channel/latest/user/" stringByAppendingString:[_userId stringValue]] WithParameters:nil AndDelegate:self];
    }
    
    // Channel Count
    [VJNYHTTPHelper getJSONRequest:[@"channel/countByUser/" stringByAppendingString:[_userId stringValue]] WithParameters:nil AndDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    if (_isVideoListMode) {
        VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell stopPlayVideo];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    if ([[navigationController viewControllers] objectAtIndex:0] != viewController) {
        if ([self.tabBarController hidesBottomBarWhenPushed]) {
            [self.tabBarController.tabBar setHidden:YES];
        }
    } else {
        [self.tabBarController.tabBar setHidden:NO];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isVideoListMode) {
        return [_videoData count] + 1;
    } else {
        return [_channelData count] + 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        VJNYProfileHeadTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:[VJNYUtilities profileHeadCellIdentifier]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.videoPlayer = nil;
        
        [VJNYUtilities addRoundMaskForUIView:cell.userAvatarImageView];
        
        [self initMyUser];
        [self initVideoCountAndLike];
        
        if (!_hasConfiguredTableHead) {
            
            if ([_userId isEqualToNumber:[VJNYPOJOUser sharedInstance].uid]) {
                
                UITapGestureRecognizer* coverGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeUserCoverAction:)];
                [cell.userCoverImageView addGestureRecognizer:coverGesture];
                [cell.userCoverImageView setUserInteractionEnabled:YES];
                
                UITapGestureRecognizer* avatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeUserAvatarAction:)];
                [cell.userAvatarImageView addGestureRecognizer:avatarGesture];
                [cell.userAvatarImageView setUserInteractionEnabled:YES];
                
                [cell.chatImageView setHidden:YES];
                
            } else {
                
                UITapGestureRecognizer* chatGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChat)];
                [cell.chatImageView addGestureRecognizer:chatGesture];
                [cell.chatImageView setUserInteractionEnabled:YES];
            }
            
            UITapGestureRecognizer* topicGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeToTopicMode)];
            [cell.topicCountLabel addGestureRecognizer:topicGesture];
            [cell.topicCountLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer* videoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeToVideoListMode)];
            [cell.storyCountLabel addGestureRecognizer:videoGesture];
            [cell.storyCountLabel setUserInteractionEnabled:YES];
            
            if (!_pushed) {
                [cell.backButtonImageView setHidden:YES];
            } else {
                //[VJNYUtilities addShadowForUIView:cell.backButtonImageView WithOffset:CGSizeMake(2.0f, 2.0f) AndRadius:3.0f];
                UITapGestureRecognizer* backGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToBackAction:)];
                [cell.backButtonImageView addGestureRecognizer:backGesture];
                [cell.backButtonImageView setUserInteractionEnabled:YES];
            }
            
            _hasConfiguredTableHead = true;
        }
        
        return cell;
    } else {
        
        if (_isVideoListMode) {
            
            VJNYProfileVideoTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:[VJNYUtilities profileVideoCellIdentifier]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            
            cell.videoPlayer = nil;
            VJNYPOJOVideo* video = [_videoData objectAtIndex:indexPath.row-1];
            [VJNYDataCache loadImage:cell.videoCoverImageView WithUrl:video.coverUrl AndMode:1 AndIdentifier:indexPath AndDelegate:self];
            
            cell.videoDescriptionLabel.text = video.description;
            cell.videoTimeLabel.text = [VJNYUtilities formatDataString:video.time];
            
            cell.videoId = video.vid;
            
            VJNYPOJOChannel* channel = [_channelInfoForVideo objectForKey:video.channelId];
            //cell.channelNameLabel.titleLabel.text = channel.name;
            [cell.channelNameLabel setTitle:channel.name forState:UIControlStateNormal];
            [VJNYDataCache loadImage:cell.channelCoverImageView WithUrl:channel.coverUrl AndMode:3 AndIdentifier:indexPath AndDelegate:self];
            
            cell.channelId = channel.cid;
            
            [cell.videoDeleteButton setHidden:![_userId isEqualToNumber:[VJNYPOJOUser sharedInstance].uid]];
            
            NSNumber* likedValue = [_likeVideoDic objectForKey:video.vid];
            
            if (likedValue == nil) {
                [cell.videoLikeButton setEnabled:NO];
                [VJNYHTTPHelper sendJSONRequest:@"video/isLike" WithParameters:[self genUserVideoRequestDicWithVideoID:video.vid] AndDelegate:self];
            } else {
                [cell.videoLikeButton setEnabled:YES];
                [cell.videoLikeButton setSelected:[likedValue boolValue]];
            }
            
            return cell;
            
        } else {
            
            VJNYChannelTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[VJNYUtilities channelCellIdentifier]];
            
            VJNYPOJOChannel *channel = [_channelData objectAtIndex:indexPath.row-1];
            
            cell.bgMaskView.layer.cornerRadius = 5;
            cell.bgMaskView.layer.masksToBounds = YES;
            
            cell.image.layer.cornerRadius = 5;
            cell.image.layer.masksToBounds = YES;
            
            // Set up the cell...
            NSString* imageUrl = channel.coverUrl;
            UIImage* imageData = [[VJNYDataCache instance] dataByURL:imageUrl];
            if (imageData == nil) {
                [[VJNYDataCache instance] requestDataByURL:imageUrl WithDelegate:self AndIdentifier:indexPath AndMode:0];
                cell.image.image = nil;
            } else {
                cell.image.image = imageData;
            }
            cell.title.text = channel.name;
            return cell;
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isVideoListMode) {
        
        if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
        {
            // This indeed is an indexPath no longer visible
            // Do something to this non-visible cell...
            if (indexPath.row > 0) {
                [(VJNYProfileVideoTableViewCell*)cell stopPlayVideo];
            }
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 360;
    } else {
        if (_isVideoListMode) {
            return 421;
        } else {
            return 61;
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > 0) {
        
        if (_isVideoListMode) {
            
            VJNYProfileVideoTableViewCell* cell = (VJNYProfileVideoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            VJNYPOJOVideo* video = [_videoData objectAtIndex:indexPath.row-1];
            [cell startPlayOrStopVideoWithURL:[NSURL URLWithString:video.url]];
            
        } else {
            
            VJNYPOJOChannel* channel = [_channelData objectAtIndex:indexPath.row-1];
            
            VJNYVideoViewController *videoViewController = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardVideoListPage]];
            [videoViewController initWithChannel:channel andIsFollow:-1];
            
            [self.navigationController pushViewController:videoViewController animated:YES];
            
        }
        
        
    }
    
}

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
    } else if (mode == 2) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.userCoverImageView.image = data;
    } else if (mode == 3) {
        NSIndexPath* indexPath = identifier;
        VJNYProfileVideoTableViewCell* cell = (VJNYProfileVideoTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.channelCoverImageView.image = data;
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
                [_videoData removeAllObjects];
                [_channelInfoForVideo removeAllObjects];
                for (NSArray* arr in result.response) {
                    VJNYPOJOVideo* video = [arr objectAtIndex:0];
                    [_videoData addObject:video];
                    VJNYPOJOChannel* channel = [arr objectAtIndex:1];
                    if ([_channelInfoForVideo objectForKey:channel.cid]==nil) {
                        [_channelInfoForVideo setObject:channel forKey:channel.cid];
                    }
                }
                [self.tableView reloadData];
            }
        } else if ([result.action isEqualToString:@"channel/CountByUser"]) {
            if (result.result == Success) {
                _channelCount = [result.response objectForKey:@"count"];
                [self initVideoCountAndLike];
            }
        } else if ([result.action isEqualToString:@"user/Avatar/Update"] || [result.action isEqualToString:@"user/Cover/Update"]) {
            
            [UIView animateWithDuration:0.5f animations:^{
                [_uploadBannerView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [_uploadBannerView removeFromSuperview];
                _uploadBannerView = nil;
            }];
            if (result.result == Success) {
                
                VJDMUser* user = (VJDMUser*)[VJDMModel sharedInstance].getCurrentUser;
                if (user != nil) {
                    
                    NSString* url = result.response[@"url"];
                    
                    if ([result.action isEqualToString:@"user/Avatar/Update"]) {
                        user.avatars_url = url;
                    } else if ([result.action isEqualToString:@"user/Cover/Update"]) {
                        user.cover_url = url;
                    }
                    
                    [[VJDMModel sharedInstance] saveChanges];
                }
                
                
            } else {
                [VJNYUtilities showAlertWithNoTitle:[NSString stringWithFormat:@"Upload Failed!, Reason:%d",result.result]];
            }
        } else if ([result.action isEqualToString:@"channel/LatestByUser"]) {
            if (result.result == Success) {
                _channelData = result.response;
                if (_isVideoListMode == false) {
                    [self.tableView reloadData];
                }
            }
        } else if ([result.action isEqualToString:@"user/Avatar/Update"]) {
            if (result.result == Success) {
                NSString* url = [result.response objectForKey:@"url"];
                [VJNYPOJOUser sharedInstance].avatarUrl = url;
                VJDMUser* user = (VJDMUser*)[[VJDMModel sharedInstance] getCurrentUser];
                user.avatars_url = url;
                [[VJDMModel sharedInstance] saveChanges];
            }
        } else if ([result.action isEqualToString:@"user/Cover/Update"]) {
            if (result.result == Success) {
                NSString* url = [result.response objectForKey:@"url"];
                [VJNYPOJOUser sharedInstance].coverUrl = url;
                VJDMUser* user = (VJDMUser*)[[VJDMModel sharedInstance] getCurrentUser];
                user.cover_url = url;
                [[VJDMModel sharedInstance] saveChanges];
            }
        } else if ([result.action isEqualToString:@"video/IsLike"]) {
            if (result.result == Success) {
                NSNumber* video_id = [result.response objectForKey:@"videoId"];
                NSNumber* likedResult = [result.response objectForKey:@"result"];
                [_likeVideoDic setObject:likedResult forKey:video_id];
                
                if (_isVideoListMode) {
                    for (NSIndexPath* path in [self.tableView indexPathsForVisibleRows]) {
                        if (path.row > 0) {
                            VJNYPOJOVideo* video = [_videoData objectAtIndex:path.row-1];
                            VJNYProfileVideoTableViewCell* cell = (VJNYProfileVideoTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
                            if ([video.vid isEqualToNumber:video_id]) {
                                [cell.videoLikeButton setEnabled:YES];
                                [cell.videoLikeButton setSelected:[likedResult boolValue]];
                                break;
                            }
                        }
                    }
                }
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
    [UIView animateWithDuration:0.5f animations:^{
        [_uploadBannerView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [_uploadBannerView removeFromSuperview];
        _uploadBannerView = nil;
    }];
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

#pragma mark - Custom Methods

- (void)initMyUser {
    
    VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (_myUser != nil) {
        
        cell.userNameLabel.text = _myUser.name;
        
        CGRect textRect = [_myUser.name boundingRectWithSize:CGSizeMake(180.0f, 27.0f)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0f]}
                                                     context:nil];
        
        CGRect nameFrame = cell.userNameLabel.frame;
        nameFrame.size.width = textRect.size.width;
        nameFrame.origin.x = self.view.frame.size.width/2 - nameFrame.size.width/2;
        cell.userNameLabel.frame = nameFrame;
        
        cell.userDescriptionLabel.text = _myUser.description;
        
        [VJNYDataCache loadImage:cell.userAvatarImageView WithUrl:_myUser.avatarUrl AndMode:0 AndIdentifier:[NSIndexPath indexPathForRow:0 inSection:0] AndDelegate:self];
        [VJNYDataCache loadImage:cell.userCoverImageView WithUrl:_myUser.coverUrl AndMode:2 AndIdentifier:[NSIndexPath indexPathForRow:0 inSection:0] AndDelegate:self];
    }
}

- (void)initVideoCountAndLike {
    VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (_storyCount != nil) {
        cell.storyCountLabel.text = [_storyCount stringValue];
    } else {
        cell.storyCountLabel.text = @"0";
    }
    if (_totalLike != nil) {
        cell.likeCountLabel.text = [_totalLike stringValue];
    } else {
        cell.likeCountLabel.text = @"0";
    }
    if (_channelCount != nil) {
        cell.topicCountLabel.text = [_channelCount stringValue];
    } else {
        cell.topicCountLabel.text = @"0";
    }
}

- (IBAction)tapToChangeUserCoverAction:(UITapGestureRecognizer *)sender {
    
    if ([_userId isEqualToNumber:[VJNYPOJOUser sharedInstance].uid]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take a Picture", @"Choose from Camera", nil];
        actionSheet.tag = 100;
        _isUploadingCover = true;
        [actionSheet showInView:self.view];
    }
}

- (IBAction)tapToChangeUserAvatarAction:(UITapGestureRecognizer *)sender {
    
    if ([_userId isEqualToNumber:[VJNYPOJOUser sharedInstance].uid]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take a Picture", @"Choose from Camera", nil];
        actionSheet.tag = 200;
        _isUploadingCover = false;
        [actionSheet showInView:self.view];
    }
}

- (IBAction)tapToBackAction:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapToChangeToVideoListMode {
    if (_isVideoListMode == false) {
        _isVideoListMode = true;
        [self.tableView reloadData];
    }
}

- (void)tapToChangeToTopicMode {
    if (_isVideoListMode == true) {
        _isVideoListMode = false;
        [self.tableView reloadData];
    }
}

- (void)tapToChat {
    VJNYChatViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardChatDetailPage]];
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    controller.target_avatar = cell.userAvatarImageView.image;
    controller.target_id = _userId;
    controller.target_name = cell.userNameLabel.text;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        // 拍照
        if ([VJNYUtilities isCameraAvailable] && [VJNYUtilities doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([VJNYUtilities isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([VJNYUtilities isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
        }
    }
    
    //NSLog(@"Index = %ld - Title = %@", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    VJNYProfileHeadTableViewCell* cell = (VJNYProfileHeadTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (_isUploadingCover) {
        cell.userCoverImageView.image = editedImage;
        
    } else {
        cell.userAvatarImageView.image = editedImage;
    }
    
    //self.portraitImageView.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        [self uploadImage:UIImageJPEGRepresentation(editedImage,1.0f)];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Upload Delegate

- (void)uploadImage:(NSData*)coverData {
    
    //[VJNYUtilities showProgressAlertViewToView:self.view];
    
    ASIFormDataRequest *request;
    if (!_isUploadingCover) {
        request = [ASIFormDataRequest requestWithURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:@"user/avatar/update"]];
        [request addData:coverData withFileName:@"test.jpg" andContentType:@"image/jpeg" forKey:@"avatar"];
    } else {
        request = [ASIFormDataRequest requestWithURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:@"user/cover/update"]];
        [request addData:coverData withFileName:@"test.jpg" andContentType:@"image/jpeg" forKey:@"cover"];
    }
    
    // Success
    
    //[request setData:filedata forKey:@"file"];
    //[request setPostValue:@"test.mov" forKey:@"fileName"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    
    [dic setObject:[[NSNumber numberWithUnsignedInteger:coverData.length] stringValue] forKey:@"length"];
    
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    
    [request addPostValue:jsonString forKey:@"description"];
    
    [request setDelegate:self];
    [request startAsynchronous];
    
    [request setUploadProgressDelegate:self];
    
    // Set Upload Banner
    _uploadBannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    [_uploadBannerView setBackgroundColor:[UIColor blueColor]];
    [_uploadBannerView setAlpha:0.5f];
    [self.view addSubview:_uploadBannerView];
}

- (void)setProgress:(float)newProgress {
    NSLog(@"%f",newProgress);
    _uploadBannerView.frame = CGRectMake(0, 0, 320.0f*newProgress, 20);
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        portraitImg = [VJNYUtilities imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg fullFrame:self.view.frame cropFrame:CGRectMake(0, (self.view.frame.size.height-self.view.frame.size.width)/2.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0 orientation:portraitImg.imageOrientation];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}



#pragma mark - VJNYUserProfileVideo Delegate

- (NSMutableDictionary*)genUserVideoRequestDicWithVideoID:(NSNumber*)videoId {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    
    [dic setObject:[videoId stringValue] forKey:@"videoId"];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    return dic;
}

- (void)videoCell:(UITableViewCell*)cell DidSelectToLikeVideo:(NSNumber*)videoId {
    VJNYProfileVideoTableViewCell* vCell = (VJNYProfileVideoTableViewCell*)cell;
    
    if (vCell.videoLikeButton.selected == NO) {
        [vCell.videoLikeButton setSelected:YES];
    } else {
        [vCell.videoLikeButton setSelected:NO];
    }
    
    NSMutableDictionary* dic = [self genUserVideoRequestDicWithVideoID:videoId];
    
    [dic setObject:[[NSNumber numberWithBool:vCell.videoLikeButton.selected] stringValue] forKey:@"like"];
    [VJNYHTTPHelper sendJSONRequest:@"video/like" WithParameters:dic AndDelegate:self];
    [_likeVideoDic setObject:[NSNumber numberWithBool:vCell.videoLikeButton.selected] forKey:videoId];
    
}
- (void)videoCell:(UITableViewCell*)cell DidSelectToDeleteVideo:(NSNumber*)videoId {
    
    UIAlertView* view = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure to delete the video?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    view.tag = 100;
    [view show];
    _videoIdToDelete = videoId;
    
}
- (void)videoCell:(UITableViewCell *)cell DidSelectToEnterChannel:(NSNumber *)channelId {
    
    VJNYPOJOChannel* channel = [_channelInfoForVideo objectForKey:channelId];
    
    VJNYVideoViewController *videoViewController = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardVideoListPage]];
    [videoViewController initWithChannel:channel andIsFollow:-1];
    
    [self.navigationController pushViewController:videoViewController animated:YES];
    
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        //Cancel
        return;
    }
    
    if (alertView.tag == 100) {
        // delete video
        NSMutableDictionary* dic = [self genUserVideoRequestDicWithVideoID:_videoIdToDelete];
        [VJNYHTTPHelper sendJSONRequest:@"video/delete" WithParameters:dic AndDelegate:self];
        if (_isVideoListMode) {
            for (NSIndexPath* path in [self.tableView indexPathsForVisibleRows]) {
                if (path.row > 0) {
                    VJNYPOJOVideo* video = [_videoData objectAtIndex:path.row-1];
                    [_videoData removeObjectAtIndex:path.row-1];
                    [_likeVideoDic removeObjectForKey:video.vid];
                    if ([video.vid isEqualToNumber:_videoIdToDelete]) {
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
                        break;
                    }
                }
            }
        }
    }
}


@end
