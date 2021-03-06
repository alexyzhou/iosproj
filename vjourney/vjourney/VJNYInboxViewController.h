//
//  VJNYInboxViewController.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VJNYHTTPHelper.h"
#import "VJNYDataCache.h"
#import "ASIHTTPRequest.h"

@protocol VJNYInboxSlideDelegate <NSObject>
@required
-(void)subViewDidTriggerSliderAction:(UIView*)view;
-(void)subViewDidDragSliderAction:(CGPoint)translation AndGestureState:(UIGestureRecognizerState)state AndView:(UIView*)view;
-(void)subViewDidTapOutsideSlider:(UIView*)view;
-(BOOL)isSliderOff;
@end

@interface VJNYInboxViewController : UIViewController<UINavigationControllerDelegate,VJNYInboxSlideDelegate,VJNYDataCacheDelegate,ASIHTTPRequestDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UIImageView *userCoverView;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *userVideoCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLikeCountLabel;

@property (weak, nonatomic) IBOutlet UIView *messageSelectionView;
@property (weak, nonatomic) IBOutlet UIImageView *messageIconView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabelView;

@property (weak, nonatomic) IBOutlet UIView *chatSelectionView;
@property (weak, nonatomic) IBOutlet UIImageView *chatIconView;
@property (weak, nonatomic) IBOutlet UILabel *chatLabelView;

@property (weak, nonatomic) IBOutlet UIView *settingsSelectionView;
@property (weak, nonatomic) IBOutlet UIImageView *settingIconView;
@property (weak, nonatomic) IBOutlet UILabel *settingLabelView;

@property (weak, nonatomic) IBOutlet UIView *vooDooSelectionView;
@property (weak, nonatomic) IBOutlet UIImageView *vooDooIconView;
@property (weak, nonatomic) IBOutlet UILabel *vooDooLabelView;

@property (weak, nonatomic) IBOutlet UIScrollView *sliderScrollView;

- (IBAction)dismissSliderViewAction:(id)sender;
- (void)subViewDidTriggerSliderAction:(UIView *)view;
- (void)subViewDidDragSliderAction:(CGPoint)translation AndGestureState:(UIGestureRecognizerState)state AndView:(UIView *)view;
- (void)subViewDidTapOutsideSlider:(UIView *)view;
- (BOOL)isSliderOff;

- (IBAction)tapToChangePageAction:(UITapGestureRecognizer *)sender;
- (IBAction)panToDismissSliderAction:(UIPanGestureRecognizer *)sender;



@end
