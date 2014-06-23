//
//  VJNYTabBarViewController.m
//  vjourney
//
//  Created by alex on 14-6-18.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYTabBarViewController.h"

@interface VJNYTabBarViewController ()

@end

@implementation VJNYTabBarViewController

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
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        
        switch (idx) {
            case 0:
                vc.tabBarItem.image = [[UIImage imageNamed:@"tab_whatsNew.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_whatsNew_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                break;
            case 1:
                vc.tabBarItem.image = [[UIImage imageNamed:@"tab_imIn.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_imIn_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                break;
            case 2:
                vc.tabBarItem.image = [[UIImage imageNamed:@"tab_notif.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_notif_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                break;
            case 3:
                vc.tabBarItem.image = [[UIImage imageNamed:@"tab_myPage.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_myPage_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                break;
            default:
                break;
        }
    }];
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
