//
//  VJNYVideoTableViewCell.h
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VJNYHTTPHelper.h"

@interface VJNYVideoTableViewCell : UITableViewCell
@property(nonatomic,strong) UIWebView* webView;
-(void)setURL:(NSString*)url;
@end
