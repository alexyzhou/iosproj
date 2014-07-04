//
//  VJNYWelcomeViewController.m
//  vjourney
//
//  Created by alex on 14-4-24.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYWelcomeViewController.h"
#import "VJNYUtilities.h"

@interface VJNYWelcomeViewController ()

@end

@implementation VJNYWelcomeViewController

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
    
    /*for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }*/
    
    self.helloLabelView.font = [VJNYUtilities customFontWithSize:20];
    
    //self.signInBgImageView.image = [self.bgImageView.image applyLightEffect];
    
    [self performSelector:@selector(beginAnimation) withObject:nil afterDelay:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}


/*#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}*/


#pragma mark - UITextField Event Handler

-(BOOL)textFieldShouldReturn:(UITextField *)tf {
    [tf resignFirstResponder];
    if (tf == self.userNameInputField) {
        [self.passwordInputField becomeFirstResponder];
    }
    return YES;
}

#pragma mark - Custom Method for Animation

- (void)beginAnimation {
    [UIView animateWithDuration:2 animations:^(void) {
        self.helloLabelView.alpha = 0.0f;
        [self.logoImageView setFrame:CGRectMake(self.logoImageView.frame.origin.x, 53, self.logoImageView.frame.size.width, self.logoImageView.frame.size.height)];
        [self.ballonImageView setFrame:CGRectMake(25, -1 * self.ballonImageView.frame.size.height, self.ballonImageView.frame.size.width, self.ballonImageView.frame.size.height)];
        self.ballonImageView.alpha = 0.0f;
        self.signInView.alpha = 1.0f;
    }completion:^(BOOL complete) {
        [self.helloLabelView removeFromSuperview];
        [self.bgImageView removeFromSuperview];
        [self.ballonImageView removeFromSuperview];
    }];
}

#pragma mark - activityIndicator Event
- (void) actIndicatorBegin {
    [VJNYUtilities showProgressAlertViewToView:self.view];
}

-(void) actIndicatorEnd {
    [VJNYUtilities dismissProgressAlertViewFromView:self.view];
}

#pragma mark - Button Action

- (IBAction)loginAction:(id)sender {
    if ([self.userNameInputField.text isEqualToString:@""]) {
        [VJNYUtilities showAlertWithNoTitle:@"Please fill in your username!"];
        [self.userNameInputField becomeFirstResponder];
        return;
    } else if ([self.passwordInputField.text isEqualToString:@""]) {
        [VJNYUtilities showAlertWithNoTitle:@"Please fill in your password!"];
        [self.passwordInputField becomeFirstResponder];
        return;
    }
    
    [NSThread detachNewThreadSelector: @selector(actIndicatorBegin) toTarget:self withObject:nil];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.userNameInputField.text forKey:@"username"];
    [dic setObject:self.passwordInputField.text forKey:@"password"];
    
    [VJNYHTTPHelper sendJSONRequest:@"user/login" WithParameters:dic AndDelegate:self];
}

- (IBAction)registerAction:(id)sender {
}

- (IBAction)iForgotAction:(id)sender {
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"login"]) {
        if (result.result == Success) {
            [NSThread detachNewThreadSelector: @selector(actIndicatorEnd) toTarget:self withObject:nil];
            
            [self performSegueWithIdentifier:[VJNYUtilities segueLoginShowMainPage] sender:self];
            //[self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"mainPage"] animated:YES completion:nil];
        } else {
            [VJNYUtilities showAlertWithNoTitle:@"Login Failed!"];
        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [NSThread detachNewThreadSelector: @selector(actIndicatorEnd) toTarget:self withObject:nil];
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}
@end
