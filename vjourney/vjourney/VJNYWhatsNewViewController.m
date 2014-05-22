//
//  VJNYWhatsNewViewController.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYWhatsNewViewController.h"

@interface VJNYWhatsNewViewController ()

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
    _instance = self;
    
    UISegmentedControl *statFilter = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"HOT", @"LATEST", nil]];
    //[statFilter setSegmentedControlStyle:UISegmentedControlStyleBar];
    statFilter.selectedSegmentIndex = 0;
    [statFilter sizeToFit];
    self.navigationItem.titleView = statFilter;
    
    // UITableView Related
    VJNYChannelTableViewController* controller = [[VJNYChannelTableViewController alloc] init];
    [controller.tableView setFrame:CGRectMake(0, 0, self.channelListView.frame.size.width, self.channelListView.frame.size.height)];
    _channelController = controller;
    _channelController.parent = self;
    [self.channelListView addSubview:_channelController.tableView];
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

#pragma mark - Button Event Handler

- (IBAction)searchChannelAction:(id)sender {
}

#pragma mark - custom Methods

-(void)enterVideoPageByChannelID:(NSInteger)channelID AndTitle:(NSString*)name {
    VJNYVideoViewController *videoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"videoListPage"];
    [videoViewController initWithChannelID:channelID andName:name];
    [self.navigationController pushViewController:videoViewController animated:YES];
}


@end
