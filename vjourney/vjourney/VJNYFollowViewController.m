//
//  VJNYFollowViewController.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYFollowViewController.h"

@interface VJNYFollowViewController ()
{
    NSMutableArray *_channelData;
    NSMutableDictionary* _channelUnreadDic;
    NSArray *_searchResult;
    
    MJRefreshFooterView *_footer;
}
@end

@implementation VJNYFollowViewController

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
    [VJNYUtilities initBgImageForTabView:self.view];
    [VJNYUtilities initBgImageForNaviBarWithTabView:self.navigationController];
    
    self.channelView.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 49.0f, 0.0f);
    self.channelView.scrollIndicatorInsets = UIEdgeInsetsMake(65.0f, 0.0f, 49.0f, 0.0f);
    self.channelView.separatorColor = [UIColor clearColor];
    
    // 1.初始化数据
    _channelData = [NSMutableArray array];
    _channelUnreadDic = [NSMutableDictionary dictionary];
    
    self.searchDisplayController.searchResultsTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_main.jpg"]];
    
    // 2.集成刷新控件
    /*MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.channelView;
    footer.delegate = self;
    _footer = footer;
    */
    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:[VJNYUtilities segueShowVideoPageByChannel]]) {
        
        NSIndexPath *indexPath = nil;
        VJNYPOJOChannel *channel = nil;
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            channel = [_searchResult objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.channelView indexPathForSelectedRow];
            channel = [_channelData objectAtIndex:indexPath.row];
        }
        VJNYVideoViewController *videoViewController = segue.destinationViewController;
        [videoViewController initWithChannel:channel andIsFollow:1];
    }
}

- (void)refreshData {
    
    [_channelData removeAllObjects];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    
    [VJNYHTTPHelper sendJSONRequest:@"channel/latest/user" WithParameters:dic AndDelegate:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResult count];
        
    } else {
        return [_channelData count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VJNYFollowChannelTableViewCell *cell = [self.channelView dequeueReusableCellWithIdentifier:[VJNYUtilities channelCellIdentifier]];
    //
    if (cell == nil) {
        cell = [[VJNYFollowChannelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[VJNYUtilities channelCellIdentifier]];
    }
    
    VJNYPOJOChannel *channel = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        channel = [_searchResult objectAtIndex:indexPath.row];
    } else {
        channel = [_channelData objectAtIndex:indexPath.row];
    }
    
    cell.bgMaskView.layer.cornerRadius = 5;
    cell.bgMaskView.layer.masksToBounds = YES;
    
    cell.image.layer.cornerRadius = 5;
    cell.image.layer.masksToBounds = YES;
    
    // Set up the cell...
    NSString* imageUrl = channel.coverUrl;
    UIImage* imageData = [[VJNYDataCache instance] dataByURL:imageUrl];
    if (imageData == nil) {
        [[VJNYDataCache instance] requestDataByURL:imageUrl WithDelegate:self AndIdentifier:indexPath AndMode:0];
        cell.image.image = nil;
    } else {
        cell.image.image = imageData;
    }
    cell.title.text = channel.name;
    cell.unReadLabel.text = @"";
    
    if (![[_channelUnreadDic objectForKey:channel.cid] isKindOfClass:[NSNull class]]) {
        NSNumber* unReadNumber = [_channelUnreadDic objectForKey:channel.cid];
        if (unReadNumber != nil && [unReadNumber longValue] > 0) {
            cell.unReadLabel.text = [unReadNumber stringValue];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
#pragma TODO
    [self.channelView deselectRowAtIndexPath:indexPath animated:YES];
}*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
        [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
        
        VJNYPOJOChannel* channel = [_channelData objectAtIndex:indexPath.row];
        
        [dic setObject:[channel.cid stringValue] forKey:@"channelId"];
        
        [VJNYHTTPHelper sendJSONRequest:@"channel/unFollow" WithParameters:dic AndDelegate:self];
        
        [_channelData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Cache Handler
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    assert(mode==0);
    
    NSIndexPath* path = (NSIndexPath*)identifier;
    if ([self.channelView.indexPathsForVisibleRows indexOfObject:path] == NSNotFound)
    {
        // This indeed is an indexPath no longer visible
        // Do something to this non-visible cell...
    } else {
        VJNYFollowChannelTableViewCell* cell = (VJNYFollowChannelTableViewCell*)[self.channelView cellForRowAtIndexPath:path];
        cell.image.image = data;
    }
}

#pragma mark - 刷新控件的代理方法
#pragma mark 开始进入刷新状态
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == _footer) {
        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:2.0];
    }
    
    NSLog(@"%@----开始进入刷新状态", refreshView.class);
}

#pragma mark 刷新完毕
- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView
{
    NSLog(@"%@----刷新完毕", refreshView.class);
}

#pragma mark 监听刷新状态的改变
- (void)refreshView:(MJRefreshBaseView *)refreshView stateChange:(MJRefreshState)state
{
    switch (state) {
        case MJRefreshStateNormal:
            NSLog(@"%@----切换到：普通状态", refreshView.class);
            break;
            
        case MJRefreshStatePulling:
            NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
            break;
            
        case MJRefreshStateRefreshing:
            NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
            break;
        default:
            break;
    }
}

#pragma mark 刷新表格并且结束正在刷新状态
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    [self.channelView reloadData];
    
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"channel/LatestByUser"]) {
        if (result.result == Success) {
            _channelData = result.response[0];
            _channelUnreadDic = result.response[1];
            
            [_channelData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSNumber* score1 = [NSNumber numberWithLong:-1l];
                NSNumber* score2 = [NSNumber numberWithLong:-1l];
                if (![[_channelUnreadDic objectForKey:((VJNYPOJOChannel*)obj1).cid] isKindOfClass:[NSNull class]]) {
                    NSNumber* unRead1 = [_channelUnreadDic objectForKey:((VJNYPOJOChannel*)obj1).cid];
                    if (unRead1 != nil) {
                        score1 = unRead1;
                    }
                }
                if (![[_channelUnreadDic objectForKey:((VJNYPOJOChannel*)obj2).cid] isKindOfClass:[NSNull class]]) {
                    NSNumber* unRead2 = [_channelUnreadDic objectForKey:((VJNYPOJOChannel*)obj2).cid];
                    if (unRead2 != nil) {
                        score2 = unRead2;
                    }
                }
                return [score1 compare:score2];
            }];
            
            [_channelView reloadData];
        }
    }
    
    // 当以二进制形式读取返回内容时用这个方法
    //NSData *responseData = [request responseData];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

- (void)dealloc
{
    [_footer free];
}

#pragma mark - Search Handler
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    _searchResult = [_channelData filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - custom Methods


@end
