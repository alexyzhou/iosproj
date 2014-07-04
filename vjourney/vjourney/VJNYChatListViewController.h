//
//  VJNYChatListViewController.h
//  vjourney
//
//  Created by alex on 14-6-27.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYDataCache.h"
#import "ASIHTTPRequest.h"
#import "VJNYInboxViewController.h"

@interface VJNYChatListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) id<VJNYInboxSlideDelegate> slideDelegate;
- (IBAction)showSliderAction:(id)sender;

@end
