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

@interface VJNYBallonBaseViewController () {
    UIImageView* _uploadIndicator;
    UIView* _uploadBannerView;
    BOOL _ballonAnimationReady;
}

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
    
    _uploadIndicator = nil;
    _uploadBannerView = nil;
    _ballonAnimationReady = false;
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToShowSliderAction:)];
    [self.view addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissSliderAction:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [VJNYUtilities addShadowForUIView:self.ballonAnimationImageView WithOffset:CGSizeMake(2.0f, 2.0f) AndRadius:3.0f];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//    });
    
    //[self.ballonAnimationImageView setAnimationRepeatCount:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    //[self.ballonAnimationImageView startAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    //[self.ballonAnimationImageView stopAnimating];
    
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
        videoController.captureMode = WhisperMode;
    } else if ([segue.identifier isEqual:[VJNYUtilities segueBallonStoragePage]]) {
        VJNYBallonListViewController* controller = segue.destinationViewController;
        controller.whisper = sender;
    }
}

#pragma mark - Video Upload Delegate

- (void) videoReadyForUploadWithVideoData:(NSData*)videoData AndCoverData:(NSData*)coverData AndPostValue:(NSMutableDictionary*)dic {
    
    //[VJNYUtilities showProgressAlertViewToView:self.view];
    
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
    
    [request setUploadProgressDelegate:self];
    
    // Set Upload Banner
    _uploadBannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    [_uploadBannerView setBackgroundColor:[UIColor blueColor]];
    [_uploadBannerView setAlpha:0.5f];
    [self.view addSubview:_uploadBannerView];
    
    // Set Upload Indicator
    _uploadIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(10, 65, 300, 196)];
    [VJNYUtilities addShadowForUIView:_uploadIndicator WithOffset:CGSizeMake(2.0f, 2.0f) AndRadius:4.0f];
    //_uploadIndicator.backgroundColor = [UIColor redColor];
    _uploadIndicator.image = [UIImage imageWithData:coverData];
    _uploadIndicator.contentMode = UIViewContentModeScaleAspectFill;
    _uploadIndicator.clipsToBounds = YES;
    [self.view addSubview:_uploadIndicator];
    [self.addVoodooButton setEnabled:NO];
    
    [UIView animateWithDuration:2 animations:^{
        [_uploadIndicator setFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2+20, 0, 0)];
        _uploadIndicator.alpha = 0.0f;
    } completion:^(BOOL finished) {
        NSLog(@"uploadIndicator Animate Result: %d",finished);
        if (finished) {
            [_uploadIndicator removeFromSuperview];
            _uploadIndicator = nil;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self ballonAnimationHelperWithCurrentIndex:0 AndMaxIndex:27];
            });
            
            [UIView animateWithDuration:2.2f delay:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.ballonAnimationImageView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                
            }];
            
        } else {
            NSLog(@"Error With animate");
        }
        
    }];
}

- (void)setProgress:(float)newProgress {
    NSLog(@"%f",newProgress);
    _uploadBannerView.frame = CGRectMake(0, 0, 320.0f*newProgress, 20);
}

#pragma mark - Animation

- (void)ballonAnimationHelperWithCurrentIndex:(int)index AndMaxIndex:(int)maxIndex {
    if (index <= maxIndex) {
        NSString *strImgeName = [NSString stringWithFormat:@"Voodoo-animate-%d@2x", index];
        NSString *filePath = [[NSBundle mainBundle]pathForResource:strImgeName ofType:@"png"];
        
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:filePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ballonAnimationImageView.image = image;
        });
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.7f/27.0f * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            [self ballonAnimationHelperWithCurrentIndex:index+1 AndMaxIndex:maxIndex];
        });
    } else {
        NSString *strImgeName = [NSString stringWithFormat:@"Voodoo-animate-%d@2x", 0];
        NSString *filePath = [[NSBundle mainBundle]pathForResource:strImgeName ofType:@"png"];
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:filePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ballonAnimationImageView.image = image;
            self.ballonAnimationImageView.alpha = 1.0f;
        });
    }
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"add/whisper"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[VJNYUtilities dismissProgressAlertViewFromView:self.view];
            if (result.result == Success) {
                //[VJNYUtilities showAlert:@"Success" andContent:@"Upload Succeed!"];
                [UIView animateWithDuration:0.5f animations:^{
                    [_uploadBannerView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [_uploadBannerView removeFromSuperview];
                    _uploadBannerView = nil;
                    [self.addVoodooButton setEnabled:YES];
                }];
                
            } else {
                [VJNYUtilities showAlertWithNoTitle:[NSString stringWithFormat:@"Login Failed!, Reason:%d",result.result]];
            }
        });
    } else if ([result.action isEqualToString:@"whisper/Get"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [VJNYUtilities dismissProgressAlertViewFromView:self.view];
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
    
    [VJNYUtilities showProgressAlertViewToView:self.view];
    
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

#pragma mark - Gesture Delegate

- (void)panToShowSliderAction:(UIPanGestureRecognizer *)sender {
    
    UIPanGestureRecognizer* gesture = sender;
    CGPoint translation = [gesture translationInView:self.view];
    [gesture setTranslation:CGPointZero inView:self.view];
    
    //NSLog(@"PanGesture:x-%f,y-%f",translation.x,translation.y);
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidDragSliderAction:AndGestureState:)]) {
        [_slideDelegate subViewDidDragSliderAction:translation AndGestureState:gesture.state];
    }
    
}

- (void)tapToDismissSliderAction:(UITapGestureRecognizer *)sender {
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTapOutsideSlider)]) {
        [_slideDelegate subViewDidTapOutsideSlider];
    }
    
}


@end
