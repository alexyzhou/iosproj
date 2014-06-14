//
//  VJNYUtilities.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VJNYUtilities : NSObject

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
+(UIInterfaceOrientation)orientationByPreferredTransform:(CGAffineTransform)tranform;
+(UIImage*)uiImageByCGImage:(CGImageRef)ref WithOrientation:(UIInterfaceOrientation)orientation AndScale:(CGFloat)scale;

+(NSString*)segueShowVideoPageByChannel;
+(NSString*)segueLoginShowMainPage;
+(NSString*)segueVideoCutPage;

+(CGFloat)minCaptureTime;
+(CGFloat)maxCaptureTime;

+(NSString*)videoCaptureTmpFolderPath;
+(NSString*)videoCutInputPath;
+(NSString*)videoCutOutputPath;
+(NSString*)videoShareTmpFolderPath;

+ (UIImage *) imageWithView:(UIView *)view;
+ (UIImage *) imageWithView7:(UIView *)view;
@end

