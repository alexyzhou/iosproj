//
//  VJNYChatThreadTableViewCell.h
//  vjourney
//
//  Created by alex on 14-6-27.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VJNYChatThreadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabelView;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabelView;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeLabelView;

@end
