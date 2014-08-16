//
//  VJNYChannelReviewViewController.h
//  vjourney
//
//  Created by alex on 14-8-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "VJNYDataCache.h"
#import "VJNYAdminProtocols.h"

@interface VJNYChannelReviewViewController : UIViewController<ASIHTTPRequestDelegate,VJNYDataCacheDelegate,UICollectionViewDataSource,UICollectionViewDelegate,VJNYAdminChannelReviewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)refreshAction:(id)sender;

- (void)channelAcceptActionWithID:(NSNumber *)cid;
- (void)channelRejectActionWithID:(NSNumber *)cid;

@end
