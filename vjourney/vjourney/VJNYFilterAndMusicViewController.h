//
//  VJNYFilterAndMusicViewController.h
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VJNYFilterAndMusicViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *playLogoView;

@property (weak, nonatomic) IBOutlet UICollectionView *filterCardCollectionView;
@property (weak, nonatomic) IBOutlet UISwitch *muteOriginalSoundSwitch;
- (IBAction)changeMuteSettingAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *originalSoundLabel;

- (IBAction)selectFilterModeAction:(id)sender;

- (IBAction)tapToPlayOrPauseAction:(id)sender;
- (IBAction)pressToSelectFilterAction:(UILongPressGestureRecognizer *)_longPressRecognizer;

- (IBAction)doneFilterAction:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *dragReceiverView;

//Custom Properties
@property(strong, nonatomic) NSURL* inputPath;

@end
