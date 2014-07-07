//
//  VJNYLikedListViewController.h
//  vjourney
//
//  Created by alex on 14-7-8.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "VJNYDataCache.h"

@interface VJNYLikedListViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,ASIHTTPRequestDelegate,VJNYDataCacheDelegate>
@property (weak, nonatomic) IBOutlet UILabel *likedTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSNumber* videoId;

@end
