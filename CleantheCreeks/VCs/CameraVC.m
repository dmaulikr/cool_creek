#import "CameraVC.h"

@implementation CameraVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if(!self.cameraPicture)
        [self takePhoto];
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
    [self.tabBarController setSelectedIndex:1];
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
