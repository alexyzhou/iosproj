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
#import "VJDMUserAvatar.h"
#import "VJNYPOJOUser.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"

@interface VJNYChatListViewController () {
    NSMutableArray* _threadArray;
    NSMutableArray* _filteredThreadArray;
    UIActivityIndicatorView* _activityIndicator;
    
    BOOL _isSearchMode;
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
    _isSearchMode = false;
    [VJNYUtilities initBgImageForNaviBarWithTabView:self.navigationController];
    
    _threadArray = [[[VJDMModel sharedInstance] getThreadList] mutableCopy];
    _filteredThreadArray = [NSMutableArray array];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToShowSliderAction:)];
    [self.tableView addGestureRecognizer:panGesture];
    panGesture.delegate = self;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissSliderAction:)];
    [self.tableView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 49.0f, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 49.0f, 0)];
    
    self.searchBarCancelButton.alpha = 0.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    // Network Stuff
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    dic[@"userId"]=[[VJNYPOJOUser sharedInstance].uid stringValue];
    [VJNYHTTPHelper sendJSONRequest:@"notif/chat/get" WithParameters:dic AndDelegate:self];
    
    //self.navigationItem.titleView = _activityIndicator;
    //[_activityIndicator startAnimating];
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
    if (_isSearchMode) {
        return _filteredThreadArray.count;
    } else {
        return _threadArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VJNYChatThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities chatThreadCellIdentifier]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    VJDMThread* thread;
    if (_isSearchMode) {
        thread = [_filteredThreadArray objectAtIndex:indexPath.row];
    } else {
        thread = [_threadArray objectAtIndex:indexPath.row];
    }
    
    // 设置数据
    
    VJDMUserAvatar* avatar = (VJDMUserAvatar*)[[VJDMModel sharedInstance] getUserAvatarByUserID:thread.target_id];
    if (avatar != nil) {
        [VJNYDataCache loadImage:cell.avatarImageView WithUrl:avatar.avatarUrl AndMode:0 AndIdentifier:indexPath AndDelegate:self];
    } else {
        [VJNYHTTPHelper getJSONRequest:[@"user/avatarUrl/" stringByAppendingString:[thread.target_id stringValue]] WithParameters:nil AndDelegate:self];
    }
    [VJNYUtilities addRoundMaskForUIView:cell.avatarImageView];
    cell.nameLabelView.text = thread.target_name;
    cell.lastMessageLabelView.text = thread.last_message;
    cell.lastTimeLabelView.text = [VJNYUtilities formatDataString:thread.last_time];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 81;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:[VJNYUtilities segueChatDetailpage] sender:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        VJDMThread* thread;
        if (_isSearchMode) {
            thread = [_filteredThreadArray objectAtIndex:indexPath.row];
            [_filteredThreadArray removeObjectAtIndex:indexPath.row];
            
            int i = 0;
            for (; i < _threadArray.count; i++) {
                VJDMThread* threadToTest = [_threadArray objectAtIndex:i];
                if ([threadToTest.target_id isEqualToNumber:thread.target_id]) {
                    break;
                }
            }
            if (i < _threadArray.count) {
                [_threadArray removeObjectAtIndex:i];
            }
            
        } else {
            thread = [_threadArray objectAtIndex:indexPath.row];
            [_threadArray removeObjectAtIndex:indexPath.row];
        }
        
        [[VJDMModel sharedInstance] removeThreadAndMessageByID:thread.target_id];
        
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
    } else if ([result.action isEqualToString:@"user/AvatarUrl"]) {
        if (result.result == Success) {
            VJDMUserAvatar* avatar = result.response;
            for (NSIndexPath* path in [self.tableView indexPathsForVisibleRows]) {
                VJDMThread* thread = [_threadArray objectAtIndex:path.row];
                if ([thread.target_id isEqualToNumber:avatar.userId]) {
                    VJNYChatThreadTableViewCell* cell = (VJNYChatThreadTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
                    [VJNYDataCache loadImage:cell.avatarImageView WithUrl:avatar.avatarUrl AndMode:0 AndIdentifier:path AndDelegate:self];
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

- (IBAction)showSliderAction:(id)sender {
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTriggerSliderAction:)]) {
        [_slideDelegate subViewDidTriggerSliderAction:self.view];
    }
}

- (IBAction)cancelSearchAction:(id)sender {
    _isSearchMode = false;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
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
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidDragSliderAction:AndGestureState:AndView:)]) {
        [_slideDelegate subViewDidDragSliderAction:translation AndGestureState:gesture.state AndView:self.view];
    }
    
}

- (void)tapToDismissSliderAction:(UITapGestureRecognizer *)sender {
    
    if ([_slideDelegate respondsToSelector:@selector(subViewDidTapOutsideSlider:)]) {
        [_slideDelegate subViewDidTapOutsideSlider:self.view];
    }
    
}

#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [UIView animateWithDuration:0.5f animations:^{
        self.searchBarCancelButton.alpha = 1.0f;
    }];
    _isSearchMode = true;
    //return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [UIView animateWithDuration:0.1f animations:^{
        self.searchBarCancelButton.alpha = 0.0f;
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateSearchResult];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)updateSearchResult {
    
    [_filteredThreadArray removeAllObjects];
    
    for (int i = 0; i < _threadArray.count; i++) {
        VJDMThread* thread = [_threadArray objectAtIndex:i];
        if ([thread.target_name rangeOfString:self.searchBar.text options:0].location != NSNotFound) {
            [_filteredThreadArray addObject:thread];
        }
    }
    
    [self.tableView reloadData];
}

@end
