//
//  VJNYRegisterViewController.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYRegisterViewController.h"

@interface VJNYRegisterViewController ()

@end

@implementation VJNYRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextField Event Handler
-(BOOL)textFieldShouldReturn:(UITextField *)tf {
    BOOL result = [super textFieldShouldReturn:tf];
    if (self.usernameInput == tf) {
        [self.passwordInput becomeFirstResponder];
    } else if (self.passwordInput == tf) {
        [self.nameInput becomeFirstResponder];
    }
    return result;
}

#pragma mark - UIButton Event Handler

- (IBAction)registerAction:(id)sender {
    
    if ([self.usernameInput.text isEqualToString:@""]) {
        [VJNYUtilities showAlertWithNoTitle:@"Please fill in your username!"];
        [self.usernameInput becomeFirstResponder];
        return;
    } else if ([self.passwordInput.text isEqualToString:@""]) {
        [VJNYUtilities showAlertWithNoTitle:@"Please fill in your password!"];
        [self.passwordInput becomeFirstResponder];
        return;
    } else if ([self.nameInput.text isEqualToString:@""]) {
        [VJNYUtilities showAlertWithNoTitle:@"Please fill in your name!"];
        [self.nameInput becomeFirstResponder];
        return;
    }
    
    [NSThread detachNewThreadSelector: @selector(actIndicatorBegin) toTarget:self withObject:nil];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.usernameInput.text forKey:@"username"];
    [dic setObject:self.passwordInput.text forKey:@"password"];
    [dic setObject:self.nameInput.text forKey:@"name"];
    
    [VJNYHTTPHelper sendJSONRequest:@"user/register" WithParameters:dic AndDelegate:self];
    
}
@end
