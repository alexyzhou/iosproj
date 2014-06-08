//
//  VJNYWelcomeViewController.m
//  vjourney
//
//  Created by alex on 14-4-24.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYWelcomeViewController.h"

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
    
    self.helloLabelView.font = [UIFont fontWithName:@"CenturyGothic" size:20];
    
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
        //self.bgImageView.alpha = 0.0f;
        self.signInView.alpha = 1.0f;
    }completion:^(BOOL complete) {
        [self.helloLabelView removeFromSuperview];
        [self.bgImageView removeFromSuperview];
    }];
}

#pragma mark - Button Action

- (IBAction)loginAction:(id)sender {
}

- (IBAction)registerAction:(id)sender {
}

- (IBAction)iForgotAction:(id)sender {
}
@end
