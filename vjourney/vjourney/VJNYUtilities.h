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
+(void)showAlert:(NSString*)title andContent:(NSString*)content;
+(void)showAlertWithNoTitle:(NSString*)content;
+(BOOL)isRetina;

+(NSString*)channelCellIdentifier;
+(NSString*)channelPromoCellIdentifier;
+(NSString*)channelSearchCellIdentifier;
+(NSString*)videoCellIdentifier;
+(NSString*)videoThumbnailCellIdentifier;

+(NSString*)segueShowVideoPageByChannel;
+(NSString*)segueLoginShowMainPage;
+(NSString*)segueVideoCutPage;
+ (UIImage *) imageWithView:(UIView *)view;
+ (UIImage *) imageWithView7:(UIView *)view;
@end

