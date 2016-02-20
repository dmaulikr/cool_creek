//
//  PhotoDetails.m
//  CleantheCreeks
//
//  Created by Kimura Isoroku on 1/31/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "PhotoDetailsVC.h"
#import "DetailCell1.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSS3/AWSS3.h>
@implementation PhotoDetailsVC
bool secondPhototaken=false;
-(void)viewDidLoad
{
    [super viewDidLoad];
    _locationManager=[[CLLocationManager alloc] init];
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
        [_locationManager requestWhenInUseAuthorization];
    
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter=500;
    self.locationManager=_locationManager;
    
    if([CLLocationManager locationServicesEnabled]){
        
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.nextButton setEnabled:NO];
    
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    self.currentLocation=newLocation;
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    [ceo reverseGeocodeLocation:self.currentLocation
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  NSLog(@"placemark %@",placemark);
                  //String to hold address
                  NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                  NSLog(@"addressDictionary %@", placemark.addressDictionary);
                  
                  NSLog(@"region %@",placemark.region);
                  NSLog(@"country %@",placemark.country);  // Give Country Name
                  NSLog(@"locality %@",placemark.locality); // Extract the city name
                  NSLog(@"name %@",placemark.name);
                  NSLog(@"ocean %@",placemark.ocean);
                  NSLog(@"postalcode %@",placemark.postalCode);
                  NSLog(@"sublocality%@",placemark.subLocality);
                  
                  NSLog(@"location %@",placemark.location);
                  //Print the location to console
                  NSLog(@"I am currently at %@",locatedAt);
                  
                  self.locationName1=placemark.locality;
                  self.locationName2=locatedAt;
                  self.countryName=placemark.country;
                  [self.nextButton setEnabled:YES];
                  [self.detailTable reloadData];
              }
     ];
    [_locationManager stopUpdatingLocation];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return NO;
}
-(void) SetSecondPhoto:(bool)set
{
    secondPhototaken=set;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height=0;
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
            height=5;
        else if(indexPath.row==1)
            height=self.view.frame.size.height*0.3;
    }
    else if(indexPath.section==1)
    {
        if(indexPath.row==0)
            height=5;
        else if(indexPath.row==3)
        {
            if(secondPhototaken)
                height=self.view.frame.size.height*0.13;
            else
                height=0;
        }
        else
            height=self.view.frame.size.height*0.13;
    }
    else if(indexPath.section==2)
    {
        if(indexPath.row==0)
            height=5;
        else
            height=self.view.frame.size.height*0.4;
    }
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count=0;
    if(section==0)
        count=2;
    else if(section==1)
        count=4;
    else if(section==2)
        count=2;
    return count;
}
-(void) setSecondPhoto:(BOOL)set
{
    secondPhototaken=set;
    [self.detailTable reloadData];
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell=[[UITableViewCell alloc]init];

    if(indexPath.section==0)
    {
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"bar1"];
        else if(indexPath.row==1)
        {
            cell = (photoViewCell*)[tableView dequeueReusableCellWithIdentifier:@"photoCell"];
            [((photoViewCell*)cell).firstPhoto setImage:self.firstPicture];
            ((photoViewCell*)cell).delegate=self;
        }
    }
    else if(indexPath.section==1)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *user_name = [defaults objectForKey:@"user_name"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy"];
        
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"bar2"];
        else if(indexPath.row==1)
        {
            cell = (DetailCell1*)[tableView dequeueReusableCellWithIdentifier:@"detailCell1"];
            
            [((DetailCell1*)cell).locationName1 setText:self.locationName1];
            [((DetailCell1*)cell).locationName2 setText:self.locationName2];
            
        }
        else if(indexPath.row==2)
        {
            cell = (DetailCell1*)[tableView dequeueReusableCellWithIdentifier:@"detailCell2"];
            [((DetailCell1*)cell).finderName setText:user_name];
            [((DetailCell1*)cell).foundDate setText:[dateFormatter stringFromDate:self.foundDate]];
            
        }
        else if(indexPath.row==3)
        {
            cell = (DetailCell1*)[tableView dequeueReusableCellWithIdentifier:@"detailCell3"];
            [((DetailCell1*)cell).cleanerName setText:user_name];
            [((DetailCell1*)cell).cleanedDate setText:[dateFormatter stringFromDate:[NSDate date]]];
        }

    }
    else if(indexPath.section==2)
    {
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"bar3"];
        else if(indexPath.row==1)
            cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell4"];
    }
    if(!cell){
        cell = nil;
        
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title;
    if(section==0)
        title=@"Details";
    else if(section==1)
        title=@"Timeline";
    else if(section==2)
        title=@"Comments";
    return title;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *stringToSave = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.commentText=stringToSave;
    
    return YES;
}
- (IBAction)nextPage:(id)sender {
    if(secondPhototaken)
    {
        [self storeData:false];
        [self performSegueWithIdentifier:@"cleanedFBPost" sender:self];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Whoa Whoa Whoa!" message:@"What is the deal? Do you want to tag this spot as a dirty location or can we wrap this one up." preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Tag as dirty" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self storeData:true];
            [self performSegueWithIdentifier:@"foundFBPost" sender:self];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Wrap this up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self storeData:false];
        }]];
        
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:alertController animated:YES completion:nil];
        });

    }

}

- (IBAction)prevPage:(id)sender {
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
-(void)storeData:(BOOL)isDirty
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_name = [defaults objectForKey:@"user_name"];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    Location *location = [Location new];
    NSString *location_id = [NSString stringWithFormat:@"%.2f,%.2f",
                         self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    location.location_id=location_id;
    location.location_name = self.locationName1;
    location.state=self.locationName2;
    location.comments=self.commentText;
    location.country=self.countryName;
    location.found_by=user_name;
    location.founder_id=user_id;
    location.cleaner_id=user_id;
    location.cleaner_name=user_name;
    location.found_date=[dateFormatter stringFromDate:self.foundDate];
    location.cleaned_date=[dateFormatter stringFromDate:self.cleanedDate];
    location.latitude=self.currentLocation.coordinate.latitude;
    location.longitude=self.currentLocation.coordinate.longitude;
    if(isDirty)
        location.isDirty=@"true";
    else
        location.isDirty=@"false";
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper save:location]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             //Do something with the result.
         }
         return nil;
     }];
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", location_id]];
    [UIImagePNGRepresentation(self.firstPicture) writeToFile:filePath atomically:YES];
    
    NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
    
    //upload the image
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = fileUrl;
    uploadRequest.bucket = @"cleanthecreeks";
    uploadRequest.key = [NSString stringWithFormat:@"%.2f,%.2f",
                         self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    uploadRequest.contentType = @"image/png";
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                   }
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                               // The file uploaded successfully.
                                                           }
                                                           return nil;
                                                       }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"perform Segue");
    UIImage * photo=[[UIImage alloc]init];
    photo=[info objectForKey:UIImagePickerControllerOriginalImage];
    if(secondPhototaken)
    {
        secondPhototaken=false;
    }
    else
    {
        self.firstPicture=photo;
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.detailTable reloadData];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    if(secondPhototaken)
    {
        
    }
    else
    {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
