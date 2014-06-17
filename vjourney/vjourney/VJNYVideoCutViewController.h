//
//  VJNYVideoCutViewController.h
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VJNYVideoCutViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property(nonatomic, strong) NSURL* selectedVideoURL;
@property (weak, nonatomic) IBOutlet UIView *videoPlayBackView;
@property (weak, nonatomic) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayButton;

@property (weak, nonatomic) IBOutlet UIImageView *leftSlider;
@property (weak, nonatomic) IBOutlet UIImageView *rightSlider;
- (IBAction)trimVideoAction:(id)sender;

@end
