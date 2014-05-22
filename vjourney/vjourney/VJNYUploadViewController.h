//
//  VJNYUploadViewController.h
//  vjourney
//
//  Created by alex on 14-5-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYBaseViewController.h"

@interface VJNYUploadViewController : VJNYBaseViewController<ASIHTTPRequestDelegate> {
    NSURL* videoUrlToUpload;
}

- (IBAction)VideoUploadAction:(id)sender;
- (IBAction)VideoPlayAction:(id)sender;

// For opening UIImagePickerController
-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id )delegate;
-(void)startMediaPlayerFromVideoURL:(NSURL*)url;
-(void)finishSelectingVideo:(NSURL*)url;

@end
