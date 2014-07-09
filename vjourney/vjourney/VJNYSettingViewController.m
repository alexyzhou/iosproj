//
//  VJNYSettingViewController.m
//  vjourney
//
//  Created by alex on 14-7-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYSettingViewController.h"
#import "VJNYSettingWithLabelTableViewCell.h"
#import "VJNYSettingWithSwitchTableViewCell.h"
#import "VJNYUtilities.h"
#import "VJNYDataCache.h"
#import <ShareSDK/ShareSDK.h>

@interface VJNYSettingViewController () {
    UIImage* _weiboImage;
    UIImage* _facebookImage;
    
    int _socialMode;
    int _actionMode;
}

@end

@implementation VJNYSettingViewController

@synthesize slideDelegate=_slideDelegate;

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
    
    [VJNYUtilities initBgImageForNaviBarWithTabView:self.navigationController];
    
    self.settingLabel.font = [VJNYUtilities customFontWithSize:18.0f];
    self.settingOtherLabel.font = [VJNYUtilities customFontWithSize:18.0f];
    _socialMode = -1;
    _actionMode = -1;
    
    _weiboImage = [VJNYUtilities scaleImage:[UIImage imageNamed:@"share_lg_min_sinaWeibo.png"] toResolution:25.0f];
    _facebookImage = [VJNYUtilities scaleImage:[UIImage imageNamed:@"share_lg_min_facebook.png"] toResolution:25.0f];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToShowSliderAction:)];
    [self.tableView addGestureRecognizer:panGesture];
    panGesture.delegate = self;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissSliderAction:)];
    [self.tableView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 2;
            break;
        case 4:
            return 3;
            break;
        case 5:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VJNYSettingWithLabelTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities settingCellWithLabelIdentifier]];
    
    switch (indexPath.section) {
        case 0:
            ;
            cell.titleView.text = @"Drafts";
            cell.detailView.text = nil;
            break;
        case 1:
            ;
            if (indexPath.row == 0) {
                cell.titleView.text = @"Language Settings";
            }
            cell.detailView.text = nil;
            break;
        case 2:
            ;
            if (indexPath.row == 0) {
                cell.titleView.text = @"SINA Weibo";
                cell.imageView.image = _weiboImage;
                cell.detailView.text = [ShareSDK hasAuthorizedWithType:ShareTypeSinaWeibo] ? @"connected" : @"unconnected";
            } else if (indexPath.row == 1) {
                cell.titleView.text = @"Facebook";
                cell.imageView.image = _facebookImage;
                cell.detailView.text = [ShareSDK hasAuthorizedWithType:ShareTypeFacebook] ? @"connected" : @"unconnected";
            }
            break;
        case 3:
            ;
            if (indexPath.row == 0) {
                cell.titleView.text = @"Privacy";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.titleView.text = @"Tutorial";
            }
            cell.detailView.text = nil;
            break;
        case 4:
            ;
            if (indexPath.row == 0) {
                cell.titleView.text = @"Feedback";
                cell.detailView.text = nil;
            } else if (indexPath.row == 1) {
                cell.titleView.text = @"About Vjourney";
                cell.detailView.text = nil;
            } else {
                cell.titleView.text = [NSString stringWithFormat:@"Clear Cache"];
                cell.detailView.text = [VJNYDataCache cacheTotalSize];
            }
            break;
        case 5:
            ;
            UITableViewCell* logoutCell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities settingLogoutCellIdentifier]];
            
            UIView *customColorView = [[UIView alloc] init];
            customColorView.backgroundColor = [UIColor colorWithRed:108.0/255.0 green:170.0/255.0 blue:202.0/255.0 alpha:1.0f];
            logoutCell.selectedBackgroundView = customColorView;
            
            return logoutCell;
            break;
    }
    
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [UIColor colorWithRed:108.0/255.0 green:170.0/255.0 blue:202.0/255.0 alpha:1.0f];
    cell.selectedBackgroundView = customColorView;
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            
        }
        //Drafts
        break;
        case 1:
        {
            
        }
        //Languages Settings
        break;
        case 2:
        {
            VJNYSettingWithLabelTableViewCell* cell = (VJNYSettingWithLabelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            NSString* platformName;
            NSString* actionName;
            
            _socialMode = indexPath.row;
            
            platformName = cell.titleView.text;
            if ([cell.detailView.text isEqual:@"connected"]) {
                actionName = @"unconnect";
                _actionMode = 0;
            } else {
                actionName = @"connect";
                _actionMode = 1;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Do you want to %@ %@?",actionName,platformName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
            alert.tag = 100;
            [alert show];
        }
        break;
        case 3:
            //Privacy and Tutorial
        {
            if (indexPath.row == 0) {
                //Privacy
                [self performSegueWithIdentifier:[VJNYUtilities seguePrivacySettingPage] sender:nil];
            }
        }
    
        break;
        case 4:
            //Feedback, about, clear cache
        {
            if (indexPath.row == 2) {
                //Cache
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to Clear All Cache?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
                alert.tag = 200;
                [alert show];
            }
        }
        break;
        case 5:
        {
            //Logout
        }
        break;
    }
    
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //NSLog(@"%d",buttonIndex);
    if (buttonIndex == 0) {
        return;
    }
    switch (alertView.tag) {
        case 100:
        {
            VJNYSettingWithLabelTableViewCell* cell = (VJNYSettingWithLabelTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_socialMode inSection:2]];
            ShareType actionType = _socialMode == 0? ShareTypeSinaWeibo : ShareTypeFacebook;
            if (_actionMode == 0) {
                [ShareSDK cancelAuthWithType:actionType];
                cell.detailView.text = @"unconnected";
            } else {
                //connect
                [ShareSDK authWithType:actionType                                              //需要授权的平台类型
                               options:nil                                          //授权选项，包括视图定制，自动授权
                                result:^(SSAuthState state, id<ICMErrorInfo> error) {       //授权返回后的回调方法
                                    if (state == SSAuthStateSuccess)
                                    {
                                        cell.detailView.text = @"connected";
                                    }
                                    else if (state == SSAuthStateFail)
                                    {
                                        NSLog(@"失败");
                                    }
                                }];
            }
        }
            break;
        case 200:
        {
            //cache
            [VJNYDataCache removeAllCache];
            VJNYSettingWithLabelTableViewCell* cell = (VJNYSettingWithLabelTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:4]];
            cell.detailView.text = @"0 KB";
        }
            break;
        default:
            break;
    }
}


#pragma mark - Custom Methods

- (IBAction)showSliderAction:(id)sender {
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTriggerSliderAction)]) {
        [_slideDelegate subViewDidTriggerSliderAction];
    }
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isMemberOfClass:UIPanGestureRecognizer.class]) {
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self.view];
        BOOL isVerticalPan = (fabsf(translation.x) < fabsf(translation.y));
        return !isVerticalPan;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isMemberOfClass:UIPanGestureRecognizer.class]) {
        return YES;
    } else {
        if ([_slideDelegate respondsToSelector:@selector(isSliderOff)]) {
            return ![_slideDelegate isSliderOff];
        }
        return NO;
    }
}

- (void)panToShowSliderAction:(UIPanGestureRecognizer *)sender {
    
    UIPanGestureRecognizer* gesture = sender;
    CGPoint translation = [gesture translationInView:self.view];
    [gesture setTranslation:CGPointZero inView:self.view];
    
    //NSLog(@"PanGesture:x-%f,y-%f",translation.x,translation.y);
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidDragSliderAction:AndGestureState:)]) {
        [_slideDelegate subViewDidDragSliderAction:translation AndGestureState:gesture.state];
    }
    
}

- (void)tapToDismissSliderAction:(UITapGestureRecognizer *)sender {
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTapOutsideSlider)]) {
        [_slideDelegate subViewDidTapOutsideSlider];
    }
    
}
@end
