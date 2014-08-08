//
//  VJNYPromoChannelTableViewCell.m
//  vjourney
//
//  Created by alex on 14-5-23.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYPromoChannelTableViewCell.h"
#import "VJNYChannelPromoCoverCell.h"
#import "VJNYUtilities.h"
#import "VJNYPOJOChannel.h"
#import "VJNYDataCache.h"
#import "VJNYWhatsNewViewController.h"

@interface VJNYPromoChannelTableViewCell ()<VJNYDataCacheDelegate>

- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode;

@end

@implementation VJNYPromoChannelTableViewCell

@synthesize channelArray=_channelArray;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
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

#pragma mark - Custom Methods

- (void)setChannelArray:(NSMutableArray *)channelArray {
    _channelArray = channelArray;
}

#pragma mark - UICollectionView Delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    _pageControl.numberOfPages = [_channelArray count];
    _pageControl.currentPage = 0;
    return [_channelArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    VJNYChannelPromoCoverCell *cover = [collectionView dequeueReusableCellWithReuseIdentifier:[VJNYUtilities channelPromoCoverCellIdentifier] forIndexPath:indexPath];
	
    NSString* imageUrl = ((VJNYPOJOChannel*)[_channelArray objectAtIndex:indexPath.row]).coverUrl;
    
    [VJNYDataCache loadImage:cover.imageView WithUrl:imageUrl AndMode:1 AndIdentifier:indexPath AndDelegate:self];
    
    cover.titleLabel.text = ((VJNYPOJOChannel*)[_channelArray objectAtIndex:indexPath.row]).name;
	return cover;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[collectionView indexPathsForVisibleItems] count] > 0) {
        NSIndexPath* path = [collectionView indexPathsForVisibleItems][0];
        _pageControl.currentPage = path.row;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[VJNYWhatsNewViewController instance] promoCoverWasTapped:(int)indexPath.row];
}

#pragma mark - DataCache Delegate

- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode {
    if (mode == 1) {
        
        if ([[_collectionView indexPathsForVisibleItems] containsObject:identifier]) {
            VJNYChannelPromoCoverCell* cell = (VJNYChannelPromoCoverCell*)[_collectionView cellForItemAtIndexPath:identifier];
            cell.imageView.image = data;
        }
    }
}

@end
