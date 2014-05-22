//
//  VJNYVideoViewController.h
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYVideoTableViewController.h"

@interface VJNYVideoViewController : UIViewController {
    NSInteger _channelID;
    NSString* _channelName;
    VJNYVideoTableViewController* _videoController;
}
@property (weak, nonatomic) IBOutlet UIView *videoListView;

-(void)initWithChannelID:(NSInteger)channelID andName:(NSString*)name;

@end
