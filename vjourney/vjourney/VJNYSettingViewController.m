//
//  VJNYSettingViewController.m
//  vjourney
//
//  Created by alex on 14-7-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYSettingViewController.h"
#import "VJNYUtilities.h"
#import "VJNYDataCache.h"

@interface VJNYSettingViewController ()

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
    self.settingLabel.font = [VJNYUtilities customFontWithSize:18.0f];
    self.settingOtherLabel.font = [VJNYUtilities customFontWithSize:18.0f];
    
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
    return 5;
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
            return 3;
            break;
        case 4:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell;
    
    switch (indexPath.section) {
        case 0:
            ;
            cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities settingGeneralCellIdentifier]];
            cell.textLabel.text = @"Drafts";
            break;
        case 1:
            ;
            cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities settingGeneralCellIdentifier]];
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Language Settings";
            }
            break;
        case 2:
            ;
            cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities settingGeneralCellIdentifier]];
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Privacy";
            } else {
                cell.textLabel.text = @"Tutorial";
            }
            break;
        case 3:
            ;
            cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities settingGeneralCellIdentifier]];
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Feedback";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"About Vjourney";
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"Clear Cache (%@)",[VJNYDataCache cacheTotalSize]];
            }
            break;
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities settingLogoutCellIdentifier]];
            break;
        default:
            break;
    }
    if (indexPath.section < 4) {
        cell.textLabel.textColor = [UIColor colorWithRed:15.0/255.0 green:44.0/255.0 blue:77.0/255.0 alpha:1.0f];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
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
