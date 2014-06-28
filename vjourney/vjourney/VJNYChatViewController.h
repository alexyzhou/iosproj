//
//  VJNYChatViewController.h
//  vjourney
//
//  Created by alex on 14-6-27.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYDataCache.h"
#import "ASIHTTPRequest.h"

@interface VJNYChatViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate>
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (weak, nonatomic) IBOutlet UIView *toolbarContainerView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
- (IBAction)sendButtonAction:(id)sender;

@property (nonatomic, strong) UIImage* target_avatar;
@property (nonatomic, strong) NSNumber* target_id;
@property (nonatomic, strong) NSString* target_name;
@property (nonatomic, strong) NSString* target_avatar_url;

@end
