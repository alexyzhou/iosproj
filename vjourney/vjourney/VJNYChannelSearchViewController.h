//
//  VJNYChannelSearchViewController.h
//  vjourney
//
//  Created by alex on 14-7-8.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYDataCache.h"
#import "ASIHTTPRequest.h"

#define ADD_NEW_CHANNEL_FONTSIZE 15

@interface VJNYChannelSearchViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)cancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *addNewChannelView;
@property (weak, nonatomic) IBOutlet UILabel *addNewChannelLabel1;
@property (weak, nonatomic) IBOutlet UILabel *addNewChannelLabel2;
@property (weak, nonatomic) IBOutlet UILabel *addNewChannelLabel3;
- (IBAction)addNewChannelAction:(id)sender;

@end
