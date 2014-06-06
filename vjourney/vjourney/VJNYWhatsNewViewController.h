//
//  VJNYWhatsNewViewController.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYVideoViewController.h"
#import "TKCoverflowView.h"
#import "MJRefresh.h"
#import "VJNYPOJOChannel.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYHTTPResultCode.h"
#import "VJNYChannelTableViewCell.h"
#import "VJNYPromoChannelTableViewCell.h"
#import "VJNYChannelCoverFlowCellView.h"
#import "VJNYDataCache.h"

@interface VJNYWhatsNewViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate, ASIHTTPRequestDelegate,VJNYDataCacheDelegate,TKCoverflowViewDelegate,TKCoverflowViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *channelView;

- (IBAction)searchChannelAction:(id)sender;
- (IBAction)segmentedFilterClickAction:(id)sender;

+(VJNYWhatsNewViewController*)instance;

@end
