//
//  VJNYVideoShareViewController.m
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoShareViewController.h"
#import "VJNYVideoCaptureViewController.h"
#import "VJNYUtilities.h"
#import "VJNYPOJOUser.h"
#import "VJNYShareCardCell.h"
#import <AVFoundation/AVFoundation.h>

#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"
#import "VJNYHTTPResultCode.h"

@interface VJNYVideoShareViewController () {
    NSMutableArray* _socialNetworkArray;
    
    BOOL _isShareOnWeibo;
    BOOL _isShareOnFb;
}

-(void)generateFirstCover;

@end

@implementation VJNYVideoShareViewController

@synthesize inputPath=_inputPath;

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
    
    self.weiboShareContainerView.layer.cornerRadius = 5.0f;
    self.weiboShareContainerView.layer.masksToBounds = YES;
    self.facebookShareContainerView.layer.cornerRadius = 5.0f;
    [self.facebookShareContainerView.layer setMasksToBounds:YES];
    
    _isShareOnFb = false;
    _isShareOnWeibo = false;
    
    // UI Customization
    _textContainerView.layer.cornerRadius = 15;
    _textContainerView.layer.masksToBounds = YES;
    
    //[VJNYUtilities addShadowForUIView:_coverContainerView];
    
    [VJNYUtilities addShadowForUIView:_shareCardCollectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.textTitleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:15];
    self.coverPromoLabel.font = [UIFont fontWithName:@"CenturyGothic" size:18];
    
    [self generateFirstCover];
    
    // Prepare Social Networks
    _socialNetworkArray = [NSMutableArray arrayWithCapacity:3];
    [_socialNetworkArray addObject:@"weibo"];
    [_socialNetworkArray addObject:@"fb"];
    [_socialNetworkArray addObject:@"twitter"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    VJNYVideoCaptureViewController* rootController = [[self.navigationController viewControllers] objectAtIndex:0];
    if (rootController.captureMode == WhisperMode) {
        [_textContainerView setHidden:YES];
        [_shareCardCollectionView setHidden:YES];
    }
}

#pragma mark - Keyboard

- (void)keyBoardWillShow:(NSNotification *)note{
    
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat originalY = self.view.frame.size.height - _textContainerView.frame.size.height - _textContainerView.frame.origin.y;
    CGFloat ty = originalY - rect.size.height - 74.0f + _contentScrollView.contentOffset.y;
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, ty);
    }];
    
}

- (void)keyBoardWillHide:(NSNotification *)note{
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_textEditView resignFirstResponder];
    return YES;
}

#pragma mark - Cover Image Helper
-(void)generateFirstCover {
    
    // Generate First Cover Page
    // Set up ImageGenerator
    AVURLAsset* _originalVideoAsset = [[AVURLAsset alloc] initWithURL:_inputPath options:nil];
    AVAssetTrack* track = [[_originalVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGAffineTransform txf = [track preferredTransform];
    UIInterfaceOrientation _videoOrientation = [VJNYUtilities orientationByPreferredTransform:txf];
    //CGSize videoSize = [track naturalSize];
    
    AVAssetImageGenerator* _thumbnailImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_originalVideoAsset];
    _thumbnailImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    _thumbnailImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    _thumbnailImageGenerator.maximumSize = CGSizeMake(_coverImageView.frame.size.width*2, _coverImageView.frame.size.height*2);
    
    // Set up Cover Image
    NSError *error;
    CMTime actualTime;
    CGImageRef imageRef = [_thumbnailImageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    _coverImageView.image = [VJNYUtilities uiImageByCGImage:imageRef WithOrientation:_videoOrientation AndScale:2.0f];
    
}

#pragma mark - Collection View Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_socialNetworkArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VJNYShareCardCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VJNYUtilities shareCardCellIdentifier] forIndexPath:indexPath];
    
    NSLog(@"%f-%f",cell.bounds.size.width,cell.bounds.size.height);
    
    //cell.backgroundImage.image = filter.cover;
    cell.imageView.backgroundColor = [UIColor redColor];
    
    return cell;
}

#pragma mark - Cover Selection Delegate

- (void)selectCoverDidCancel {
    
}

- (void)selectCoverDidDoneWithImage:(UIImage *)image {
    _coverImageView.image = image;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:[VJNYUtilities segueVideoCoverSelectPage]]) {
        UINavigationController* controller = segue.destinationViewController;
        VJNYSelectCoverViewController* rootController = [controller.viewControllers objectAtIndex:0];
        rootController.inputPath = sender;
        rootController.delegate = self;
    }
}


- (IBAction)tapToChangeCoverAction:(UITapGestureRecognizer *)sender {
    
    [self performSegueWithIdentifier:[VJNYUtilities segueVideoCoverSelectPage] sender:_inputPath];
    
}

- (IBAction)tapToBeginEditing:(UITapGestureRecognizer *)sender {
    
    if ([_textEditView isFirstResponder] == false) {
        [_textEditView becomeFirstResponder];
    }
    
}

- (IBAction)gPSAction:(UIButton *)sender {
}

- (IBAction)uploadAction:(UIBarButtonItem *)sender {
    
    VJNYVideoCaptureViewController* rootController = [self.navigationController.viewControllers objectAtIndex:0];
    
    if ([_textEditView.text isEqual:@""] && rootController.captureMode == GeneralMode) {
        [VJNYUtilities showAlert:@"Error" andContent:@"Please fill in your description"];
        [_textEditView becomeFirstResponder];
        return;
    }
    
    NSData* filedata = [NSData dataWithContentsOfURL:_inputPath];
    NSData* coverdata = UIImageJPEGRepresentation(_coverImageView.image,1.0f);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    
    if (rootController.captureMode == GeneralMode) {
        [dic setObject:_textEditView.text forKey:@"description"];
    }
    
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    
    [self dismissViewControllerAnimated:(rootController.captureMode != WhisperMode) completion:^{
        
        NSMutableDictionary* shareDic = [NSMutableDictionary dictionary];
        [shareDic setObject:[NSNumber numberWithBool:_isShareOnWeibo] forKey:@"weibo"];
        [shareDic setObject:[NSNumber numberWithBool:_isShareOnFb] forKey:@"fb"];
        
        if ([rootController.delegate respondsToSelector:@selector(videoReadyForUploadWithVideoData:AndCoverData:AndPostValue: AndShareOptions:)]) {
            [rootController.delegate videoReadyForUploadWithVideoData:filedata AndCoverData:coverdata AndPostValue:dic AndShareOptions:shareDic];
        }
        
    }];
    
    
}

- (IBAction)shareOnWeiboAction:(id)sender {
    
    _isShareOnWeibo = !_isShareOnWeibo;
    if (_isShareOnWeibo) {
        
        if ([ShareSDK hasAuthorizedWithType:ShareTypeSinaWeibo]) {
            _weiboShareContainerView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
        } else {
            [ShareSDK authWithType:ShareTypeSinaWeibo                                              //需要授权的平台类型
                           options:nil                                          //授权选项，包括视图定制，自动授权
                            result:^(SSAuthState state, id<ICMErrorInfo> error) {       //授权返回后的回调方法
                                if (state == SSAuthStateSuccess)
                                {
                                    _weiboShareContainerView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
                                }
                                else if (state == SSAuthStateFail)
                                {
                                    _weiboShareContainerView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f];
                                    _isShareOnWeibo = false;
                                }
                            }];
        }
    } else {
        _weiboShareContainerView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f];
    }
    
}

- (IBAction)shareOnFbAction:(id)sender {
    
    _isShareOnFb = !_isShareOnFb;
    if (_isShareOnFb) {
        
        if ([ShareSDK hasAuthorizedWithType:ShareTypeFacebook]) {
            _facebookShareContainerView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
        } else {
            [ShareSDK authWithType:ShareTypeFacebook                                              //需要授权的平台类型
                           options:nil                                          //授权选项，包括视图定制，自动授权
                            result:^(SSAuthState state, id<ICMErrorInfo> error) {       //授权返回后的回调方法
                                if (state == SSAuthStateSuccess)
                                {
                                    _facebookShareContainerView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
                                }
                                else if (state == SSAuthStateFail)
                                {
                                    _facebookShareContainerView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f];
                                    _isShareOnFb = false;
                                }
                            }];
        }
    } else {
        _facebookShareContainerView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f];
    }
    
}
@end
