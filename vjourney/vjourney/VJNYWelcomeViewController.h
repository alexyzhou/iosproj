//
//  VJNYWelcomeViewController.h
//  vjourney
//
//  Created by alex on 14-4-24.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VJNYWelcomeViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *helloLabelView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet UIImageView *signInBgImageView;
@property (weak, nonatomic) IBOutlet UITextField *userNameInputField;
@property (weak, nonatomic) IBOutlet UITextField *passwordInputField;
- (IBAction)loginAction:(id)sender;
- (IBAction)registerAction:(id)sender;
- (IBAction)iForgotAction:(id)sender;


@end
