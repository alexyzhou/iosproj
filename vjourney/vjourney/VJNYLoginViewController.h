//
//  VJNYLoginViewController.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYBaseViewController.h"
#import "VJNYPOJOUser.h"
#import "VJNYUploadViewController.h"

@interface VJNYLoginViewController : VJNYBaseViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
- (IBAction)loginAction:(id)sender;
@end
