#import "CameraVC.h"

@implementation CameraVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self takePhoto];
	// Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSLog(@"Camera View Controller");
}

-(void) takePhoto
{
    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO)
    {
        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    }
    
    picker.delegate=self;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"perform Segue");
    self.cameraPicture=[[UIImage alloc]init];
    self.cameraPicture=[info objectForKey:UIImagePickerControllerOriginalImage];
    self.photoURL=[[NSURL alloc]init];
    self.photoURL=[info valueForKey:UIImagePickerControllerReferenceURL];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self performSegueWithIdentifier:@"showPhotoDetails" sender:self];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqual:@"showPhotoDetails"])
    {
        PhotoDetailsVC *photoDetailsVC=(PhotoDetailsVC*)segue.destinationViewController;
        photoDetailsVC.firstPicture=self.cameraPicture;
        photoDetailsVC.firstPath=self.photoURL;

        photoDetailsVC.foundDate=[NSDate date];
    }
}

@end
