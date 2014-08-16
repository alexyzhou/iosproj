//
//  VJNYChannelCreateViewController.m
//  vjourney
//
//  Created by alex on 14-7-8.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYChannelCreateViewController.h"
#import "VPImageCropperViewController.h"
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOUser.h"
#import "VJNYPOJOHttpResult.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define VJNYTOPIC_NAME_MAXLENGTH 20
#define VJNYTOPIC_DESCRIPTION_MAXLENGTH 100

@interface VJNYChannelCreateViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,VPImageCropperDelegate> {
    BOOL _isEditingTopicName;
    
    UIView* _uploadBannerView;
    
    BOOL _coverReady;
    BOOL _topicNameReady;
    BOOL _topicDescriptionReady;
}

@end

@implementation VJNYChannelCreateViewController

@synthesize preferredTitle=_preferredTitle;

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
    _uploadBannerView = nil;
    [self.saveTopicBarButton setEnabled:NO];
    _coverReady = false;
    _topicNameReady = false;
    _topicDescriptionReady = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [_topicInputField addTarget:self
                  action:@selector(topicNameChangedAction:)
        forControlEvents:UIControlEventEditingChanged];
    
    _isEditingTopicName = false;
    
    if (_preferredTitle != nil) {
        _topicInputField.text = _preferredTitle;
        [self topicNameChangedAction:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkAndSetSaveButton {
    [self.saveTopicBarButton setEnabled:_coverReady&&_topicNameReady&&_topicDescriptionReady];
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

#pragma mark - 键盘处理
#pragma mark 键盘即将显示
- (void)keyBoardWillShow:(NSNotification *)note{
    
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat ty = - rect.size.height;
    if (_isEditingTopicName) {
        ty += self.view.frame.size.height - self.topicInputField.frame.origin.y - self.topicInputField.frame.size.height - 8.0f;
    } else {
        ty += self.view.frame.size.height - self.descriptionInputField.frame.origin.y - self.descriptionInputField.frame.size.height - 8.0f;
    }
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, ty);
    }];
    
}
#pragma mark 键盘即将退出
- (void)keyBoardWillHide:(NSNotification *)note{
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _isEditingTopicName = true;
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _isEditingTopicName = false;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (_topicNameReady == false) {
        return false;
    }
    
    [self.topicInputField resignFirstResponder];
    return YES;
}

- (void)topicNameChangedAction:(id)sender {
    
    long remainingCount = VJNYTOPIC_NAME_MAXLENGTH - _topicInputField.text.length;
    if (remainingCount < 0) {
        self.topicRemainingCountLabel.textColor = [UIColor redColor];
    } else {
        self.topicRemainingCountLabel.textColor = [UIColor whiteColor];
    }
    
    self.topicRemainingCountLabel.text = [NSString stringWithFormat:@"(%ld)", remainingCount];
    _topicNameReady = remainingCount >= 0;
    [self checkAndSetSaveButton];
    
}

- (void)textViewDidChange:(UITextView *)textView {
    [self topicDescriptionChangedAction:nil];
}

- (void)topicDescriptionChangedAction:(id)sender {
    
    long remainingCount = VJNYTOPIC_DESCRIPTION_MAXLENGTH - _descriptionInputField.text.length;
    if (remainingCount < 0) {
        self.descriptionRemainingCountLabel.textColor = [UIColor redColor];
    } else  {
        self.descriptionRemainingCountLabel.textColor = [UIColor whiteColor];
    }
    
    self.descriptionRemainingCountLabel.text = [NSString stringWithFormat:@"(%ld)", remainingCount];
    _topicDescriptionReady = remainingCount >= 0;
    [self checkAndSetSaveButton];
}

/*
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
 
    long remainingCount = VJNYTOPIC_DESCRIPTION_MAXLENGTH - _descriptionInputField.text.length;
    long conReplateRange = (long)text.length - (long)range.length < remainingCount ? text.length : remainingCount;
    
    self.descriptionInputField.text = [self.descriptionInputField.text stringByReplacingCharactersInRange:range withString:[text substringToIndex:conReplateRange]];
 
    
    long remainingCount = VJNYTOPIC_DESCRIPTION_MAXLENGTH - _descriptionInputField.text.length;
    remainingCount += (long)text.length - (long)range.length;
    if (remainingCount <= 0) {
        self.descriptionRemainingCountLabel.textColor = [UIColor redColor];
    } else if (remainingCount > 0) {
        self.descriptionRemainingCountLabel.textColor = [UIColor whiteColor];
    } else {
        
    }
    
    self.descriptionRemainingCountLabel.text = [NSString stringWithFormat:@"(%ld)", remainingCount];
    _topicDescriptionReady = remainingCount >= 0;
    [self checkAndSetSaveButton];
    
    return YES;
}
*/
#pragma mark - Button Action Handler

- (IBAction)finishEditingDescriptionAction:(id)sender {
    
    if (_topicDescriptionReady == false) {
        return;
    }
    
    [self.descriptionInputField resignFirstResponder];
    
}

- (IBAction)saveTopicAction:(id)sender {
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:@"channel/add"]];
    
    NSData* imageData = UIImageJPEGRepresentation(_coverImageView.image, 0.2f);
    
    [request addData:imageData withFileName:@"test.jpg" andContentType:@"image/jpeg" forKey:@"cover"];
    // Success
    
    //[request setData:filedata forKey:@"file"];
    //[request setPostValue:@"test.mov" forKey:@"fileName"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    [dic setObject:_topicInputField.text forKey:@"name"];
    [dic setObject:_descriptionInputField.text forKey:@"description"];
    [dic setObject:[[NSNumber numberWithUnsignedInteger:imageData.length] stringValue] forKey:@"length"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    
    [request addPostValue:jsonString forKey:@"description"];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [request setUploadProgressDelegate:self];
    
    // Set Upload Banner
    _uploadBannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    [_uploadBannerView setBackgroundColor:[UIColor blueColor]];
    [_uploadBannerView setAlpha:0.5f];
    [self.navigationController.view addSubview:_uploadBannerView];
    [VJNYUtilities showProgressAlertViewToView:self.view];
    
}
- (IBAction)tapToSetCoverAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take a Picture", @"Choose from Camera", nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.navigationController.view];
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        // 拍照
        if ([VJNYUtilities isCameraAvailable] && [VJNYUtilities doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([VJNYUtilities isRearCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([VJNYUtilities isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
        }
    }
    
    NSLog(@"Index = %ld - Title = %@", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        portraitImg = [VJNYUtilities imageByScalingToMaxSize:portraitImg];
        
        CGFloat height_To_Crop = self.view.frame.size.height * 0.6f;
        
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg fullFrame:self.view.frame cropFrame:CGRectMake(0, self.view.frame.size.height/2.0f - height_To_Crop/2.0f, self.view.frame.size.width, height_To_Crop) limitScaleRatio:2.0 orientation:portraitImg.imageOrientation];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
        
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    UIImage *portraitImg = editedImage;
    self.coverImageView.image = portraitImg;
    _coverReady = true;
    [self checkAndSetSaveButton];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Upload Delegate

- (void)setProgress:(float)newProgress {
    NSLog(@"%f",newProgress);
    _uploadBannerView.frame = CGRectMake(0, 0, 320.0f*newProgress, 20);
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [VJNYUtilities dismissProgressAlertViewFromView:self.view];
        if ([result.action isEqualToString:@"channel/Add"]) {
            [UIView animateWithDuration:0.5f animations:^{
                [_uploadBannerView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [_uploadBannerView removeFromSuperview];
                _uploadBannerView = nil;
            }];
            if (result.result == Success) {
                [VJNYUtilities showAlertWithNoTitle:@"话题创建申请提交成功，请耐心等待审核!"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [VJNYUtilities showAlertWithNoTitle:[NSString stringWithFormat:@"Upload Failed!, Reason:%d",result.result]];
            }
        }
    });
    
    // 当以二进制形式读取返回内容时用这个方法
    //NSData *responseData = [request responseData];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [VJNYUtilities dismissProgressAlertViewFromView:self.view];
    [UIView animateWithDuration:0.5f animations:^{
        [_uploadBannerView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [_uploadBannerView removeFromSuperview];
        _uploadBannerView = nil;
    }];
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

@end
