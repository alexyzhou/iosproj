//
//  VJNYChannelCoverFlowCellView.h
//  vjourney
//
//  Created by alex on 14-5-23.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VJNYChannelCoverFlowCellView : UIView {
    float baseline;
    UIImageView* imageView;
}
/** The coverflow image. */
@property (strong,nonatomic) UIImage *image;

@property (strong,nonatomic) UILabel *title;

/** The height of the image. This property will help coverflow adjust views to display images with different heights. */
@property (assign,nonatomic) float baseline; // set this property for displaying images w/ different heights

@end
