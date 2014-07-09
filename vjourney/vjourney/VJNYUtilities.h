//
//  VJNYUtilities.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VJNYUtilities : NSObject

// For Testing
+(void)initTestParameters;
+(void)initBgImageForTabView:(UIView*)view;
+(void)initBgImageForNaviBarWithTabView:(UINavigationController*)controller;
+(void)initEditingBgImageForNaviBarWithTabView:(UINavigationController*)controller;
+(void)voidBgImageForTabBarWithController:(UITabBarController*)controller;


// Helper
+(NSString*)formatDataString:(NSDate*)param;
+(NSString*)filterToAlphabetFromString:(NSString*)input;
//+(UIAlertView*)alertViewWithProgress;
+(void)showProgressAlertViewToView:(UIView*)view;
+(void)dismissProgressAlertViewFromView:(UIView*)view;
+(void)showAlert:(NSString*)title andContent:(NSString*)content;
+(void)showAlertWithNoTitle:(NSString*)content;
+(BOOL)isRetina;
+(UIFont*)customFontWithSize:(CGFloat)size;

// Camera Helper
#pragma mark camera utility
+ (BOOL) isCameraAvailable;

+ (BOOL) isRearCameraAvailable;

+ (BOOL) isFrontCameraAvailable;

+ (BOOL) doesCameraSupportTakingPhotos;

+ (BOOL) isPhotoLibraryAvailable;
+ (BOOL) canUserPickVideosFromPhotoLibrary;
+ (BOOL) canUserPickPhotosFromPhotoLibrary;

+ (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;


// FileSystem Helpers
+(NSString *)documentsDirectory;
+(void)clearTempFiles;
+(void)checkAndCreateFolderForPath:(NSString*)path;
+(void)checkAndDeleteFileForPath:(NSString*)path;

+(NSString*)channelCellIdentifier;
+(NSString*)channelPromoCellIdentifier;
+(NSString*)channelSearchCellIdentifier;
+(NSString*)videoCellIdentifier;
+(NSString*)videoThumbnailCellIdentifier;
+(NSString*)filterCardCellIdentifier;
+(NSString*)shareCardCellIdentifier;
+(NSString*)ballonCardCellIdentifier;
+(NSString*)profileHeadCellIdentifier;
+(NSString*)profileVideoCellIdentifier;
+(NSString*)chatMessageCellIdentifier;
+(NSString*)chatThreadCellIdentifier;
+(NSString*)sysNotifCellIdentifier;
+(NSString*)likedUserCellIdentifier;
+(NSString*)settingGeneralCellIdentifier;
+(NSString*)settingLogoutCellIdentifier;
+(NSString*)settingCellWithLabelIdentifier;
+(NSString*)settingCellWithSwitchIdentifier;
+(UIInterfaceOrientation)orientationByPreferredTransform:(CGAffineTransform)tranform;
+(UIImage*)uiImageByCGImage:(CGImageRef)ref WithOrientation:(UIInterfaceOrientation)orientation AndScale:(CGFloat)scale;
+ (UIImage *)scaleImage:(UIImage*)image toResolution:(int)resolution;

+(NSString*)segueShowVideoPageByChannel;
+(NSString*)segueLoginShowMainPage;
+(NSString*)segueVideoCapturePage;
+(NSString*)segueVideoCutPage;
+(NSString*)segueVideoFilterPage;
+(NSString*)segueVideoSharePage;
+(NSString*)segueVideoCoverSelectPage;
+(NSString*)segueBallonStoragePage;
+(NSString*)segueChatDetailpage;
+(NSString*)segueLikedListPage;
+(NSString*)segueChannelSearchPage;

+(NSString*)storyboardBallonBasePage;
+(NSString*)storyboardUserProfilePage;
+(NSString*)storyboardUserProfileDetailPage;
+(NSString*)storyboardChatListPage;
+(NSString*)storyboardChatDetailPage;
+(NSString*)storyboardSysNotifPage;
+(NSString*)storyboardVideoListPage;
+(NSString*)storyboardSettingPage;

+(CGFloat)minCaptureTime;
+(CGFloat)maxCaptureTime;

+(NSString*)videoCaptureTmpFolderPath;
+(NSString*)videoFilterInputPath;
+(NSString*)videoFilterTempPath;
+(NSString*)videoFilterOutputPath;
+(NSString*)videoCutOutputPath;
+(NSString*)videoShareTmpFolderPath;
+(NSString*)dataCacheFolderPath;

+ (UIImage *) imageWithView:(UIView *)view;
+ (UIImage *) imageWithView7:(UIView *)view;

+ (void) addShadowForUIView:(UIView *)view;
+ (void) addShadowForUIView:(UIView *)view WithOffset:(CGSize)size AndRadius:(CGFloat)radius;
+ (void) addRoundMaskForUIView:(UIView*)view;
@end

