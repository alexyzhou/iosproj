//
//  VJNYBaseViewController.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYBaseViewController.h"
#import "VJNYWhatsNewViewController.h"

@interface VJNYBaseViewController ()

@end

@implementation VJNYBaseViewController

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
    self.navigationController.navigationBar.translucent= YES; // Set transperency to no and
    self.tabBarController.tabBar.translucent= YES; //Set this property so that the tababr will not be transperent
}

- (void)viewWillDisappear:(BOOL)animated {
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
    [tf resignFirstResponder];
    return YES;
}

#pragma mark - activityIndicator Event
- (void) actIndicatorBegin {
    [VJNYUtilities showProgressAlertViewToView:self.view];
}

-(void) actIndicatorEnd {
    [VJNYUtilities dismissProgressAlertViewFromView:self.view];
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
            
            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"mainPage"] animated:YES completion:nil];
        } else {
            [VJNYUtilities showAlertWithNoTitle:@"Login Failed!"];
        }
    } else if ([result.action isEqualToString:@"register"]) {
        if (result.result == Success) {
            [NSThread detachNewThreadSelector: @selector(actIndicatorEnd) toTarget:self withObject:nil];
            
            [VJNYUtilities showAlertWithNoTitle:@"Register Succeed!"];
            
            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"uploadPage"] animated:YES completion:nil];
        } else {
            [VJNYUtilities showAlertWithNoTitle:@"Register Failed!"];
        }
    }
    
    // 当以二进制形式读取返回内容时用这个方法
    //NSData *responseData = [request responseData];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [NSThread detachNewThreadSelector: @selector(actIndicatorEnd) toTarget:self withObject:nil];
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

@end
