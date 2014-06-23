//
//  VJNYBallonListViewController.h
//  vjourney
//
//  Created by alex on 14-6-22.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYDataCache.h"

@class VJNYPOJOWhisper;

@interface VJNYBallonListViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,VJNYDataCacheDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoPlayerContainerView;
@property (weak, nonatomic) IBOutlet UIView *videoMaskView;
@property (weak, nonatomic) IBOutlet UICollectionView *cardContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayButton;


@property (nonatomic, strong) VJNYPOJOWhisper* whisper;

- (IBAction)longPressHandler:(UILongPressGestureRecognizer*)sender;
- (IBAction)tapToPlayAction:(UITapGestureRecognizer *)sender;

@end
