//
//  VJNYChatListViewController.m
//  vjourney
//
//  Created by alex on 14-6-27.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYChatListViewController.h"
#import "VJNYChatThreadTableViewCell.h"
#import "VJNYChatViewController.h"
#import "VJNYUtilities.h"
#import "VJDMThread.h"
#import "VJDMModel.h"
#import "VJNYPOJOUser.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"

@interface VJNYChatListViewController () {
    NSMutableArray* _threadArray;
    UIActivityIndicatorView* _activityIndicator;
}

@end

@implementation VJNYChatListViewController

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
    
    _threadArray = [[[VJDMModel sharedInstance] getThreadList] mutableCopy];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToShowSliderAction:)];
    [self.tableView addGestureRecognizer:panGesture];
    panGesture.delegate = self;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissSliderAction:)];
    [self.tableView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Network Stuff
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    dic[@"userId"]=[[VJNYPOJOUser sharedInstance].uid stringValue];
    [VJNYHTTPHelper sendJSONRequest:@"notif/chat/get" WithParameters:dic AndDelegate:self];
    
    self.navigationItem.titleView = _activityIndicator;
    [_activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    VJNYChatViewController* controller = segue.destinationViewController;
    VJDMThread* thread = _threadArray[((NSIndexPath*)sender).row];
    VJNYChatThreadTableViewCell* cell = (VJNYChatThreadTableViewCell*)[self.tableView cellForRowAtIndexPath:sender];
    controller.target_avatar = cell.avatarImageView.image;
    controller.target_id = thread.target_id;
    controller.target_name = cell.nameLabelView.text;
    controller.target_avatar_url = thread.avatar_url;
}


#pragma mark - Cache Handler

- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    if (mode == 0) {
        NSIndexPath* path = identifier;
        if ([[self.tableView indexPathsForVisibleRows] containsObject:path]) {
            VJNYChatThreadTableViewCell* cell = (VJNYChatThreadTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
            cell.avatarImageView.image = data;
        }
    }
}

#pragma mark - tableView数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _threadArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VJNYChatThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities chatThreadCellIdentifier]];
    
    VJDMThread* thread = [_threadArray objectAtIndex:indexPath.row];
    
    // 设置数据
    [VJNYDataCache loadImage:cell.avatarImageView WithUrl:[[VJNYHTTPHelper pathUrlPrefix] stringByAppendingString:thread.avatar_url] AndMode:0 AndIdentifier:indexPath AndDelegate:self];
    cell.nameLabelView.text = thread.target_name;
    cell.lastMessageLabelView.text = thread.last_message;
    cell.lastTimeLabelView.text = [VJNYUtilities formatDataString:thread.last_time];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 61;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:[VJNYUtilities segueChatDetailpage] sender:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        VJDMThread* thread = [_threadArray objectAtIndex:indexPath.row];
        [[VJDMModel sharedInstance] removeThreadAndMessageByID:thread.target_id];
        
        [_threadArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [_activityIndicator stopAnimating];
    self.navigationItem.titleView = nil;
    
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"notif/Chat/Get"]) {
        _threadArray = [[[VJDMModel sharedInstance] getThreadList] mutableCopy];
        [self.tableView reloadData];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

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
