//
//  VJNYIPViewController.m
//  vjourney
//
//  Created by alex on 14-5-29.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYIPViewController.h"
#import "VJNYHTTPHelper.h"

@interface VJNYIPViewController ()

@end

@implementation VJNYIPViewController

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
    [VJNYHTTPHelper setIPAddr:self.ipAddrTextField.text];
}


@end
