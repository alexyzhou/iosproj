//
//  VJNYVideoCaptureViewController.h
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVision.h"

@interface VJNYVideoCaptureViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,PBJVisionDelegate>
- (IBAction)videoSelectAction:(id)sender;
- (IBAction)videoDeleteAction:(id)sender;
- (IBAction)startCaptureAction:(id)sender;
- (IBAction)endCaptureInSideAction:(id)sender;
- (IBAction)endCaptureOutSideAction:(id)sender;


- (IBAction)cancelCaptureAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *videoSelectionOrDoneButton;
@property (weak, nonatomic) IBOutlet UIButton *videoCaptureButton;
@property (weak, nonatomic) IBOutlet UIView *progressContainerView;
@property (weak, nonatomic) IBOutlet UIButton *videoDeleteButton;

@end
