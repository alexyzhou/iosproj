//
//  VJNYChannelSearchViewController.m
//  vjourney
//
//  Created by alex on 14-7-8.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYChannelSearchViewController.h"
#import "VJNYChannelCreateViewController.h"
#import "VJNYChannelTableViewCell.h"
#import "VJNYVideoViewController.h"
#import "VJNYPOJOChannel.h"
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"

@interface VJNYChannelSearchViewController () {
    NSMutableArray* _channelData;
    
    NSString* _searchedTitle;
}

@end

@implementation VJNYChannelSearchViewController

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
    
    _channelData = [NSMutableArray array];
    
    _searchedTitle = @"";
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:[VJNYUtilities segueShowVideoPageByChannel]]) {
        VJNYVideoViewController *videoViewController = segue.destinationViewController;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        VJNYPOJOChannel* channel = [_channelData objectAtIndex:indexPath.row];
        [videoViewController initWithChannel:channel andIsFollow:-1];
    } else if ([segue.identifier isEqualToString:[VJNYUtilities segueChannelCreatePage]]) {
        VJNYChannelCreateViewController* viewController = segue.destinationViewController;
        viewController.preferredTitle = _searchedTitle;
    }
}


#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([_searchedTitle isEqualToString:@""]) {
        return 0;
    } else {
        return [_channelData count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [_channelData count]) {
        VJNYChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities channelCellIdentifier]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.bgMaskView.layer.cornerRadius = 5;
        cell.bgMaskView.layer.masksToBounds = YES;
        
        cell.image.layer.cornerRadius = 5;
        cell.image.layer.masksToBounds = YES;
        
        // Set up the cell...
        NSString* imageUrl = ((VJNYPOJOChannel*)[_channelData objectAtIndex:indexPath.row]).coverUrl;
        UIImage* imageData = [[VJNYDataCache instance] dataByURL:imageUrl];
        if (imageData == nil) {
            [[VJNYDataCache instance] requestDataByURL:imageUrl WithDelegate:self AndIdentifier:indexPath AndMode:0];
            cell.image.image = nil;
        } else {
            cell.image.image = imageData;
        }
        cell.title.text = ((VJNYPOJOChannel*)[_channelData objectAtIndex:indexPath.row]).name;
        return cell;
    } else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities seggestCreateChannelCellIdentifier]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row < [_channelData count]) {
        [self performSegueWithIdentifier:[VJNYUtilities segueShowVideoPageByChannel] sender:self];
    } else {
        [self performSegueWithIdentifier:[VJNYUtilities segueChannelCreatePage] sender:self];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_channelData count]) {
        return 61;
    } else {
        return 121;
    }
}

#pragma mark - Cache Delegate

- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    
    if (mode == 0) {
        NSIndexPath* path = (NSIndexPath*)identifier;
        if ([self.tableView.indexPathsForVisibleRows indexOfObject:path] == NSNotFound)
        {
            // This indeed is an indexPath no longer visible
            // Do something to this non-visible cell...
        } else {
            VJNYChannelTableViewCell* cell = (VJNYChannelTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
            cell.image.image = data;
        }
    }
}

#pragma mark - HTTP Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"channel/Latest/Query/Name"]) {
        if (result.result == Success) {
            _channelData = result.response;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [VJNYUtilities dismissProgressAlertViewFromView:self.view];
                [self.tableView reloadData];
                if ([_channelData count] == 0) {
                    //[_addNewChannelView setHidden:NO];
                }
            });
            
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

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if ([searchBar.text isEqualToString:@""]) {
        return;
    }
    [searchBar resignFirstResponder];
    [VJNYUtilities showProgressAlertViewToView:self.view];
    NSString* filterString = searchBar.text;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setObject:filterString forKey:@"name"];
    [VJNYHTTPHelper sendJSONRequest:@"channel/latest/query/name" WithParameters:dic AndDelegate:self];
    
    _searchedTitle = filterString;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}

#pragma mark - Custom Button Methods

- (IBAction)cancelAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
