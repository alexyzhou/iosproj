//
//  VJNYWhatsNewViewController.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYWhatsNewViewController.h"
#import "VJNYWelcomeViewController.h"
#import "VJDMModel.h"
#import "VJDMUser.h"
#import <ShareSDK/ShareSDK.h>

@interface VJNYWhatsNewViewController ()
{
    NSMutableArray *_promoChannelData;
    NSMutableArray *_channelData;
    
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
    
    TKCoverflowView *coverflow;
}
@end

@implementation VJNYWhatsNewViewController

static VJNYWhatsNewViewController* _instance = NULL;

+(VJNYWhatsNewViewController*)instance {
    return _instance;
}

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
    
    VJDMUser* user = (VJDMUser*)[[VJDMModel sharedInstance] getCurrentUser];
    if (user == nil) {
        VJNYWelcomeViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardWelcomePage]];
        [self presentViewController:controller animated:NO completion:nil];
    } else {
        [VJNYPOJOUser sharedInstance].uid = user.uid;
        [VJNYPOJOUser sharedInstance].name = user.name;
        [VJNYPOJOUser sharedInstance].username = user.username;
        [VJNYPOJOUser sharedInstance].avatarUrl = user.avatars_url;
        
        [VJNYPOJOUser sharedInstance].token = user.token;
        [VJNYPOJOUser sharedInstance].gender = user.gender;
        [VJNYPOJOUser sharedInstance].age = user.age;
        [VJNYPOJOUser sharedInstance].coverUrl = user.cover_url;
        
        [VJNYPOJOUser sharedInstance].description = user.user_description;
    }

    // Set up Background
    [VJNYUtilities initBgImageForTabView:self.view];
    [VJNYUtilities initBgImageForNaviBarWithTabView:self.navigationController];
    [VJNYUtilities voidBgImageForTabBarWithController:self.tabBarController];
    
    _instance = self;
    
    coverflow = nil;
    
    self.channelView.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 49.0f, 0.0f);
    self.channelView.scrollIndicatorInsets = UIEdgeInsetsMake(65.0f, 0.0f, 49.0f, 0.0f);
    self.channelView.separatorColor = [UIColor clearColor];
    
    // 1.初始化数据
    _channelData = [NSMutableArray array];
    _promoChannelData = nil;
    
    // 2.集成刷新控件
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.channelView;
    footer.delegate = self;
    _footer = footer;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.channelView;
    header.delegate = self;
    _header = header;
    
    [_header beginRefreshing];
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
    if ([segue.identifier isEqualToString:[VJNYUtilities segueShowVideoPageByChannel]]) {
        VJNYVideoViewController *videoViewController = segue.destinationViewController;
        NSIndexPath* indexPath = [self.channelView indexPathForSelectedRow];
        VJNYPOJOChannel* channel = [_channelData objectAtIndex:indexPath.row-1];
        [videoViewController initWithChannel:channel andIsFollow:-1];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_channelData count]+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        VJNYPromoChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities channelPromoCellIdentifier]];
        //
        if (cell == nil) {
            cell = [[VJNYPromoChannelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[VJNYUtilities channelPromoCellIdentifier]];
        }
        
        if (_promoChannelData == nil) {
            [VJNYHTTPHelper getJSONRequest:@"channel/promotion" WithParameters:nil AndDelegate:self];
        } else if (cell.channelArray != _promoChannelData) {
            cell.channelArray = _promoChannelData;
            [cell.collectionView reloadData];
        }
        
        /*if (coverflow == nil) {
            coverflow = [[TKCoverflowView alloc] initWithFrame:CGRectMake(0, 0, self.channelView.frame.size.width, 220)];
            coverflow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            coverflow.coverflowDelegate = self;
            coverflow.dataSource = self;
            coverflow.backgroundColor = [UIColor clearColor];
            [coverflow setNumberOfCovers:0];
            [VJNYHTTPHelper getJSONRequest:@"channel/promotion" WithParameters:nil AndDelegate:self];
            //coverflow.backgroundColor = [UIColor redColor];
            [cell.view addSubview:coverflow];
        }*/
        
        return cell;
        
    } else {
        VJNYChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities channelCellIdentifier]];
        //
        if (cell == nil) {
            cell = [[VJNYChannelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[VJNYUtilities channelCellIdentifier]];
        }
        
        cell.bgMaskView.layer.cornerRadius = 5;
        cell.bgMaskView.layer.masksToBounds = YES;
        
        cell.image.layer.cornerRadius = 5;
        cell.image.layer.masksToBounds = YES;
        
        // Set up the cell...
        NSString* imageUrl = ((VJNYPOJOChannel*)[_channelData objectAtIndex:indexPath.row-1]).coverUrl;
        UIImage* imageData = [[VJNYDataCache instance] dataByURL:imageUrl];
        if (imageData == nil) {
            [[VJNYDataCache instance] requestDataByURL:imageUrl WithDelegate:self AndIdentifier:indexPath AndMode:0];
            cell.image.image = nil;
        } else {
            cell.image.image = imageData;
        }
        cell.title.text = ((VJNYPOJOChannel*)[_channelData objectAtIndex:indexPath.row-1]).name;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 221;
    } else {
        return 61;
    }
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
        
    [self.channelView deselectRowAtIndexPath:indexPath animated:YES];
}*/

#pragma mark - Cache Handler
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    
    if (mode == 1) {
        VJNYChannelCoverFlowCellView *cover = [coverflow coverAtIndex:[(NSNumber*)identifier intValue]];
        cover.image = data;
    } else if (mode == 0) {
        NSIndexPath* path = (NSIndexPath*)identifier;
        if ([self.channelView.indexPathsForVisibleRows indexOfObject:path] == NSNotFound)
        {
            // This indeed is an indexPath no longer visible
            // Do something to this non-visible cell...
        } else {
            VJNYChannelTableViewCell* cell = (VJNYChannelTableViewCell*)[self.channelView cellForRowAtIndexPath:path];
            cell.image.image = data;
        }
    }
}

#pragma mark - 刷新控件的代理方法
#pragma mark 开始进入刷新状态
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == _header) {
        //reload Data
        if ([_segmentedControl selectedSegmentIndex] == 0) {
            // hot
            [VJNYHTTPHelper getJSONRequest:@"channel/hot" WithParameters:nil AndDelegate:self];
        } else {
            // latest
            [VJNYHTTPHelper getJSONRequest:@"channel/latest" WithParameters:nil AndDelegate:self];
        }
        
    } else if (refreshView == _footer) {
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
    if ([result.action isEqualToString:@"channel/Latest"] || [result.action isEqualToString:@"channel/Hot"]) {
        if (result.result == Success) {
            _channelData = result.response;
            [self doneWithView:_header];
            //[self.channelView reloadData];
        }
    } else if ([result.action isEqualToString:@"channel/Promo"]) {
        if (result.result == Success) {
            _promoChannelData = result.response;
            VJNYPromoChannelTableViewCell* headCell = (VJNYPromoChannelTableViewCell*)[_channelView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            headCell.channelArray = _promoChannelData;
            [headCell.collectionView reloadData];
            
            [self performSelector:@selector(autoScrollPromoCoverCollectionView) withObject:nil afterDelay:5];
            
            //[coverflow setNumberOfCovers:(int)[_promoChannelData count]];
            //[coverflow bringCoverAtIndexToFront:(int)[_promoChannelData count]/2 animated:NO];
            //[self performSelector:@selector(flipCoverFlowView) withObject:nil afterDelay:5];
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
    [_header free];
    [_footer free];
}

#pragma mark - Cover Flow Handler
- (void) coverflowView:(TKCoverflowView*)coverflowView coverAtIndexWasBroughtToFront:(int)index{
	//NSLog(@"Front %d",index);
}
- (VJNYChannelCoverFlowCellView*) coverflowView:(TKCoverflowView*)coverflowView coverAtIndex:(int)index{
	
	VJNYChannelCoverFlowCellView *cover = [coverflowView dequeueReusableCoverView];
	
	if(cover == nil){
        float newSize = coverflow.frame.size.height * 0.9f;
		
		cover = [[VJNYChannelCoverFlowCellView alloc] initWithFrame:CGRectMake(0, 0, newSize, newSize)]; // 224
		cover.baseline = newSize;
		
	}
    NSString* imageUrl = ((VJNYPOJOChannel*)[_promoChannelData objectAtIndex:index]).coverUrl;
    UIImage* imageData = [[VJNYDataCache instance] dataByURL:imageUrl];
    if (imageData == nil) {
        [[VJNYDataCache instance] requestDataByURL:imageUrl WithDelegate:self AndIdentifier:[NSNumber numberWithInt:index] AndMode:1];
        cover.image = nil;
    } else {
        cover.image = imageData;
    }
    cover.title.text = ((VJNYPOJOChannel*)[_promoChannelData objectAtIndex:index]).name;
	return cover;
}
- (void) coverflowView:(TKCoverflowView*)coverflowView coverAtIndexWasTapped:(int)index{
	
	VJNYChannelCoverFlowCellView *cover = [coverflowView coverAtIndex:index];
	if(cover == nil) return;
	
    VJNYPOJOChannel* channel = (VJNYPOJOChannel*)[_promoChannelData objectAtIndex:index];
    
    VJNYVideoViewController *videoViewController = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardVideoListPage]];
    [videoViewController initWithChannel:channel andIsFollow:-1];
    
    [self.navigationController pushViewController:videoViewController animated:YES];
    
}

- (void) flipCoverFlowView {
    
    VJNYChannelCoverFlowCellView *cover = [coverflow coverAtIndex:(int)[coverflow currentIndex]];
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cover cache:YES];
	[UIView commitAnimations];
    
    [self performSelector:@selector(flipCoverFlowView) withObject:nil afterDelay:5];
}

- (void) autoScrollPromoCoverCollectionView {
    
    if ([[_channelView indexPathsForVisibleRows] containsObject:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        VJNYPromoChannelTableViewCell* cell = (VJNYPromoChannelTableViewCell*)[_channelView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        long nextRow = (cell.pageControl.currentPage + 1) % cell.pageControl.numberOfPages;
        [cell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:nextRow inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        cell.pageControl.currentPage = nextRow;
    }
    
    [self performSelector:@selector(autoScrollPromoCoverCollectionView) withObject:nil afterDelay:5];
}

- (void)promoCoverWasTapped:(int)index {
    VJNYPOJOChannel* channel = (VJNYPOJOChannel*)[_promoChannelData objectAtIndex:index];
    
    VJNYVideoViewController *videoViewController = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardVideoListPage]];
    [videoViewController initWithChannel:channel andIsFollow:-1];
    
    [self.navigationController pushViewController:videoViewController animated:YES];
}

#pragma mark - Button Event Handler

- (IBAction)searchChannelAction:(id)sender {
    //NSLog(@"%@",[VJNYDataCache cacheTotalSize]);
    [self performSegueWithIdentifier:[VJNYUtilities segueChannelSearchPage] sender:nil];
}

- (IBAction)segmentedFilterClickAction:(id)sender {
    if ([_segmentedControl selectedSegmentIndex] == 0) {
        // hot
        [VJNYHTTPHelper getJSONRequest:@"channel/hot" WithParameters:nil AndDelegate:self];
    } else {
        // latest
        [VJNYHTTPHelper getJSONRequest:@"channel/latest" WithParameters:nil AndDelegate:self];
    }
}

#pragma mark - custom Methods


@end
