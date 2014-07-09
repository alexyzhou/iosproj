//
//  VJNYSettingPrivacyViewController.h
//  vjourney
//
//  Created by alex on 14-7-10.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface VJNYSettingPrivacyViewController : UITableViewController<ASIHTTPRequestDelegate>

- (IBAction)topicPrivacyChangedAction:(UISwitch *)sender;

- (IBAction)videoPrivacyChangedAction:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UISwitch *videoPrivacySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *topicPrivacySwitch;

@end
