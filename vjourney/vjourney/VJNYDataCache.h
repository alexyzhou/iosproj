//
//  VJNYDataCache.h
//  vjourney
//
//  Created by alex on 14-5-23.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VJNYDataCacheDelegate;

@interface VJNYDataCache : NSObject

+(VJNYDataCache*)instance;
-(UIImage*)dataByURL:(NSString*)url;
-(void)requestDataByURL:(NSString*)url WithDelegate:(id<VJNYDataCacheDelegate>)delegate AndIdentifier:(id)identifier AndMode:(int)mode;
@end

@protocol VJNYDataCacheDelegate <NSObject>
@required
/** Returns a coverflow cover view to place at the cover index.
 @param coverflowView The coverflow view.
 @param index The index for the coverflow cover.
 @return A `TKCoverflowCoverView` view that is either newly created or from the coverflow's reusable queue.
 */
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode;
@end