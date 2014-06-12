//
//  VJNYVideoCaptureViewController.m
//  vjourney
//
//  Created by alex on 14-6-12.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYVideoCaptureViewController.h"
#import "VJNYUtilities.h"
#import "VJNYVideoCutViewController.h"

@interface VJNYVideoCaptureViewController () {
    UIImagePickerController* _videoPickerController;
}

@end

@implementation VJNYVideoCaptureViewController

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
    _videoPickerController = [[UIImagePickerController alloc] init];
    _videoPickerController.delegate = self;
    _videoPickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    _videoPickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [_videoPickerController setMediaTypes:[NSArray arrayWithObjects:@"public.movie", nil]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:[VJNYUtilities segueVideoCutPage]]) {
        VJNYVideoCutViewController* controller = [segue destinationViewController];
        controller.selectedVideoURL = (NSURL*)sender;
    }
    
}

#pragma mark - Button Event Handler

- (IBAction)videoSelectAction:(id)sender {
    [self presentViewController:_videoPickerController animated:YES completion:nil];
}

#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // this is the file system url of the media
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL* videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    
    [self performSegueWithIdentifier:[VJNYUtilities segueVideoCutPage] sender:videoUrl];
    NSLog(@"%@",[videoUrl absoluteString]);
    // TODO: read in data at videoUrl and write upload it to your server
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"ImagePicker Cancel!");
}
@end
