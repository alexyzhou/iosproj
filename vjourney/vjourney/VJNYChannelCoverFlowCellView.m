//
//  VJNYChannelCoverFlowCellView.m
//  vjourney
//
//  Created by alex on 14-5-23.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYChannelCoverFlowCellView.h"

@interface VJNYChannelCoverFlowCellView () {
    UIActivityIndicatorView* _loadingIndicator;
}

@end

@implementation VJNYChannelCoverFlowCellView
@synthesize baseline=_baseline;
@synthesize title=_title;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        imageView.alpha = 0.0f;
        //[imageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        //[imageView.layer setBorderWidth: 1.0f];
        
        CGFloat titleWidth = 210.0f;
        CGFloat titleHeight = 60.0f;
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width-titleWidth)/2, (frame.size.height-titleHeight)/2, titleWidth, titleHeight)];
        _title.font = [UIFont boldSystemFontOfSize:22.0f];
        _title.textColor = [UIColor whiteColor];
        _title.layer.shadowOffset = CGSizeMake(2, 2);
        _title.textAlignment = NSTextAlignmentCenter;
        _title.backgroundColor = [UIColor clearColor];
        
        //imageView.layer.shadowOffset = CGSizeMake(2, 2);
        //imageView.layer.shadowRadius = 2;
        //imageView.layer.shadowOpacity = 0.6;
        
        [self addSubview:imageView];
        [self addSubview:_title];
        
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((frame.size.width-50)/2, (frame.size.height-50)/2, 50, 50)];
        [_loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_loadingIndicator];
        
        [self.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [self.layer setBorderWidth:1.0f];
    }
    return self;
}

- (void) setBaseline:(float)f{
	baseline = f;
	[self setNeedsDisplay];
}

- (void) setImage:(UIImage *)img{
    
    if (img == nil) {
        imageView.alpha = 0.0f;
        _loadingIndicator.alpha = 1.0f;
        [_loadingIndicator startAnimating];
        [self bringSubviewToFront:_loadingIndicator];
    } else {
        UIImage *image = img;
        
        _loadingIndicator.alpha = 0.0f;
        [_loadingIndicator stopAnimating];
        //[_loadingIndicator removeFromSuperview];
        
        /*float w = image.size.width;
         float h = image.size.height;
         float factor = self.bounds.size.width / (h>w?h:w);
         h = factor * h;
         w = factor * w;
         float y = baseline - h > 0 ? baseline - h : 0;*/
        
        //imageView.frame = CGRectMake(0, y, w, h);
        imageView.image = image;
        
        [UIView animateWithDuration:0.1 animations:^{
            imageView.alpha = 1.0f;
        }];
        
    }
	
	
}
- (UIImage*) image{
	return imageView.image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
