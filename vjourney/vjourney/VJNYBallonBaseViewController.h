//
//  VJNYBallonBaseViewController.h
//  vjourney
//
//  Created by alex on 14-6-22.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "VJNYVideoCaptureViewController.h"
#import "VJNYInboxViewController.h"

@interface VJNYBallonBaseViewController : UIViewController<ASIHTTPRequestDelegate, VJNYVideoUploadDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *ballonAnimationImageView;

- (IBAction)catchBallonAction:(id)sender;
- (IBAction)ballonStorageAction:(id)sender;
- (IBAction)uploadBallonAction:(id)sender;

@property(nonatomic, strong) id<VJNYInboxSlideDelegate> slideDelegate;
- (IBAction)showSliderAction:(id)sender;

@end
