//
//  VJNYMyStoryViewController.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYMyStoryViewController.h"
#import "VJNYUserProfileViewController.h"
#import "VJNYPOJOUser.h"
#import "VJNYUtilities.h"

@interface VJNYMyStoryViewController ()

@end

@implementation VJNYMyStoryViewController

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
    VJNYUserProfileViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:[VJNYUtilities storyboardUserProfilePage]];
    controller.userId = [VJNYPOJOUser sharedInstance].uid;
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
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
