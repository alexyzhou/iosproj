//
//  VJNYSysNotifViewController.h
//  vjourney
//
//  Created by alex on 14-6-28.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "VJNYDataCache.h"
#import "VJNYInboxViewController.h"

@interface VJNYSysNotifViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,VJNYDataCacheDelegate>
- (IBAction)sideAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *sysNotifTableView;

@property (strong, nonatomic) id<VJNYInboxSlideDelegate> slideDelegate;

@end
