//
//  VJNYVideoViewController.h
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYDataCache.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYHTTPResultCode.h"
#import "VJNYVideoCaptureViewController.h"

@interface VJNYVideoViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate,VJNYVideoUploadDelegate> {
    NSNumber* _channelID;
    NSString* _channelName;
    int _isFollow;
}
@property (weak, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

- (IBAction)longPressHandler:(id)sender;
- (void)clickToFollowAction:(UIBarButtonItem *)sender;
- (void)clickToUploadAction:(UIBarButtonItem *)sender;

-(void)initWithChannelID:(NSNumber*)channelID andName:(NSString*)name andIsFollow:(int)follow;

@end
