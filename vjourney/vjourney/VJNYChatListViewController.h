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

@interface VJNYChatListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchBarCancelButton;

@property (strong, nonatomic) id<VJNYInboxSlideDelegate> slideDelegate;
- (IBAction)showSliderAction:(id)sender;
- (IBAction)cancelSearchAction:(id)sender;

@end
