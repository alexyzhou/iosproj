//
//  VJNYInboxViewController.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYInboxViewController.h"
#import "VJNYUtilities.h"
#import "VJNYBallonBaseViewController.h"
#import "VJNYBallonListViewController.h"
#import "VJNYChatListViewController.h"
#import "VJNYSysNotifViewController.h"
#import "VJNYSettingViewController.h"
#import "VJNYAppDelegate.h"
#import "VJNYPOJOUser.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYAppDelegate.h"

@interface VJNYInboxViewController () {
    BOOL _sliderHide;
    NSMutableDictionary* _previousSelectedView;
    NSMutableDictionary* _subViewControllers;
}

@end

@implementation VJNYInboxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tabBarController setHidesBottomBarWhenPushed:YES];
    [VJNYUtilities addShadowForUIView:self.sliderView WithOffset:CGSizeMake(4.0f, 4.0f) AndRadius:5.0f];
    
    if ([self.sliderView isDescendantOfView:self.view]) {
        [self.sliderView removeFromSuperview];
        [self.tabBarController.view addSubview:self.sliderView];
        NSDictionary* dicOfViews = [NSDictionary dictionaryWithObject:self.sliderView forKey:@"sliderView"];
        [self.tabBarController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sliderView]|" options:0 metrics:nil views:dicOfViews]];
        
        NSLog(@"After Init: %f,%f",self.sliderView.frame.size.height,self.sliderView.frame.origin.y);
        _sliderHide = true;
        [self dismissSliderView];
    } else {
        [self.tabBarController.view bringSubviewToFront:self.sliderScrollView];
    }
    
    _previousSelectedView = [NSMutableDictionary dictionary];
    _subViewControllers = [NSMutableDictionary dictionaryWithCapacity:4];
    
    // UI Configuration
    [VJNYUtilities addRoundMaskForUIView:self.userAvatarView];
    //self.userAvatarView.layer.cornerRadius = self.userAvatarView.bounds.size.height/2;
    //self.userAvatarView.layer.masksToBounds = YES;
    [VJNYDataCache loadImage:self.userAvatarView WithUrl:[VJNYPOJOUser sharedInstance].avatarUrl AndMode:0 AndIdentifier:[[NSObject alloc] init] AndDelegate:self];
    [VJNYDataCache loadImage:self.userCoverView WithUrl:[VJNYPOJOUser sharedInstance].coverUrl AndMode:1 AndIdentifier:[[NSObject alloc] init] AndDelegate:self];
    self.userNameLabel.text = [VJNYPOJOUser sharedInstance].name;
    self.userDescriptionLabel.text = [VJNYPOJOUser sharedInstance].description;
    
    // Network Stuff
    [VJNYHTTPHelper getJSONRequest:[@"video/countByUser/" stringByAppendingString:[[VJNYPOJOUser sharedInstance].uid stringValue]] WithParameters:nil AndDelegate:self];
    
    // Default Page
    
    UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardSysNotifPage]];
    controller.delegate = self;
    VJNYSysNotifViewController* vooDooController = controller.viewControllers[0];
    vooDooController.slideDelegate = self;
    [self addChildViewController:controller];
    [self.view insertSubview:controller.view belowSubview:self.sliderView];
    [_subViewControllers setObject:controller forKey:@"1"];

    
    [self setUIForSelectedView:_messageSelectionView WithIconView:_messageIconView AndLabel:_messageLabelView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Helpers

- (void)dismissSliderView {
    self.sliderView.center = CGPointMake(-self.sliderView.frame.size.width/2-20, self.sliderView.center.y);
    //self.sliderView.transform = CGAffineTransformMakeTranslation(-self.sliderView.frame.size.width-20, 0);
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}

- (void)showSliderView {
    self.sliderView.center = CGPointMake(self.sliderView.frame.size.width/2, self.sliderView.center.y);
    //self.sliderView.transform = CGAffineTransformIdentity;

    NSLog(@"After Show[sliderView]: %f,%f",self.sliderView.frame.size.height,self.sliderView.frame.origin.y);
    NSLog(@"After Show: %f,%f",self.sliderScrollView.frame.size.height,self.sliderScrollView.frame.origin.y);
    self.tabBarController.tabBar.userInteractionEnabled = NO;
}

- (void)switchToViewController:(int)number {
    NSString* numberKey = [[NSNumber numberWithInt:number] stringValue];
    if ([_subViewControllers objectForKey:numberKey] == nil) {
        // we don't have this view controller
        if (number == 2) {
            // Chat
            UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardChatListPage]];
            controller.delegate = self;
            VJNYChatListViewController* chatController = controller.viewControllers[0];
            chatController.slideDelegate = self;
            [self addChildViewController:controller];
            [self.view insertSubview:controller.view belowSubview:self.sliderView];
            [_subViewControllers setObject:controller forKey:numberKey];
        } else if (number == 3) {
            // Setting
            UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardSettingPage]];
            //controller.delegate = self;
            VJNYSettingViewController* chatController = controller.viewControllers[0];
            chatController.slideDelegate = self;
            [self addChildViewController:controller];
            [self.view insertSubview:controller.view belowSubview:self.sliderView];
            [_subViewControllers setObject:controller forKey:numberKey];
        } else if (number == 4) {
            // Voodoo
            
            UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardBallonListPage]]];
            controller.delegate = self;
            VJNYBallonListViewController* vooDooController = controller.viewControllers[0];
            vooDooController.slideDelegate = self;
            [self addChildViewController:controller];
            [self.view insertSubview:controller.view belowSubview:self.sliderView];
            [_subViewControllers setObject:controller forKey:numberKey];
            
            
            /*
            UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardBallonBasePage]];
            controller.delegate = self;
            VJNYBallonBaseViewController* vooDooController = controller.viewControllers[0];
            vooDooController.slideDelegate = self;
            [self addChildViewController:controller];
            [self.view insertSubview:controller.view belowSubview:self.sliderView];
            [_subViewControllers setObject:controller forKey:numberKey];
             */
        }
    }
    UIViewController* viewControllerToShow = _subViewControllers[numberKey];
    [self.view bringSubviewToFront:viewControllerToShow.view];
    [self.view bringSubviewToFront:self.sliderView];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    if ([[navigationController viewControllers] objectAtIndex:0] != viewController) {
        if ([self.tabBarController hidesBottomBarWhenPushed]) {
            [self.tabBarController.tabBar setHidden:YES];
        }
    } else {
        [self.tabBarController.tabBar setHidden:NO];
    }
    
}

#pragma mark - Slide Delegate

- (IBAction)dismissSliderViewAction:(id)sender {
    _sliderHide = true;
    [UIView animateWithDuration:0.3f animations:^{
        [self dismissSliderView];
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self.view];
    BOOL isVerticalPan = (fabsf(translation.x) < fabsf(translation.y));
    return !isVerticalPan;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (IBAction)tapToChangePageAction:(UITapGestureRecognizer *)sender {
    
    if (sender.view == _previousSelectedView[@"view"]) {
        return;
    }
    
    [self setUIForUnSelectedView:_previousSelectedView[@"view"] WithIconView:_previousSelectedView[@"icon"] AndLabel:_previousSelectedView[@"label"]];
    
    if (sender.view == _messageSelectionView) {
        [self setUIForSelectedView:_messageSelectionView WithIconView:_messageIconView AndLabel:_messageLabelView];
        [self switchToViewController:1];
    } else if (sender.view == _chatSelectionView) {
        [self setUIForSelectedView:_chatSelectionView WithIconView:_chatIconView AndLabel:_chatLabelView];
        [self switchToViewController:2];
    } else if (sender.view == _settingsSelectionView) {
        [self setUIForSelectedView:_settingsSelectionView WithIconView:_settingIconView AndLabel:_settingLabelView];
        [self switchToViewController:3];
    } else {
        [self setUIForSelectedView:_vooDooSelectionView WithIconView:_vooDooIconView AndLabel:_vooDooLabelView];
        [self switchToViewController:4];
    }
    
    [self dismissSliderViewAction:nil];
}



- (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

- (void)setUIForSelectedView:(UIView*)selectedView WithIconView:(UIImageView*)image AndLabel:(UILabel*)label {
    //1. Change Icon
    [image setHighlighted:YES];
    //2. Change Background
    selectedView.backgroundColor = [self colorWithRed:15 green:44 blue:77 alpha:1.0f];
    //3. Change Font Color
    label.textColor = [UIColor whiteColor];
    
    _previousSelectedView[@"view"] = selectedView;
    _previousSelectedView[@"icon"] = image;
    _previousSelectedView[@"label"] = label;
}

- (void)setUIForUnSelectedView:(UIView*)selectedView WithIconView:(UIImageView*)image AndLabel:(UILabel*)label {
    if (selectedView == nil) {
        return;
    }
    //1. Change Icon
    [image setHighlighted:NO];
    //2. Change Background
    selectedView.backgroundColor = [self colorWithRed:108 green:170 blue:202 alpha:1.0f];
    //3. Change Font Color
    label.textColor = [self colorWithRed:15 green:44 blue:77 alpha:1.0f];
}

#pragma mark - Data Cache Delegate

- (void)dataRequestFinished:(UIImage *)data WithIdentifier:(id)identifier AndMode:(int)mode {
    if (mode == 0) {
        self.userAvatarView.image = data;
    } else if (mode == 1) {
        self.userCoverView.image = data;
    }
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([result.action isEqualToString:@"video/CountByUser"]) {
            if (result.result == Success) {
                self.userVideoCountLabel.text = [[result.response objectForKey:@"count"] stringValue];
                self.userLikeCountLabel.text = [[result.response objectForKey:@"like_count"] stringValue];
            }
        }
    });
    
    // 当以二进制形式读取返回内容时用这个方法
    //NSData *responseData = [request responseData];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

#pragma mark - Slider Delegate

-(void)subViewDidDragSliderAction:(CGPoint)translation AndGestureState:(UIGestureRecognizerState)state AndView:(UIView *)view {
    
    if (_sliderHide == NO) {
        return;
    }
    
    if (state == UIGestureRecognizerStateBegan) {
        
        self.sliderView.center = CGPointMake(-self.sliderView.bounds.size.width/2 - 20, self.sliderView.center.y);
        //NSLog(@"slider Center Rearrange!");
        
    } else if (state == UIGestureRecognizerStateChanged) {
        
        CGPoint originCenter = self.sliderView.center;
        originCenter.x += translation.x;
        
        if (originCenter.x > self.sliderView.bounds.size.width/2) {
            originCenter.x -= translation.x;
        }
        
        self.sliderView.center = originCenter;
        
        
    } else if (state == UIGestureRecognizerStateEnded) {
        
        if (self.sliderView.center.x < -self.sliderView.bounds.size.width/4) {
            [self dismissSliderViewAction:nil];
            //view.userInteractionEnabled = YES;
        } else {
            [self subViewDidTriggerSliderAction:view];
        }
        
    }
    
}

- (IBAction)panToDismissSliderAction:(UIPanGestureRecognizer *)sender {
    
    UIPanGestureRecognizer* gesture = sender;
    CGPoint translation = [gesture translationInView:self.view];
    [gesture setTranslation:CGPointZero inView:self.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        /*
         [self.rightSlider setAlpha:1.0f];
         [_topMaskView setAlpha:1.0f];
         [_bottomMaskView setAlpha:1.0f];
         */
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint originCenter = self.sliderView.center;
        originCenter.x += translation.x;
        
        if (originCenter.x > self.sliderView.bounds.size.width/2) {
            originCenter.x -= translation.x;
        }
        
        self.sliderView.center = originCenter;
        
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        if (self.sliderView.center.x < self.sliderView.bounds.size.width/4) {
            [self dismissSliderViewAction:nil];
        } else {
            [self subViewDidTriggerSliderAction:nil];
        }
        
    }
    
}

- (void)subViewDidTriggerSliderAction:(UIView*)view {
    _sliderHide = false;
    if (view!=nil) {
        //view.userInteractionEnabled = NO;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self showSliderView];
    }];
}

- (void)subViewDidTapOutsideSlider:(UIView *)view {
    if (!_sliderHide) {
        [self dismissSliderViewAction:nil];
        if (view != nil) {
            //view.userInteractionEnabled = YES;
        }
    }
    
}

-(BOOL)isSliderOff {
    return _sliderHide;
}

@end
