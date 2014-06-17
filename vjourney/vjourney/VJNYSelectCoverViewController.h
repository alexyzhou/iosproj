//
//  VJNYSelectCoverViewController.h
//  vjourney
//
//  Created by alex on 14-6-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VJNYSelectCoverDelegate<NSObject>

- (void)selectCoverDidCancel;
- (void)selectCoverDidDoneWithImage:(UIImage*)image;

@end

@interface VJNYSelectCoverViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *sliderView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

- (IBAction)cancelAction:(id)sender;
- (IBAction)doneAction:(id)sender;

- (IBAction)dragSliderAction:(UIPanGestureRecognizer *)sender;


//Custom Properties
@property (strong,nonatomic) NSURL* inputPath;
@property (strong,nonatomic) id<VJNYSelectCoverDelegate> delegate;

@end
