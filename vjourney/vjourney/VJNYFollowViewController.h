//
//  VJNYFollowViewController.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYVideoViewController.h"
#import "MJRefresh.h"
#import "VJNYPOJOChannel.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYHTTPResultCode.h"
#import "VJNYFollowChannelTableViewCell.h"
#import "VJNYDataCache.h"

@interface VJNYFollowViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate, ASIHTTPRequestDelegate,VJNYDataCacheDelegate>

@property (weak, nonatomic) IBOutlet UITableView *channelView;

@end
