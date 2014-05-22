//
//  VJNYVideoTableViewCell.m
//  vjourney
//
//  Created by alex on 14-5-17.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoTableViewCell.h"

@implementation VJNYVideoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setURL:(NSString*)url {
    
    int w = self.frame.size.width;
    int h = self.frame.size.height;
    w=290;
    h=213;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 0, w, h)];
    [_webView setOpaque:YES];
    
    [_webView loadHTMLString:[VJNYHTTPHelper mediaPlayCodeWithURL:url andWidth:w andHeight:h] baseURL:nil];
    _webView.allowsInlineMediaPlayback = YES;
    _webView.scrollView.scrollEnabled = NO;
    _webView.scrollView.bounces = NO;
    
    //_webView.transform = CGAffineTransformMakeRotation(3.14/2);
    
    [self addSubview:_webView];
    
    //webView.mediaPlaybackRequiresUserAction = NO;
    
    //webView.transform = CGAffineTransformMakeRotation(3.14/2);
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
