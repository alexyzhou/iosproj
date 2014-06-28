//
//  VJNYBallonBaseViewController.m
//  vjourney
//
//  Created by alex on 14-6-22.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYBallonBaseViewController.h"
#import "VJNYBallonListViewController.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYPOJOUser.h"
#import "VJNYPOJOWhisper.h"
#import "VJNYHTTPHelper.h"
#import "VJNYUtilities.h"

@interface VJNYBallonBaseViewController ()

@end

@implementation VJNYBallonBaseViewController

@synthesize slideDelegate=_slideDelegate;

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
    //UINavigationController* controller = self.navigationController;
    //[controller pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"sBallonStoragePage"] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:[VJNYUtilities segueVideoCapturePage]]) {
        UINavigationController* controller = segue.destinationViewController;
        VJNYVideoCaptureViewController* videoController = [controller.viewControllers objectAtIndex:0];
        videoController.delegate = sender;
    } else if ([segue.identifier isEqual:[VJNYUtilities segueBallonStoragePage]]) {
        VJNYBallonListViewController* controller = segue.destinationViewController;
        controller.whisper = sender;
    }
}

#pragma mark - Video Upload Delegate

- (void) videoReadyForUploadWithVideoData:(NSData*)videoData AndCoverData:(NSData*)coverData AndPostValue:(NSMutableDictionary*)dic {
    
    [VJNYUtilities showProgressAlertView];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:@"add/whisper"]];
    
    // Success
    [request addData:videoData withFileName:@"test.mov" andContentType:@"video/quicktime" forKey:@"file"];
    [request addData:coverData withFileName:@"test.jpg" andContentType:@"image/jpeg" forKey:@"cover"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    
    [request addPostValue:jsonString forKey:@"description"];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"add/whisper"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [VJNYUtilities dismissProgressAlertView];
            if (result.result == Success) {
                [VJNYUtilities showAlert:@"Success" andContent:@"Upload Succeed!"];
            } else {
                [VJNYUtilities showAlertWithNoTitle:[NSString stringWithFormat:@"Login Failed!, Reason:%d",result.result]];
            }
        });
    } else if ([result.action isEqualToString:@"whisper/Get"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [VJNYUtilities dismissProgressAlertView];
            if (result.result == Success) {
                VJNYPOJOWhisper* whisper = result.response;
                [self performSegueWithIdentifier:[VJNYUtilities segueBallonStoragePage] sender:whisper];
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

#pragma mark - UIButton Handler

- (IBAction)catchBallonAction:(id)sender {
    
    [VJNYUtilities showProgressAlertView];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    
    [VJNYHTTPHelper sendJSONRequest:@"whisper/get" WithParameters:dic AndDelegate:self];
    
}

- (IBAction)ballonStorageAction:(id)sender {
    [self performSegueWithIdentifier:[VJNYUtilities segueBallonStoragePage] sender:nil];
}

- (IBAction)uploadBallonAction:(id)sender {
    
    [self performSegueWithIdentifier:[VJNYUtilities segueVideoCapturePage] sender:self];
    
}
- (IBAction)showSliderAction:(id)sender {
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTriggerSliderAction)]) {
        [_slideDelegate subViewDidTriggerSliderAction];
    }
}
@end
