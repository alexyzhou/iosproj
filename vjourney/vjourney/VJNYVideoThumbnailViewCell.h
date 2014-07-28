//
//  VJNYVideoThumbnailViewCell.h
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYBallonListViewController.h"

@interface VJNYVideoThumbnailViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)deleteVideoAction:(id)sender;

@property (strong, nonatomic) id<VJNYBallonOperationDelegate> delegate;

@end
