//
//  VJNYSettingAccountViewController.h
//  vjourney
//
//  Created by alex on 14-8-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface VJNYSettingAccountViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,ASIHTTPRequestDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UILabel *usernameCount;

@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UILabel *passwordCount;

@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UILabel *nameCount;

@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;

@property (weak, nonatomic) IBOutlet UITextField *ageInput;

- (IBAction)finishDescriptionInputAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *descriptionInput;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCount;

- (IBAction)registerAction:(id)sender;

@end
