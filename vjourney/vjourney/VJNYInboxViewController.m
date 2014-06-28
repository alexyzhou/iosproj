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
#import "VJNYChatListViewController.h"
#import "VJNYSysNotifViewController.h"
#import "VJNYAppDelegate.h"
#import "VJNYPOJOUser.h"
#import "VJNYPOJOHttpResult.h"

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
    
    _sliderHide = true;
    _previousSelectedView = [NSMutableDictionary dictionary];
    _subViewControllers = [NSMutableDictionary dictionaryWithCapacity:4];
    
    // UI Configuration
    self.userAvatarView.layer.cornerRadius = self.userAvatarView.bounds.size.height/2;
    self.userAvatarView.layer.masksToBounds = YES;
    [VJNYDataCache loadImage:self.userAvatarView WithUrl:[VJNYPOJOUser sharedInstance].avatarUrl AndMode:0 AndIdentifier:[[NSObject alloc] init] AndDelegate:self];
    self.userNameLabel.text = [VJNYPOJOUser sharedInstance].name;
    
    // Network Stuff
    [VJNYHTTPHelper getJSONRequest:[@"video/countByUser/" stringByAppendingString:[[VJNYPOJOUser sharedInstance].uid stringValue]] WithParameters:nil AndDelegate:self];
    
    // Default Page
    VJNYSysNotifViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardSysNotifPage]];
    controller.slideDelegate = self;
    [self addChildViewController:controller];
    [self.view insertSubview:controller.view belowSubview:self.sliderView];
    [_subViewControllers setObject:controller forKey:@"1"];
    
    [self setUIForSelectedView:_messageSelectionView WithIconView:_messageIconView AndLabel:_messageLabelView];
}

- (void)viewDidLayoutSubviews {
    if (_sliderHide == true) {
        [self dismissSliderView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Helpers

- (void)dismissSliderView {
    self.sliderView.center = CGPointMake(self.sliderView.center.x - self.sliderView.frame.size.width - 20, self.sliderView.center.y);
}

- (void)showSliderView {
    self.sliderView.center = CGPointMake(self.sliderView.frame.size.width/2, self.sliderView.center.y);
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
        } else if (number == 4) {
            // Voodoo
            UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardBallonBasePage]];
            controller.delegate = self;
            VJNYBallonBaseViewController* vooDooController = controller.viewControllers[0];
            vooDooController.slideDelegate = self;
            [self addChildViewController:controller];
            [self.view insertSubview:controller.view belowSubview:self.sliderView];
            [_subViewControllers setObject:controller forKey:numberKey];
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

- (void)subViewDidTriggerSliderAction {
    _sliderHide = false;
    [UIView animateWithDuration:0.3f animations:^{
        [self showSliderView];
    }];
    
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
        //[self switchToViewController:3];
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


@end
