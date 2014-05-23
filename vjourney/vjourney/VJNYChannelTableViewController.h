//
//  VJNYChannelTableViewController.h
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "VJNYPOJOChannel.h"
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYHTTPResultCode.h"

@interface VJNYChannelTableViewController : UITableViewController<MJRefreshBaseViewDelegate, ASIHTTPRequestDelegate>
@property(nonatomic,weak) UIViewController* parent;
@end
