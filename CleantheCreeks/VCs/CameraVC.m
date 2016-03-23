#import "CameraVC.h"

@implementation CameraVC
-(id) init
{
    self = [super initWithNibName:nil bundle:nil];
    self.photoTaken=NO;
    return self;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"cameraview will appear");
    
    if(!self.photoTaken)
    {
        [self takePhoto];
        self.photoTaken=YES;
    }
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
    self.cameraPicture=[info objectForKey:UIImagePickerControllerOriginalImage];
    self.photoURL=[[NSURL alloc]init];
    self.photoURL=[info valueForKey:UIImagePickerControllerReferenceURL];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self performSegueWithIdentifier:@"showPhotoDetails" sender:self];
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self dismissVC];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tabBarController setSelectedIndex:1];
    self.photoTaken=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) cameraRefresh:(BOOL)set
{
    self.photoTaken=set;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqual:@"showPhotoDetails"])
    {
        PhotoDetailsVC *photoDetailsVC=(PhotoDetailsVC*)segue.destinationViewController;
        photoDetailsVC.delegate=self;
        
        if(self.location!=nil)
        {
            photoDetailsVC.location=self.location;
            photoDetailsVC.foundDate=self.location.found_date;
            photoDetailsVC.cleanedDate=[[NSDate date] timeIntervalSince1970];
            photoDetailsVC.takenPhoto=self.dirtyPhoto;
            photoDetailsVC.cleanedPhoto=self.cameraPicture;
            photoDetailsVC.secondPhototaken = YES;
        }
        else
        {
            photoDetailsVC.location=nil;
            photoDetailsVC.takenPhoto=self.cameraPicture;
            photoDetailsVC.foundDate=[[NSDate date] timeIntervalSince1970];
            photoDetailsVC.secondPhototaken = NO;
        }
    }
}

@end
