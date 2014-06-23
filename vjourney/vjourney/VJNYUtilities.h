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

+(UIAlertView*)alertViewWithProgress;
+(void)showProgressAlertView;
+(void)dismissProgressAlertView;
+(void)showAlert:(NSString*)title andContent:(NSString*)content;
+(void)showAlertWithNoTitle:(NSString*)content;
+(BOOL)isRetina;

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
+(UIInterfaceOrientation)orientationByPreferredTransform:(CGAffineTransform)tranform;
+(UIImage*)uiImageByCGImage:(CGImageRef)ref WithOrientation:(UIInterfaceOrientation)orientation AndScale:(CGFloat)scale;

+(NSString*)segueShowVideoPageByChannel;
+(NSString*)segueLoginShowMainPage;
+(NSString*)segueVideoCapturePage;
+(NSString*)segueVideoCutPage;
+(NSString*)segueVideoFilterPage;
+(NSString*)segueVideoSharePage;
+(NSString*)segueVideoCoverSelectPage;
+(NSString*)segueBallonStoragePage;

+(NSString*)storyboardBallonBasePage;
+(NSString*)storyboardUserProfilePage;

+(CGFloat)minCaptureTime;
+(CGFloat)maxCaptureTime;

+(NSString*)videoCaptureTmpFolderPath;
+(NSString*)videoFilterInputPath;
+(NSString*)videoFilterTempPath;
+(NSString*)videoCutOutputPath;
+(NSString*)videoShareTmpFolderPath;

+ (UIImage *) imageWithView:(UIView *)view;
+ (UIImage *) imageWithView7:(UIView *)view;

+ (void) addShadowForUIView:(UIView *)view;
@end

