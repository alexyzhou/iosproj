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

+(void)showProgressAlertView {
    [[self alertViewWithProgress] show];
}
+(void)dismissProgressAlertView {
    [[self alertViewWithProgress] dismissWithClickedButtonIndex:0 animated:YES];
}

+(void)showAlert:(NSString*)title andContent:(NSString*)content {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+(void)showAlertWithNoTitle:(NSString*)content {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:content message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+(void)clearTempFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [VJNYUtilities videoCaptureTmpFolderPath];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
}
+(NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
+(void)checkAndCreateFolderForPath:(NSString*)path {
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
}
+(void)checkAndDeleteFileForPath:(NSString*)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            NSLog(@"could not delete an file");
        }
    }
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
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}
+(BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0));
}
+(UIInterfaceOrientation)orientationByPreferredTransform:(CGAffineTransform)tranform {
    if (tranform.a==-1&&tranform.d==-1) {
        return UIInterfaceOrientationLandscapeLeft;
    } else if (tranform.a==1&&tranform.d==1) {
        return UIInterfaceOrientationLandscapeRight;
    } else if (tranform.b==-1&&tranform.c==1) {
        return UIInterfaceOrientationPortraitUpsideDown;
    } else {
        return UIInterfaceOrientationPortrait;
    }
}
+(UIImage*)uiImageByCGImage:(CGImageRef)ref WithOrientation:(UIInterfaceOrientation)orientation AndScale:(CGFloat)scale {
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return [[UIImage alloc] initWithCGImage:ref scale:scale orientation:UIImageOrientationDown];
            break;
        case UIInterfaceOrientationLandscapeRight:
            return [[UIImage alloc] initWithCGImage:ref scale:scale orientation:UIImageOrientationUp];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return [[UIImage alloc] initWithCGImage:ref scale:scale orientation:UIImageOrientationLeft];
            break;
        case UIInterfaceOrientationPortrait:
            return [[UIImage alloc] initWithCGImage:ref scale:scale orientation:UIImageOrientationRight];
            break;
        default:
            return [[UIImage alloc] initWithCGImage:ref scale:scale orientation:UIImageOrientationRight];
            break;
    }    
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
+(NSString*)videoThumbnailCellIdentifier {
    return @"videoThumbnailCell";
}
+(NSString*)channelSearchCellIdentifier {
    return @"channelSearchCell";
}

+(NSString*)segueShowVideoPageByChannel {
    return @"segueShowVideoPageByChannel";
}
+(NSString*)segueLoginShowMainPage {
    return @"segueLoginShowMainPage";
}
+(NSString*)segueVideoCutPage {
    return @"segueVideoCutPage";
}

+(CGFloat)minCaptureTime {
    return 5.0f;
}
+(CGFloat)maxCaptureTime {
    return 15.0f;
}

+(NSString*)videoCaptureTmpFolderPath {
    return NSTemporaryDirectory();
}
+(NSString*)videoCutInputPath {
    NSString* cutPath = [[VJNYUtilities documentsDirectory] stringByAppendingPathComponent:@"/Cut"];
    [self checkAndCreateFolderForPath:cutPath];
    return [cutPath stringByAppendingString:@"/in.mp4"];
}
+(NSString*)videoCutOutputPath {
    NSString* cutPath = [[VJNYUtilities documentsDirectory] stringByAppendingPathComponent:@"/Cut"];
    [self checkAndCreateFolderForPath:cutPath];
    return [cutPath stringByAppendingString:@"/out.mp4"];
}
+(NSString*)videoShareTmpFolderPath {
    NSString* sharePath = [[VJNYUtilities documentsDirectory] stringByAppendingPathComponent:@"/Share"];
    [self checkAndCreateFolderForPath:sharePath];
    return [sharePath stringByAppendingString:@"/"];
}

@end
