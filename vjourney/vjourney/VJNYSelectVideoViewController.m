//
//  VJNYSelectVideoViewController.m
//  vjourney
//
//  Created by alex on 14-5-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYSelectVideoViewController.h"

@interface VJNYSelectVideoViewController ()

@end

@implementation VJNYSelectVideoViewController

@synthesize listData;
@synthesize videoListView;
@synthesize parent;

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
    listData = [[NSMutableArray alloc] init];
    [self generateVideoList:listData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Init

-(void)generateVideoList:(NSMutableArray*)allVideos {
    //NSMutableArray* allVideos = [[NSMutableArray alloc] init];
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if (group)
         {
             [group setAssetsFilter:[ALAssetsFilter allVideos]];
             [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
              {
                  if (asset)
                  {
                      NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                      ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                      NSString *uti = [defaultRepresentation UTI];
                      NSURL  *videoUrl = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
                      NSDate *videoDate = [asset valueForProperty:ALAssetPropertyDate];
                      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                      [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                      NSString *destDateString = [dateFormatter stringFromDate:videoDate];
                      

                      NSString *title = [NSString stringWithFormat:@"Date: %@",destDateString];
                      UIImage *image = [self imageFromVideoURL:videoUrl];
                      [dic setValue:image forKey:@"image"];
                      [dic setValue:title forKey:@"name"];
                      [dic setValue:videoUrl forKey:@"url"];
                      [allVideos addObject:dic];
                      [videoListView reloadData];
                  }
              }];
         } else {
             
         }
     }
     failureBlock:^(NSError *error)
     {
         NSLog(@"error enumerating AssetLibrary groups %@\n", error);
     }];
    
}

- (UIImage *)imageFromVideoURL:(NSURL*)videoURL
{
    // result
    UIImage *image = nil;
    
    // AVAssetImageGenerator
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    // calc midpoint time of video
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    
    // get the image from
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    
    if (halfWayImage != NULL)
    {
        // CGImage to UIImage
        image = [[UIImage alloc] initWithCGImage:halfWayImage];
        CGImageRelease(halfWayImage);
    }
    return image;
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

#pragma mark - TableView Related

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count is %d",[self.listData count]);
    return [self.listData count];
}

static NSString *SimpleTableIdentifier=@"SimpleTableIdentifier";
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if(cell==nil){//如果行元素为空的话 则新建一行
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
    }
    //取得当前行
    NSUInteger row=[indexPath row];
    NSMutableDictionary* dic = [listData objectAtIndex:row];
    cell.textLabel.text= [dic objectForKey:@"name"]; //设置每一行要显示的值
    cell.imageView.image = [dic objectForKey:@"image"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary* dic = [self.listData objectAtIndex:[indexPath row]];
    [self dismissViewControllerAnimated:NO completion:^{
        [parent finishSelectingVideo:[dic objectForKey:@"url"]];
    }];
}


@end
