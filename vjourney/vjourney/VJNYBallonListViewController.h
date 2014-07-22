//
//  VJNYBallonListViewController.h
//  vjourney
//
//  Created by alex on 14-6-22.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYDataCache.h"
#import "VJNYDataCache.h"
#import "ASIHTTPRequest.h"
#import "VJNYInboxViewController.h"

@interface VJNYBallonListViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,VJNYDataCacheDelegate,UIGestureRecognizerDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoPlayerContainerView;
@property (weak, nonatomic) IBOutlet UIView *videoMaskView;
@property (weak, nonatomic) IBOutlet UICollectionView *cardContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayButton;

@property (weak, nonatomic) IBOutlet UIButton *userAvatarButtonView;
@property (weak, nonatomic) IBOutlet UIButton *chatButtonView;
@property (weak, nonatomic) IBOutlet UIButton *sendBackButtonView;

- (IBAction)longPressHandler:(UILongPressGestureRecognizer*)sender;
- (IBAction)tapToPlayAction:(UITapGestureRecognizer *)sender;
- (IBAction)panToDragVideoCardAction:(UIPanGestureRecognizer *)sender;

- (IBAction)tapToViewUserInfoAction:(id)sender;
- (IBAction)tapToChatAction:(id)sender;
- (IBAction)tapToSendbackVoodooAction:(id)sender;

@property(nonatomic, strong) id<VJNYInboxSlideDelegate> slideDelegate;
- (IBAction)showSliderAction:(id)sender;

@end
