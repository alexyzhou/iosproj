//
//  VJNYChatViewController.m
//  vjourney
//
//  Created by alex on 14-6-27.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYChatViewController.h"
#import "VJDMMessageFrame.h"
#import "VJDMMessage.h"
#import "VJDMMessageCell.h"
#import "VJNYUtilities.h"
#import "VJDMModel.h"
#import "VJDMUserAvatar.h"
#import "VJDMThread.h"
#import "VJNYPOJOUser.h"
#import "VJNYHTTPHelper.h"
#import "VJNYPOJOHttpResult.h"

@interface VJNYChatViewController () {
    NSMutableArray  *_allMessagesFrame;
}

@end

@implementation VJNYChatViewController

@synthesize target_avatar=_target_avatar;
@synthesize target_id=_target_id;
@synthesize target_name=_target_name;

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
    
    NSArray* arrayToTest = [[VJDMModel sharedInstance] getEntityList:@"VJDMMessage"];
    for (VJDMMessage * msg in arrayToTest) {
        NSLog(@"%d",[msg.target_id intValue]);
    }
    
    // Do any additional setup after loading the view.
    self.messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageTableView.allowsSelection = NO;
    
    self.messageTableView.contentInset = UIEdgeInsetsMake(65.0, 0, 0, 0);
    self.messageTableView.scrollIndicatorInsets = UIEdgeInsetsMake(65.0, 0, 0, 0);
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //设置textField输入起始位置
    self.inputTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.inputTextField.leftViewMode = UITextFieldViewModeAlways;
    
    self.inputTextField.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:_target_name];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setTitle:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    NSArray* array = [[VJDMModel sharedInstance] getMessageListByTargetID:_target_id];
    
    _allMessagesFrame = [NSMutableArray array];
    NSString *previousTime = nil;
    
    for (VJDMMessage* message in array) {
        VJDMMessageFrame *messageFrame = [[VJDMMessageFrame alloc] init];
        messageFrame.showTime = ![previousTime isEqualToString:[message getDateString]];
        messageFrame.message = message;
        previousTime = [message getDateString];
        [_allMessagesFrame addObject:messageFrame];
    }
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
#pragma mark - 文本框代理方法
#pragma mark 点击textField键盘的回车按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    return [self insertNewMessage];
}

- (BOOL)insertNewMessage {
    
    if (self.inputTextField.text == nil || [self.inputTextField.text isEqual:@""]) {
        return NO;
    }
    [self.inputTextField resignFirstResponder];
    
    // Is this a new thread?
    VJDMThread* thread = (VJDMThread*)[[VJDMModel sharedInstance] getThreadByTargetID:_target_id];
    if (thread == nil) {
        thread = (VJDMThread*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMThread"];
        thread.target_id = _target_id;
        thread.target_name = _target_name;
        
    }
    thread.last_message = self.inputTextField.text;
    thread.last_time = [NSDate date];
    [[VJDMModel sharedInstance] saveChanges];
    
    // 1、增加数据源
    NSString *content = self.inputTextField.text;
    [self addMessageWithContent:content time:[NSDate date]];
    // 2、刷新表格
    [self.messageTableView reloadData];
    // 3、滚动至当前行
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_allMessagesFrame.count - 1 inSection:0];
    [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    // 4、清空文本框内容
    self.inputTextField.text = nil;
    return YES;
    
}

#pragma mark 给数据源增加内容
- (void)addMessageWithContent:(NSString *)content time:(NSDate *)time{
    
    VJDMMessageFrame *mf = [[VJDMMessageFrame alloc] init];
    VJDMMessage *msg=(VJDMMessage*)[[VJDMModel sharedInstance] getNewEntity:@"VJDMMessage"];
    msg.content = content;
    msg.time = time;
    msg.type = MessageTypeMe;
    msg.target_id = _target_id;
    mf.message = msg;
    
    [[VJDMModel sharedInstance] saveChanges];
    
    [_allMessagesFrame addObject:mf];
    
    // Network stuff
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:[[VJNYPOJOUser sharedInstance].uid stringValue] forKey:@"userId"];
    [dic setObject:[_target_id stringValue] forKey:@"targetUserId"];
    [dic setObject:content forKey:@"content"];
    [dic setObject:[NSString stringWithFormat:@"%ld", (long)time.timeIntervalSince1970] forKey:@"time"];
    [[VJNYPOJOUser sharedInstance] insertIdentityToDirectory:dic];
    
    [VJNYHTTPHelper sendJSONRequest:@"notif/chat/send" WithParameters:dic AndDelegate:self];
}

#pragma mark - tableView数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allMessagesFrame.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VJDMMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:[VJNYUtilities chatMessageCellIdentifier]];
    
    if (cell == nil) {
        cell = [[VJDMMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[VJNYUtilities chatMessageCellIdentifier]];
    }
    
    // 设置数据
    cell.messageFrame = _allMessagesFrame[indexPath.row];
    VJDMMessage* message = ((VJDMMessageFrame*)_allMessagesFrame[indexPath.row]).message;
    if (message.type == MessageTypeOther) {
        
        cell.iconImage = _target_avatar;
        cell.iconView.image = _target_avatar;
        
    } else {
        [VJNYDataCache loadImage:cell.iconView WithUrl:[VJNYPOJOUser sharedInstance].avatarUrl AndMode:0 AndIdentifier:indexPath AndDelegate:self];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [_allMessagesFrame[indexPath.row] cellHeight];
}

#pragma mark - 代理方法

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void) dataRequestFinished:(UIImage *)data WithIdentifier:(id)identifier AndMode:(int)mode {
    if (mode == 0) {
        NSIndexPath* path = identifier;
        if ([[self.messageTableView indexPathsForVisibleRows] containsObject:path]) {
            VJDMMessageCell* cell = (VJDMMessageCell*)[self.messageTableView cellForRowAtIndexPath:path];
            cell.iconView.image = data;
        }
    }
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
    [VJNYUtilities showAlertWithNoTitle:error.localizedDescription];
}

#pragma mark - Custom Button Events

- (IBAction)sendButtonAction:(id)sender {
    
    [self insertNewMessage];
    
}
@end
