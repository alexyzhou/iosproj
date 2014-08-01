//
//  VJNYChannelCreateViewController.h
//  vjourney
//
//  Created by alex on 14-7-8.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"

@interface VJNYChannelCreateViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,ASIHTTPRequestDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *coverLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *topicInputField;
@property (weak, nonatomic) IBOutlet UILabel *topicRemainingCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionInputField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionRemainingCountLabel;
- (IBAction)finishEditingDescriptionAction:(id)sender;
- (IBAction)saveTopicAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveTopicBarButton;
- (IBAction)tapToSetCoverAction:(id)sender;


#pragma mark - Custom Variables
@property (strong, nonatomic) NSString* preferredTitle;

@end
