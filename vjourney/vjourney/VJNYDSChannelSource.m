//
//  VJNYDSChannelSource.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYDSChannelSource.h"

@implementation VJNYDSChannelSource

@synthesize data=_data;

- (VJNYDSChannelSource*)initWithArrayOfChannels:(NSMutableArray*)arrData
{
    self = [super init];
    if (self) {
        _data = arrData;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%d",[_data count]);
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ChannelCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Updated @ 2012-08-07
    // Sample Code without "cell check" message:
    // *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'UITableView dataSource must return a cell from tableView:cellForRowAtIndexPath:'
    //
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.backgroundColor = [UIColor redColor];
    }
    
    // Set up the cell...
    cell.textLabel.text = ((VJNYPOJOChannel*)[_data objectAtIndex:indexPath.row]).name;
    return cell;
}

@end
