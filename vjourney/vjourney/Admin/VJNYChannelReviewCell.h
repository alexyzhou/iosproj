//
//  VJNYChannelReviewCell.h
//  vjourney
//
//  Created by alex on 14-8-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYAdminProtocols.h"

@interface VJNYChannelReviewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)acceptAction:(id)sender;
- (IBAction)rejectAction:(id)sender;

@property (strong, nonatomic) NSNumber* channelId;
@property (strong, nonatomic) id<VJNYAdminChannelReviewDelegate> delegate;

@end
