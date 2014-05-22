//
//  VJNYVideoViewController.m
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoViewController.h"

@interface VJNYVideoViewController ()

@end

@implementation VJNYVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initWithChannelID:(NSInteger)channelID andName:(NSString*)name {
    _channelID = channelID;
    _channelName = name;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _channelName;
    
    VJNYVideoTableViewController* controller = [[VJNYVideoTableViewController alloc] init];
    [controller.tableView setFrame:CGRectMake(0, 0, self.videoListView.frame.size.width, self.videoListView.frame.size.height)];
    _videoController = controller;
    _videoController.channelId = _channelID;
    [self.videoListView addSubview:_videoController.tableView];
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

@end
