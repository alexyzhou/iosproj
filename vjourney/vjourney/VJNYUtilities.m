//
//  VJNYUtilities.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOUser.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation VJNYUtilities

static UIAlertView* _progressAlert = NULL;

// For Testing
+(void)initTestParameters {
//    VJNYPOJOUser* user = [VJNYPOJOUser sharedInstance];
//    user.name = @"userName0";
//    user.uid = [NSNumber numberWithLong:1];
//    user.token = @"bdd4bc5d3e058f8242e9ebdd1bff7f73";
//    user.avatarUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:@"avatar/11.png"];
//    user.coverUrl = [[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:@"cover/user/1404738299542.jpg"];
//    user.description = @"static Description";
}

+(void)initBgImageForTabView:(UIView*)view {
    UIImageView* bg_image = [[UIImageView alloc] initWithFrame:view.bounds];
    bg_image.image = [UIImage imageNamed:@"bg_main.jpg"];
    [view insertSubview:bg_image atIndex:0];
}

+(void)initBgImageForNaviBarWithTabView:(UINavigationController*)controller {
    [controller.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_main_head.jpg"] forBarMetrics:UIBarMetricsDefault];
    [controller.navigationBar setTintColor:[UIColor whiteColor]];
    [controller.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}
+(void)initEditingBgImageForNaviBarWithTabView:(UINavigationController*)controller {
    [controller.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_editing_head.jpg"] forBarMetrics:UIBarMetricsDefault];
    [controller.navigationBar setTintColor:[UIColor whiteColor]];
    [controller.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}
+(void)voidBgImageForTabBarWithController:(UITabBarController*)controller {
    [controller.tabBar setBackgroundImage:[UIImage imageNamed:@"bg_main_bottom.jpg"]];
    [controller.tabBar setTintColor:[UIColor whiteColor]];
    [controller.tabBar setBarStyle:UIBarStyleBlack];
}

+(NSObject*)filterNSNullForObject:(NSObject *)obj {
    if (!obj || [obj isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return obj;
    }
}

#pragma mark - String Helper

+(NSString*)formatDataString:(NSDate*)param {
    
    NSTimeInterval intervals = abs(param.timeIntervalSinceNow);
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    
    if (intervals < 3600*24) {
        // less than a day
        fmt.dateFormat = @"HH:mm:ss";
    } else if (intervals < 3600*24*2){
        // less than 2 days
        return @"yesterday";
    } else if (intervals < 3600*24*365){
        // less than a year
        fmt.dateFormat = @"MM-dd";
    } else {
        fmt.dateFormat = @"yyyy-MM-dd";
    }
    return [fmt stringFromDate:param];
}
+(NSString*)filterToAlphabetFromString:(NSString*)input {
    return [[input componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

#pragma mark - UI Helper

/*+(UIAlertView*)alertViewWithProgress {
    
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
}*/

+(void)showProgressAlertViewToView:(UIView*)view {
    //[[self alertViewWithProgress] show];
    [MBProgressHUD showHUDAddedTo:view animated:YES];
}
+(void)dismissProgressAlertViewFromView:(UIView*)view {
    //[[self alertViewWithProgress] dismissWithClickedButtonIndex:0 animated:YES];
    [MBProgressHUD hideHUDForView:view animated:YES];
}

+(void)showAlert:(NSString*)title andContent:(NSString*)content {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+(void)showAlertWithNoTitle:(NSString*)content {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:content message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
+(UIFont*)customFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"CenturyGothic" size:size];
}

#pragma mark - IO Helper

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
+ (void) addShadowForUIView:(UIView *)view {
    [self addShadowForUIView:view WithOffset:CGSizeMake(1.0f,-4.0f) AndRadius:5.0f];
}
+ (void) addShadowForUIView:(UIView *)view WithOffset:(CGSize)size AndRadius:(CGFloat)radius {
    view.layer.shadowOffset = size;
    view.layer.shadowRadius = radius;
    view.layer.shadowOpacity = 0.5f;
    view.layer.masksToBounds = NO;
}
+ (void) addRoundMaskForUIView:(UIView*)view {
    view.layer.cornerRadius = view.bounds.size.height/2;
    view.layer.masksToBounds = YES;
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
+ (UIImage *)scaleImage:(UIImage*)image toResolution:(int)resolution {
    CGImageRef imgRef = [image CGImage];
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    //if already at the minimum resolution, return the orginal image, otherwise scale
    if (width <= resolution && height <= resolution) {
        return image;
        
    } else {
        CGFloat ratio = width/height;
        
        if (ratio > 1) {
            bounds.size.width = resolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = resolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    [image drawInRect:CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)];
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
#pragma mark image scale utility

#define ORIGINAL_MAX_WIDTH 640.0f

+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Cell Identifiers

+(NSString*)channelCellIdentifier {
    return @"channelCell";
}
+(NSString*)channelPromoCellIdentifier {
    return @"promoChannelCell";
}
+(NSString*)channelPromoCoverCellIdentifier {
    return @"promoChannelCoverCell";
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
+(NSString*)filterCardCellIdentifier {
    return @"videoFilterCell";
}
+(NSString*)shareCardCellIdentifier {
    return @"shareCardCell";
}
+(NSString*)ballonCardCellIdentifier {
    return @"ballonCardCell";
}
+(NSString*)profileHeadCellIdentifier {
    return @"profileHeadCell";
}
+(NSString*)profileVideoCellIdentifier {
    return @"profileVideoCell";
}
+(NSString*)chatMessageCellIdentifier {
    return @"chatMessageCell";
}
+(NSString*)chatThreadCellIdentifier {
    return @"chatThreadCell";
}
+(NSString*)sysNotifCellIdentifier {
    return @"sysNotifCell";
}
+(NSString*)likedUserCellIdentifier {
    return @"likedUserCell";
}
+(NSString*)settingGeneralCellIdentifier {
    return @"settingGeneralCell";
}
+(NSString*)settingLogoutCellIdentifier {
    return @"settingLogoutCell";
}
+(NSString*)settingCellWithLabelIdentifier {
    return @"settingLabelCell";
}
+(NSString*)settingCellWithSwitchIdentifier {
    return @"settingSwitchCell";
}
+(NSString*)seggestCreateChannelCellIdentifier {
    return @"suggCreateChannelCell";
}


#pragma mark - Segue

+(NSString*)segueShowVideoPageByChannel {
    return @"segueShowVideoPageByChannel";
}
+(NSString*)segueLoginShowMainPage {
    return @"segueLoginShowMainPage";
}
+(NSString*)segueVideoCapturePage {
    return @"segueVideoCapturePage";
}
+(NSString*)segueVideoCutPage {
    return @"segueVideoCutPage";
}
+(NSString*)segueVideoFilterPage {
    return @"segueVideoFilterPage";
}
+(NSString*)segueVideoSharePage {
    return @"segueVideoSharePage";
}
+(NSString*)segueVideoCoverSelectPage {
    return @"segueVideoCoverPage";
}
+(NSString*)segueBallonStoragePage {
    return @"segueBallonStoragePage";
}
+(NSString*)segueChatDetailpage {
    return @"segueChatDetailPage";
}
+(NSString*)segueLikedListPage {
    return @"segueLikedListPage";
}
+(NSString*)segueChannelSearchPage {
    return @"segueChannelSearchPage";
}
+(NSString*)seguePrivacySettingPage {
    return @"seguePrivacySettingPage";
}
+(NSString*)segueChannelCreatePage {
    return @"segueChannelCreatePage";
}
+(NSString*)segueAccountSettingPage {
    return @"segueAccountSettingPage";
}

#pragma mark - Storyboard IDs

+(NSString*)storyboardBallonBasePage {
    return @"sBallonBasePage";
}
+(NSString*)storyboardBallonListPage {
    return @"sBallonListPage";
}
+(NSString*)storyboardUserProfilePage {
    return @"sUserProfilePage";
}
+(NSString*)storyboardUserProfileDetailPage {
    return @"sUserProfileDetailPage";
}
+(NSString*)storyboardChatListPage {
    return @"sChatListPage";
}
+(NSString*)storyboardChatDetailPage {
    return @"sChatDetailPage";
}
+(NSString*)storyboardSysNotifPage {
    return @"sSysNotifPage";
}
+(NSString*)storyboardVideoListPage {
    return @"videoListPage";
}
+(NSString*)storyboardSettingPage {
    return @"sSettingPage";
}
+(NSString*)storyboardWelcomePage {
    return @"sWelcomePage";
}

#pragma mark - Const Values

+(CGFloat)minCaptureTime {
    return 5.0f;
}
+(CGFloat)maxCaptureTime {
    return 15.0f;
}

+(NSString*)videoCaptureTmpFolderPath {
    return NSTemporaryDirectory();
}
+(NSString*)videoFilterInputPath {
    NSString* cutPath = [[VJNYUtilities documentsDirectory] stringByAppendingPathComponent:@"/Filter"];
    [self checkAndCreateFolderForPath:cutPath];
    return [cutPath stringByAppendingString:@"/in.mp4"];
}
+(NSString*)videoFilterTempPath {
    NSString* cutPath = [[VJNYUtilities documentsDirectory] stringByAppendingPathComponent:@"/Filter"];
    [self checkAndCreateFolderForPath:cutPath];
    return [cutPath stringByAppendingString:@"/tmp.mp4"];
}
+(NSString*)videoFilterOutputPath {
    NSString* cutPath = [[VJNYUtilities documentsDirectory] stringByAppendingPathComponent:@"/Filter"];
    [self checkAndCreateFolderForPath:cutPath];
    return [cutPath stringByAppendingString:@"/out.mp4"];
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
+(NSString*)dataCacheFolderPath {
    NSString* sharePath = [[VJNYUtilities documentsDirectory] stringByAppendingPathComponent:@"/Cache"];
    [self checkAndCreateFolderForPath:sharePath];
    return [sharePath stringByAppendingString:@"/"];
}

#pragma mark - Camera Utility

#pragma mark camera utility
+ (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

+ (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
+ (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
+ (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

@end
