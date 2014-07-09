//
//  VJNYSysNotifViewController.m
//  vjourney
//
//  Created by alex on 14-6-28.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYSysNotifViewController.h"
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"
#import "VJDMNotification.h"
#import "VJDMModel.h"
#import "VJDMUserAvatar.h"
#import "VJNYSysNotifTableViewCell.h"

@interface VJNYSysNotifViewController () {
    NSMutableArray* _notifArray;
    NSMutableArray* _notifHeightArray;
    UIActivityIndicatorView* _activityIndicator;
}

@end

@implementation VJNYSysNotifViewController

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
    _notifArray = [[[VJDMModel sharedInstance] getNotifList] mutableCopy];
    [self initHeightArrayForNotification];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [VJNYDataCache loadImage:self.userAvatarImageView WithUrl:[VJNYPOJOUser sharedInstance].avatarUrl AndMode:1 AndIdentifier:[[NSObject alloc] init] AndDelegate:self];
    self.userNameLabel.text = [VJNYPOJOUser sharedInstance].name;
    self.userNameLabel.font = [VJNYUtilities customFontWithSize:23];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToShowSliderAction:)];
    [self.view addGestureRecognizer:panGesture];
    panGesture.delegate = self;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissSliderAction:)];
    [self.view addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Network Stuff
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    dic[@"userId"]=[[VJNYPOJOUser sharedInstance].uid stringValue];
    [VJNYHTTPHelper sendJSONRequest:@"notif/sysNotif/get" WithParameters:dic AndDelegate:self];
    
    self.navigationItem.titleView = _activityIndicator;
    [_activityIndicator startAnimating];
    
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

#pragma mark - Helper
- (void)initHeightArrayForNotification {
    _notifHeightArray = [NSMutableArray arrayWithCapacity:[_notifArray count]];
    for (unsigned long i = 0; i < _notifArray.count; i++) {
        VJDMNotification* notif = _notifArray[i];
        
        CGRect textRect = [[notif contentStringByType] boundingRectWithSize:CGSizeMake(192.0f, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:[VJNYUtilities customFontWithSize:14.0f]}
                                                         context:nil];
        
        CGSize contentSize = textRect.size;
        
        [_notifHeightArray addObject:[NSNumber numberWithDouble:(contentSize.height + 30)]];
    }
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

#pragma mark - Cache Handler

- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    if (mode == 0) {
        NSIndexPath* path = identifier;
        if ([[self.sysNotifTableView indexPathsForVisibleRows] containsObject:path]) {
            VJNYSysNotifTableViewCell* cell = (VJNYSysNotifTableViewCell*)[self.sysNotifTableView cellForRowAtIndexPath:path];
            cell.avatarImageView.image = data;
        }
    } else if (mode == 1) {
        self.userAvatarImageView.image = data;
    }
}

#pragma mark - tableView数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _notifArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VJNYSysNotifTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities sysNotifCellIdentifier]];
    
    VJDMNotification* notif = [_notifArray objectAtIndex:indexPath.row];
    
    // 设置数据
    
    if ([notif.sender_id longValue] >= 0) {
        VJDMUserAvatar* avatar = (VJDMUserAvatar*)[[VJDMModel sharedInstance] getUserAvatarByUserID:notif.sender_id];
        if (avatar != nil) {
            [VJNYDataCache loadImage:cell.avatarImageView WithUrl:[[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:avatar.avatarUrl] AndMode:0 AndIdentifier:indexPath AndDelegate:self];
        } else {
            [VJNYHTTPHelper getJSONRequest:[@"user/avatarUrl/" stringByAppendingString:[notif.sender_id stringValue]] WithParameters:nil AndDelegate:self];
        }
    }
    
    CGRect rect = cell.contentLabel.frame;
    rect.size.height = [_notifHeightArray[indexPath.row] doubleValue] - 14.0f;
    [cell.contentLabel setFrame:rect];
    
    cell.contentLabel.text = [notif contentStringByType];
    cell.contentLabel.font = [VJNYUtilities customFontWithSize:14.0];
    
    
    
    //NSLog(@"%@",cell.contentLabel.text);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [_notifHeightArray[indexPath.row] doubleValue];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        VJDMNotification* notif = [_notifArray objectAtIndex:indexPath.row];
        [[VJDMModel sharedInstance] removeManagedObject:notif];
        
        [_notifArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [_activityIndicator stopAnimating];
    self.navigationItem.titleView = nil;
    
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"notif/SysNotif/Get"]) {
        if ([result.response boolValue] == true) {
            _notifArray = [[[VJDMModel sharedInstance] getNotifList] mutableCopy];
            [self initHeightArrayForNotification];
            [self.sysNotifTableView reloadData];
        }
    } else if ([result.action isEqualToString:@"user/AvatarUrl"]) {
        if (result.result == Success) {
            VJDMUserAvatar* avatar = result.response;
            for (NSIndexPath* path in [self.sysNotifTableView indexPathsForVisibleRows]) {
                VJDMNotification* notif = [_notifArray objectAtIndex:path.row];
                if ([notif.sender_id isEqualToNumber:avatar.userId]) {
                    VJNYSysNotifTableViewCell* cell = (VJNYSysNotifTableViewCell*)[self.sysNotifTableView cellForRowAtIndexPath:path];
                    [VJNYDataCache loadImage:cell.avatarImageView WithUrl:[[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:avatar.avatarUrl] AndMode:0 AndIdentifier:path AndDelegate:self];
                    break;
                }
            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

#pragma mark - Custom Button Action

- (IBAction)sideAction:(id)sender {
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTriggerSliderAction)]) {
        [_slideDelegate subViewDidTriggerSliderAction];
    }
}

- (IBAction)panToShowSliderAction:(UIPanGestureRecognizer *)sender {
    
    UIPanGestureRecognizer* gesture = sender;
    CGPoint translation = [gesture translationInView:self.view];
    [gesture setTranslation:CGPointZero inView:self.view];
    
    //NSLog(@"PanGesture:x-%f,y-%f",translation.x,translation.y);
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidDragSliderAction:AndGestureState:)]) {
        [_slideDelegate subViewDidDragSliderAction:translation AndGestureState:gesture.state];
    }
    
}

- (IBAction)tapToDismissSliderAction:(UITapGestureRecognizer *)sender {
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTapOutsideSlider)]) {
        [_slideDelegate subViewDidTapOutsideSlider];
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

@end
