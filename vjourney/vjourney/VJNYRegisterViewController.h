//
//  VJNYRegisterViewController.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYBaseViewController.h"

@interface VJNYRegisterViewController : VJNYBaseViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
- (IBAction)registerAction:(id)sender;

@end
