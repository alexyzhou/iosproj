//
//  VJNYSettingWithLabelTableViewCell.h
//  vjourney
//
//  Created by alex on 14-7-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VJNYSettingWithLabelTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *detailView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
