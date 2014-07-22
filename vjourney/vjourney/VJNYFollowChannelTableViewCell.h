//
//  VJNYFollowChannelTableViewCell.h
//  vjourney
//
//  Created by alex on 14-7-22.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VJNYFollowChannelTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIView *bgMaskView;
@property (weak, nonatomic) IBOutlet UILabel *unReadLabel;

@end
