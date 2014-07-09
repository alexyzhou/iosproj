//
//  VJNYSettingPrivacyViewController.m
//  vjourney
//
//  Created by alex on 14-7-10.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYSettingPrivacyViewController.h"

@interface VJNYSettingPrivacyViewController ()

@end

@implementation VJNYSettingPrivacyViewController

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
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                     [UIImage imageNamed:@"bg_main.jpg"]];
    
    
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

- (IBAction)topicPrivacyChangedAction:(UISwitch *)sender {
}

- (IBAction)videoPrivacyChangedAction:(UISwitch *)sender {
}
@end
