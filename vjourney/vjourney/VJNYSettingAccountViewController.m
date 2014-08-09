//
//  VJNYSettingAccountViewController.m
//  vjourney
//
//  Created by alex on 14-8-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYSettingAccountViewController.h"
#import "VJNYUtilities.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"

#import "VJDMModel.h"
#import "VJDMUser.h"

@interface VJNYSettingAccountViewController () {
    BOOL _usernameReady;
    BOOL _nameReady;
    BOOL _ageReady;
    BOOL _descriptionReady;
    
    int _editingMode;
}

@end

@implementation VJNYSettingAccountViewController

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
    
    [self setTitle:@"Update Account"];
    
    _usernameInput.text = [VJNYPOJOUser sharedInstance].username;
    _nameInput.text = [VJNYPOJOUser sharedInstance].name;
    _ageInput.text = [[VJNYPOJOUser sharedInstance].age stringValue];
    _descriptionInput.text = [VJNYPOJOUser sharedInstance].description;
    _genderSegmentedControl.selectedSegmentIndex = [[VJNYPOJOUser sharedInstance].gender isEqualToString:@"M"] ? 0 : 1;
    
    _usernameReady = true;
    _nameReady = true;
    _ageReady = true;
    _descriptionReady = true;
    [self checkAndSetSaveButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [_usernameInput addTarget:self
                       action:@selector(textFieldChangeAction:)
             forControlEvents:UIControlEventEditingChanged];
    
    [_passwordInput addTarget:self
                       action:@selector(textFieldChangeAction:)
             forControlEvents:UIControlEventEditingChanged];
    
    [_nameInput addTarget:self
                   action:@selector(textFieldChangeAction:)
         forControlEvents:UIControlEventEditingChanged];
    
    [_ageInput addTarget:self
                  action:@selector(textFieldChangeAction:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkAndSetSaveButton {
    [self.navigationItem.rightBarButtonItem setEnabled:_usernameReady&&_nameReady&&_ageReady&&_descriptionReady];
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
    
    if (_editingMode < 3) {
        return;
    }
    
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat ty = - rect.size.height;
    
    switch (_editingMode) {
        case 0:
            //Username
        {
            ty += self.view.frame.size.height - self.usernameInput.frame.origin.y - self.usernameInput.frame.size.height - 8.0f;
            break;
        }
        case 1:
            //Password
        {
            ty += self.view.frame.size.height - self.passwordInput.frame.origin.y - self.passwordInput.frame.size.height - 8.0f;
            break;
        }
        case 2:
            //Name
        {
            ty += self.view.frame.size.height - self.nameInput.frame.origin.y - self.nameInput.frame.size.height - 8.0f;
            break;
        }
        case 3:
            //Age
        {
            ty += self.view.frame.size.height - self.ageInput.frame.origin.y - self.ageInput.frame.size.height - 8.0f;
            break;
        }
        case 4:
            //Description
        {
            ty += self.view.frame.size.height - self.descriptionInput.frame.origin.y - self.descriptionInput.frame.size.height - 8.0f;
            break;
        }
        default:
            break;
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
    
    if (textField == self.usernameInput) {
        _editingMode = 0;
    } else if (textField == self.passwordInput) {
        _editingMode = 1;
    } else if (textField == self.nameInput) {
        _editingMode = 2;
    } else if (textField == self.ageInput) {
        _editingMode = 3;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _editingMode = 4;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    
    if (self.usernameInput == tf) {
        
        if (_usernameReady == false) {
            return false;
        }
        
        [self.usernameInput resignFirstResponder];
    } else if (self.nameInput == tf) {
        
        if (_nameReady == false) {
            return false;
        }
        
        [self.nameInput resignFirstResponder];
    } else if (self.ageInput == tf) {
        
        if (_ageReady == false) {
            return false;
        }
        
        [self.ageInput resignFirstResponder];
    }
    return true;
}

#define NUMBERS @"0123456789\n"

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *cs;
    if(textField == _ageInput)
    {
        cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL basicTest = [string isEqualToString:filtered];
        if(!basicTest)
        {
            return NO;
        }
    }
    //其他的类型不需要检测，直接写入
    return YES;
}

- (void)textFieldChangeAction:(UITextField*)textField {
    
    if (textField == self.usernameInput) {
        long remainingCount = 20 - _usernameInput.text.length;
        if (remainingCount < 0) {
            self.usernameCount.textColor = [UIColor redColor];
        } else {
            self.usernameCount.textColor = [UIColor whiteColor];
        }
        
        self.usernameCount.text = [NSString stringWithFormat:@"(%ld)", remainingCount];
        _usernameReady = remainingCount >= 0 && remainingCount < 20;
    } else if (textField == self.nameInput) {
        long remainingCount = 10 - _nameInput.text.length;
        if (remainingCount < 0) {
            self.nameCount.textColor = [UIColor redColor];
        } else {
            self.nameCount.textColor = [UIColor whiteColor];
        }
        
        self.nameCount.text = [NSString stringWithFormat:@"(%ld)", remainingCount];
        _nameReady = remainingCount >= 0 && remainingCount < 10;
    } else if (textField == self.ageInput) {
        long remainingCount = 3 - _ageInput.text.length;
        _ageReady = remainingCount >= 0 && remainingCount < 3;
    }
    
    [self checkAndSetSaveButton];
    
}

- (void)textViewDidChange:(UITextView *)textView {
    [self topicDescriptionChangedAction:nil];
}

- (void)topicDescriptionChangedAction:(id)sender {
    
    long remainingCount = 50 - _descriptionInput.text.length;
    if (remainingCount < 0) {
        self.descriptionCount.textColor = [UIColor redColor];
    } else  {
        self.descriptionCount.textColor = [UIColor whiteColor];
    }
    
    self.descriptionCount.text = [NSString stringWithFormat:@"(%ld)", remainingCount];
    _descriptionReady = remainingCount >= 0;
    [self checkAndSetSaveButton];
}


#pragma mark - UIButton Event Handler

- (IBAction)registerAction:(id)sender {
    
    [VJNYUtilities showProgressAlertViewToView:self.navigationController.view];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"id"];
    [dic setObject:self.usernameInput.text forKey:@"username"];
    [dic setObject:self.nameInput.text forKey:@"name"];
    [dic setObject:self.genderSegmentedControl.selectedSegmentIndex == 0 ? @"M" : @"F" forKey:@"gender"];
    [dic setObject:self.ageInput.text forKey:@"age"];
    [dic setObject:self.descriptionInput.text forKey:@"description"];
    
    [VJNYHTTPHelper sendJSONRequest:@"user/update" WithParameters:dic AndDelegate:self];
    
}
- (IBAction)finishDescriptionInputAction:(id)sender {
    
    if (_descriptionReady == false) {
        return;
    }
    
    [self.descriptionInput resignFirstResponder];
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    VJNYPOJOHttpResult* result = [VJNYPOJOHttpResult resultFromResponseString:responseString];
    if ([result.action isEqualToString:@"user/Update"]) {
        if (result.result == Success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [VJNYUtilities dismissProgressAlertViewFromView:self.navigationController.view];
                [VJNYUtilities showAlertWithNoTitle:@"Succeed!"];
                
                [VJNYPOJOUser sharedInstance].username = _usernameInput.text;
                [VJNYPOJOUser sharedInstance].name = _nameInput.text;
                [VJNYPOJOUser sharedInstance].age = [NSNumber numberWithInt:[_ageInput.text intValue]];
                [VJNYPOJOUser sharedInstance].gender = self.genderSegmentedControl.selectedSegmentIndex == 0 ? @"M" : @"F";
                [VJNYPOJOUser sharedInstance].description = _descriptionInput.text;
                
                VJDMUser* user = (VJDMUser*)[[VJDMModel sharedInstance] getCurrentUser];
                if (user == nil) {
                    user = (VJDMUser*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMUser"];
                }
                user.name = [VJNYPOJOUser sharedInstance].name;
                user.username = [VJNYPOJOUser sharedInstance].username;
                user.gender = (NSString*)[VJNYUtilities filterNSNullForObject:[VJNYPOJOUser sharedInstance].gender];
                user.age = (NSNumber*)[VJNYUtilities filterNSNullForObject:[VJNYPOJOUser sharedInstance].age];
                user.user_description = [VJNYPOJOUser sharedInstance].description;
                
                [[VJDMModel sharedInstance] saveChanges];
                
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        } else {
            [VJNYUtilities showAlertWithNoTitle:@"Update Failed!"];
        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [VJNYUtilities dismissProgressAlertViewFromView:self.navigationController.view];
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

@end