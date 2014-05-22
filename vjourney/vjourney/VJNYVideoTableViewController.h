//
//  VJNYVideoTableViewController.h
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "VJNYUtilities.h"
#import "VJNYPOJOVideo.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYHTTPResultCode.h"

@interface VJNYVideoTableViewController : UITableViewController<MJRefreshBaseViewDelegate, ASIHTTPRequestDelegate>
@property(nonatomic) NSInteger fetchMode;
@property(nonatomic) NSInteger channelId;
@end
