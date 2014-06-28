//
//  MessageCell.h
//  15-QQ聊天布局
//
//  Created by Liu Feng on 13-12-3.
//  Copyright (c) 2013年 Liu Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VJDMMessageFrame;

@interface VJDMMessageCell : UITableViewCell

@property (nonatomic, strong) VJDMMessageFrame *messageFrame;
@property (nonatomic, strong) UIImage* iconImage;


@property (nonatomic, strong) UIImageView *iconView;

@end
