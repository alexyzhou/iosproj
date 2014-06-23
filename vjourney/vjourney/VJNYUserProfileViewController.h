//
//  VJNYUserProfileViewController.h
//  vjourney
//
//  Created by alex on 14-6-23.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYDataCache.h"
#import "ASIHttpRequest.h"

@interface VJNYUserProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerContainerView;
@property (strong, nonatomic) NSNumber* userId;
@end
