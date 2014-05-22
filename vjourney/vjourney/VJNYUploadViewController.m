//
//  VJNYUploadViewController.m
//  vjourney
//
//  Created by alex on 14-5-9.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYUploadViewController.h"
#import "VJNYSelectVideoViewController.h"

@interface VJNYUploadViewController ()

@end

@implementation VJNYUploadViewController

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
    if ([segue.identifier isEqualToString:@"getVideoList"]) {
        VJNYSelectVideoViewController* controller = [segue destinationViewController];
        controller.parent = self;
    }
}


#pragma mark - Utilities

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset: urlAsset presetName:AVAssetExportPresetLowQuality];
    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeQuickTimeMovie;
    [session exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(session);
         
     }];
}


#pragma mark - Event Handler

-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id )delegate {
    // 1 - Validations
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    // 2 - Get image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    mediaUI.videoQuality = UIImagePickerControllerQualityTypeHigh;
    mediaUI.delegate = delegate;
    // 3 - Display image picker
    // [controller presentModalViewController:mediaUI animated:YES];
    [self presentViewController:mediaUI animated:YES completion:^{
        
    }];
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    // 1 - Get media type
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
//    // 2 - Dismiss image picker
//    [self dismissViewControllerAnimated:NO completion:nil];
//    // Handle a movie capture
//    if (CFStringCompare ((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
//        // 3 - Play the video
//        MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc]
//                                                 initWithContentURL:[info objectForKey:UIImagePickerControllerMediaURL]];
//        [self presentMoviePlayerViewControllerAnimated:theMovie];
//        // 4 - Register for the playback finished notification
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
//                                                     name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
//    }
    
    // 1 - Get media URL
    NSURL* videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NSURL" message:[videoUrl absoluteString] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"Yes"];
    [alert show];
    
    // 2 - Dismiss image picker
    [self dismissViewControllerAnimated:NO completion:nil];
}

// When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    [self dismissMoviePlayerViewControllerAnimated];
    MPMoviePlayerController* theMovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}

- (IBAction)VideoUploadAction:(id)sender {
    if (videoUrlToUpload == NULL) {
        return;
    } else {
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:@"upload"]];
        
        NSLog(@"%@",[videoUrlToUpload absoluteString]);
        
        NSString* videoName = @"test";
        
        NSURL *tmpURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:videoName] stringByAppendingString:@".mov"]];
        NSLog(@"tmpURL local is %@",tmpURL);
        
        [self convertVideoToLowQuailtyWithInputURL:videoUrlToUpload outputURL:tmpURL handler:^(AVAssetExportSession *session)
         {
             if (session.status == AVAssetExportSessionStatusCompleted)
             {
                 // Success
                 NSData* filedata = [NSData dataWithContentsOfURL:tmpURL];
                 
                 [request addData:filedata withFileName:@"test.mov" andContentType:@"video/quicktime" forKey:@"file"];
                 //[request setData:filedata forKey:@"file"];
                 //[request setPostValue:@"test.mov" forKey:@"fileName"];
                 
                 NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                 [dic setObject:@"alex" forKey:@"username"];
                 [dic setObject:@"123" forKey:@"token"];
                 NSError *error = nil;
                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                                    options:NSJSONWritingPrettyPrinted
                                                                      error:&error];
                 NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                              encoding:NSUTF8StringEncoding];
                 NSLog(@"%@",jsonString);
                 
                 
                 [request addPostValue:jsonString forKey:@"description"];
                 
                 [request setDelegate:self];
                 [request startAsynchronous];
             }
             else
             {
                 // Error Handing
                 
             }
         }];
        
        /*ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:videoUrlToUpload
                 resultBlock:^(ALAsset *asset)
         {
             ALAssetRepresentation *representation = [asset defaultRepresentation];
             
             Byte *buffer = (Byte*)malloc((unsigned long)representation.size);
             NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:(unsigned long)representation.size error:nil];
             NSData *filedata = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
             
             [request addData:filedata withFileName:@"test.mov" andContentType:@"video/quicktime" forKey:@"file"];
             //[request setData:filedata forKey:@"file"];
             //[request setPostValue:@"test.mov" forKey:@"fileName"];
             
             NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
             [dic setObject:@"alex" forKey:@"username"];
             [dic setObject:@"123" forKey:@"token"];
             NSError *error = nil;
             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                                options:NSJSONWritingPrettyPrinted
                                                                  error:&error];
             NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                          encoding:NSUTF8StringEncoding];
             NSLog(@"%@",jsonString);
             
             
             [request addPostValue:jsonString forKey:@"description"];
             
             [request setDelegate:self];
             [request startAsynchronous];
             
         }
         failureBlock:^(NSError *error)
         {
             NSLog(@"couldn't get asset: %@", error);
         }
         ];*/
    }
}

- (IBAction)VideoPlayAction:(id)sender {
    
    [self startMediaPlayerFromVideoURL:[VJNYHTTPHelper connectionUrlByAppendingRequest:@"test.mov"]];
    
}

-(void)startMediaPlayerFromVideoURL:(NSURL*)url {
    // 3 - Play the video
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:theMovie];
    // 4 - Register for the playback finished notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}
-(void)finishSelectingVideo:(NSURL*)url {
    videoUrlToUpload = url;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NSURL" message:[videoUrlToUpload absoluteString] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"Yes"];
    [alert show];
}

#pragma mark - HTTP Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 当以文本形式读取返回内容时用这个方法
    NSString *responseString = [request responseString];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HTTP Finished!" message:responseString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"Yes"];
    [alert show];
    // 当以二进制形式读取返回内容时用这个方法
    //NSData *responseData = [request responseData];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
}
@end
