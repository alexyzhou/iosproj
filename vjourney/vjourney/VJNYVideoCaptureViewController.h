//
//  VJNYVideoCaptureViewController.h
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVision.h"

#ifndef vjourney_VJNYVideoCaptureMode_h
#define vjourney_VJNYVideoCaptureMode_h

typedef enum {
    GeneralMode = 0,
    WhisperMode = 1
} VJNYVideoCaptureMode;

#endif

@protocol VJNYVideoUploadDelegate <NSObject>
@required
- (void) videoReadyForUploadWithVideoData:(NSData*)videoData AndCoverData:(NSData*)coverData AndPostValue:(NSMutableDictionary*)dic;
@end

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

@property (nonatomic, strong) id<VJNYVideoUploadDelegate> delegate;
@property (nonatomic) VJNYVideoCaptureMode captureMode;

@end


