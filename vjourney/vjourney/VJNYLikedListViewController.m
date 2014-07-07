//
//  VJNYLikedListViewController.m
//  vjourney
//
//  Created by alex on 14-7-8.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYLikedListViewController.h"
#import "VJNYUserProfileViewController.h"
#import "VJNYVideoThumbnailViewCell.h"
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"

@interface VJNYLikedListViewController () {
    NSMutableArray* _userIdArray;
    NSMutableDictionary* _userAvatarDic;
}

@end

@implementation VJNYLikedListViewController

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
    _userIdArray = [NSMutableArray array];
    _userAvatarDic = [NSMutableDictionary dictionary];
    
    self.likedTitleLabel.font = [VJNYUtilities customFontWithSize:14.0f];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [VJNYHTTPHelper getJSONRequest:[@"video/likeList/" stringByAppendingString:[_videoId stringValue]] WithParameters:nil AndDelegate:self];
    [VJNYUtilities initEditingBgImageForNaviBarWithTabView:self.navigationController];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [VJNYUtilities initBgImageForNaviBarWithTabView:self.navigationController];
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
    return [_userIdArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VJNYVideoThumbnailViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VJNYUtilities likedUserCellIdentifier] forIndexPath:indexPath];
    
    NSString* avatarUrl = [_userAvatarDic objectForKey:[_userIdArray objectAtIndex:indexPath.row]];
    
    [VJNYDataCache loadImage:cell.imageView WithUrl:[VJNYHTTPHelper checkAndSetPathUrlByAppendPrefixWithValue:avatarUrl] AndMode:0 AndIdentifier:indexPath AndDelegate:self];
    
    [VJNYUtilities addRoundMaskForUIView:cell.imageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardUserProfilePage]];
    
    VJNYUserProfileViewController* profileController = [controller.viewControllers  objectAtIndex:0];
    profileController.userId = [_userIdArray objectAtIndex:indexPath.row];
    profileController.pushed = YES;
    
    [self presentViewController:controller animated:YES completion:nil];
    
}

#pragma mark - Cache Delegate

- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    
    if (mode == 0) {
        if ([[self.collectionView indexPathsForVisibleItems] containsObject:identifier]) {
            VJNYVideoThumbnailViewCell* cell = (VJNYVideoThumbnailViewCell*)[self.collectionView cellForItemAtIndexPath:identifier];
            cell.imageView.image = data;
        }
    }
}

#pragma mark - HTTP Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"video/LikeList"]) {
        if (result.result == Success) {
            [_userIdArray removeAllObjects];
            [_userAvatarDic removeAllObjects];
            for (NSMutableDictionary* dic in result.response) {
                
                [_userIdArray addObject:[dic objectForKey:@"id"]];
                [_userAvatarDic setObject:[dic objectForKey:@"avatarUrl"] forKey:[_userIdArray lastObject]];
                
            }
            [self.collectionView reloadData];
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
