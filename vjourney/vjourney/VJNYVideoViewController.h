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

@interface VJNYVideoViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate> {
    NSInteger _channelID;
    NSString* _channelName;
}
@property (weak, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

- (IBAction)longPressHandler:(id)sender;

-(void)initWithChannelID:(NSInteger)channelID andName:(NSString*)name;

@end
