//
//  VJNYSettingPrivacyViewController.m
//  vjourney
//
//  Created by alex on 14-7-10.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYSettingPrivacyViewController.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOUser.h"
#import "VJNYPOJOHttpResult.h"

@interface VJNYSettingPrivacyViewController ()

@end

@implementation VJNYSettingPrivacyViewController

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
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                     [UIImage imageNamed:@"bg_main.jpg"]];
    
    [self.topicPrivacySwitch setEnabled:NO];
    [self.videoPrivacySwitch setEnabled:NO];
    [VJNYHTTPHelper getJSONRequest:[@"user/privacy/get/" stringByAppendingString:[[VJNYPOJOUser sharedInstance].uid stringValue]] WithParameters:nil AndDelegate:self];
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

- (NSMutableDictionary*)getDictionaryWithSwitchValue:(BOOL)allow {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    [dic setObject:(allow ? @"1" : @"0") forKey:@"allow"];
    return dic;
}

- (IBAction)topicPrivacyChangedAction:(UISwitch *)sender {
    [VJNYHTTPHelper sendJSONRequest:@"user/privacy/topic" WithParameters:[self getDictionaryWithSwitchValue:self.topicPrivacySwitch.on] AndDelegate:self];
}

- (IBAction)videoPrivacyChangedAction:(UISwitch *)sender {
    [VJNYHTTPHelper sendJSONRequest:@"user/privacy/video" WithParameters:[self getDictionaryWithSwitchValue:self.videoPrivacySwitch.on] AndDelegate:self];
}

#pragma mark - HTTP Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"user/Privacy/Get"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[VJNYUtilities dismissProgressAlertViewFromView:self.view];
            if (result.result == Success) {
                //[VJNYUtilities showAlert:@"Success" andContent:@"Upload Succeed!"];
                NSMutableDictionary* dic = result.response;
                self.topicPrivacySwitch.on = [[dic objectForKey:@"allowTopic"] boolValue];
                self.videoPrivacySwitch.on = [[dic objectForKey:@"allowVideo"] boolValue];
                self.topicPrivacySwitch.enabled = YES;
                self.videoPrivacySwitch.enabled = YES;
                
            } else {
                [VJNYUtilities showAlertWithNoTitle:[NSString stringWithFormat:@"Failed!, Reason:%d",result.result]];
            }
        });
    }
    
    // 当以二进制形式读取返回内容时用这个方法
    //NSData *responseData = [request responseData];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

@end
