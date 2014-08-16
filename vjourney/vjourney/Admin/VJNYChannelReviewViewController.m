//
//  VJNYChannelReviewViewController.m
//  vjourney
//
//  Created by alex on 14-8-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYChannelReviewViewController.h"
#import "VJNYChannelReviewCell.h"
#import "VJNYUtilities.h"
#import "VJNYDataCache.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"

#import "VJNYPOJOChannel.h"
#import "VJNYPOJOUser.h"

@interface VJNYChannelReviewViewController () {
    NSMutableArray* _channelArray;
}

@end

@implementation VJNYChannelReviewViewController

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
    
    _channelArray = [NSMutableArray array];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [VJNYPOJOUser insertAdminToDirectory:dic];
    
    [VJNYHTTPHelper sendJSONRequest:@"channel/review/get" WithParameters:dic AndDelegate:self];
    
    [VJNYUtilities showProgressAlertViewToView:self.navigationController.view];
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
    return [_channelArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    VJNYChannelReviewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VJNYUtilities adminChannelReviewCellIdentifier] forIndexPath:indexPath];
    
    VJNYPOJOChannel* channel = [_channelArray objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = channel.name;
    cell.descriptionLabel.text = channel.description;
    
    cell.delegate = self;
    cell.channelId = channel.cid;
    
    [VJNYDataCache loadImage:cell.coverImageView WithUrl:channel.coverUrl AndMode:0 AndIdentifier:indexPath AndDelegate:self];
    
    return cell;
}

#pragma mark - Cache Handler
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    
    if (mode == 0) {
        NSIndexPath* path = (NSIndexPath*)identifier;
        
        VJNYChannelReviewCell* cell = (VJNYChannelReviewCell*)[self.collectionView cellForItemAtIndexPath:path];
        cell.coverImageView.image = data;
        
    }
    
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    
    NSLog(@"%@",result.action);
    if (result.result == Success) {
        NSLog(@"succeed!");
    }
    
    if ([result.action isEqualToString:@"channel/Review"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [VJNYUtilities dismissProgressAlertViewFromView:self.navigationController.view];
            if (result.result == Success) {
                _channelArray = result.response;
                [self.collectionView reloadData];
                //[self.channelView reloadData];
            }
        });
        
        
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

- (IBAction)refreshAction:(id)sender {
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [VJNYPOJOUser insertAdminToDirectory:dic];
    
    [VJNYHTTPHelper sendJSONRequest:@"channel/review/get" WithParameters:dic AndDelegate:self];
    
    [VJNYUtilities showProgressAlertViewToView:self.navigationController.view];
    
}

#pragma mark - VJNY Admin ChannelReview Delegate
- (void)channelAcceptActionWithID:(NSNumber *)cid {
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [VJNYPOJOUser insertAdminToDirectory:dic];
    [dic setObject:[cid stringValue] forKey:@"id"];
    
    [VJNYHTTPHelper sendJSONRequest:@"channel/review/accept" WithParameters:dic AndDelegate:self];
    int i = 0;
    for (; i < [_channelArray count]; i++) {
        if ([((VJNYPOJOChannel*)[_channelArray objectAtIndex:i]).cid isEqualToNumber:cid]) {
            break;
        }
    }
    [_channelArray removeObjectAtIndex:i];
    [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
}
- (void)channelRejectActionWithID:(NSNumber *)cid {
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [VJNYPOJOUser insertAdminToDirectory:dic];
    [dic setObject:[cid stringValue] forKey:@"id"];
    
    [VJNYHTTPHelper sendJSONRequest:@"channel/review/reject" WithParameters:dic AndDelegate:self];
    int i = 0;
    for (; i < [_channelArray count]; i++) {
        if ([((VJNYPOJOChannel*)[_channelArray objectAtIndex:i]).cid isEqualToNumber:cid]) {
            break;
        }
    }
    [_channelArray removeObjectAtIndex:i];
    [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
}

@end
