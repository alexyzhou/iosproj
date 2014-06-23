//
//  VJNYVideoShareViewController.h
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYSelectCoverViewController.h"

@interface VJNYVideoShareViewController : UIViewController<UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegate,VJNYSelectCoverDelegate>
@property (weak, nonatomic) IBOutlet UIView *coverContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *coverPromoLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;


- (IBAction)tapToChangeCoverAction:(UITapGestureRecognizer *)sender;
- (IBAction)tapToBeginEditing:(UITapGestureRecognizer *)sender;
- (IBAction)gPSAction:(UIButton *)sender;
- (IBAction)uploadAction:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIView *textContainerView;
@property (weak, nonatomic) IBOutlet UITextField *textEditView;
@property (weak, nonatomic) IBOutlet UILabel *textTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *shareCardCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

// Custom Properties
@property (strong, nonatomic) NSURL* inputPath;

@end
