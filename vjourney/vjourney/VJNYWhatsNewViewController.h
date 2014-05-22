//
//  VJNYWhatsNewViewController.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYBaseViewController.h"
#import "VJNYChannelTableViewController.h"
#import "VJNYVideoViewController.h"

@interface VJNYWhatsNewViewController : VJNYBaseViewController<UITableViewDelegate> {
    VJNYChannelTableViewController* _channelController;
}
@property (weak, nonatomic) IBOutlet UIView *specialEventView;
@property (weak, nonatomic) IBOutlet UIView *channelListView;
- (IBAction)searchChannelAction:(id)sender;

+(VJNYWhatsNewViewController*)instance;
-(void)enterVideoPageByChannelID:(NSInteger)channelID AndTitle:(NSString*)name;

@end
