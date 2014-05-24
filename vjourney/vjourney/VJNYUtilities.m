//
//  VJNYUtilities.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYUtilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation VJNYUtilities

static UIAlertView* _progressAlert = NULL;

+(UIAlertView*)alertViewWithProgress {
    
    if (_progressAlert == NULL) {
        _progressAlert = [[UIAlertView alloc] initWithTitle:@"Loading\nPlease Wait..."
                                            message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        //UIActivityIndicatorView* _activityIndicatorInstance = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
        //_activityIndicatorInstance.center = CGPointMake(_progressAlert.bounds.size.width / 2, _progressAlert.bounds.size.height - 50);
        //_activityIndicatorInstance.hidden =YES;
        //_activityIndicatorInstance.hidesWhenStopped = YES;
        //[_activityIndicatorInstance startAnimating];
        //[_progressAlert addSubview:_activityIndicatorInstance];
    }
    
    return _progressAlert;
}

+(void)showAlert:(NSString*)title andContent:(NSString*)content {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+(void)showAlertWithNoTitle:(NSString*)content {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:content message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIImage Helper
+ (UIImage *) imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
+ (UIImage *) imageWithView7:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 1.5f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

#pragma mark - Const Values

+(NSString*)channelCellIdentifier {
    return @"channelCell";
}
+(NSString*)channelPromoCellIdentifier {
    return @"promoChannelCell";
}
+(NSString*)videoCellIdentifier {
    return @"videoCell";
}
+(NSString*)channelSearchCellIdentifier {
    return @"channelSearchCell";
}

+(NSString*)segueShowVideoPageByChannel {
    return @"segueShowVideoPageByChannel";
}

@end
