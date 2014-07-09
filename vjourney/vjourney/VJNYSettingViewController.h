//
//  VJNYSettingViewController.h
//  vjourney
//
//  Created by alex on 14-7-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VJNYInboxViewController.h"

@interface VJNYSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
- (IBAction)showSliderAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingOtherLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) id<VJNYInboxSlideDelegate> slideDelegate;

@end
