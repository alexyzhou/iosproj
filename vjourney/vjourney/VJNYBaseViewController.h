//
//  VJNYBaseViewController.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYHTTPResultCode.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ASIFormDataRequest.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class VJNYWhatsNewViewController;

@interface VJNYBaseViewController : UIViewController<UITextFieldDelegate, ASIHTTPRequestDelegate>
-(void)actIndicatorBegin;
-(void)actIndicatorEnd;
@end
