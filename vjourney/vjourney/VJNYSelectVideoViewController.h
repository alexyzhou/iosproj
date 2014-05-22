//
//  VJNYSelectVideoViewController.h
//  vjourney
//
//  Created by alex on 14-5-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VJNYUploadViewController.h"

@interface VJNYSelectVideoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *videoListView;

@property(nonatomic,retain) NSMutableArray *listData;
@property(nonatomic,weak) VJNYUploadViewController* parent;

-(void)generateVideoList:(NSMutableArray*)allVideos;

@end
