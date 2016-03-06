//
//  PhotoDetails.m
//  CleantheCreeks
//
//  Created by Kimura Isoroku on 1/31/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "PhotoDetailsVC.h"
#import "DetailCell.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSS3/AWSS3.h>
@implementation PhotoDetailsVC

bool secondPhototaken=false;

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:YES];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.currentLocation=newLocation;
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    [ceo reverseGeocodeLocation:self.currentLocation
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  //NSLog(@"placemark %@",placemark);
                  //String to hold address
                  NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                  NSLog(@"addressDictionary %@", placemark.addressDictionary);
                  
                  /*NSLog(@"region %@",placemark.region);
                  NSLog(@"country %@",placemark.country);  // Give Country Name
                  NSLog(@"locality %@",placemark.locality); // Extract the city name
                  NSLog(@"name %@",placemark.name);
                  NSLog(@"ocean %@",placemark.ocean);
                  NSLog(@"postalcode %@",placemark.postalCode);
                  NSLog(@"sublocality%@",placemark.subLocality);
                  
                  NSLog(@"location %@",placemark.location);
                  //Print the location to console
                  NSLog(@"I am currently at %@",locatedAt);*/
                  self.locationName1=[placemark.addressDictionary valueForKey:@"Name"];
                  self.locationName2=[placemark.addressDictionary valueForKey:@"State"];
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

-(void) setSecondPhoto:(BOOL)set photo:(UIImage*)photo
{
    secondPhototaken = set;
    self.cleanedPhoto = [[UIImage alloc]init];
    self.cleanedPhoto = photo;
    self.cleanedDate = [NSDate date];
    [self.detailTable reloadData];
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

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell=[[UITableViewCell alloc]init];

    if(indexPath.section==0)
    {
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"FirstBar"];
        else if(indexPath.row==1)
        {
            cell = (PhotoViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
            [((PhotoViewCell*)cell).firstPhoto setImage:self.dirtyPhoto];
            ((PhotoViewCell*)cell).delegate=self;
        }
    }
    else if(indexPath.section==1)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *user_name = [defaults objectForKey:@"user_name"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy"];
        
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"SecondBar"];
        else if(indexPath.row==1)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"FirstDetailCell"];
            
            [((DetailCell*)cell).locationName1 setText:self.locationName1];
            [((DetailCell*)cell).locationName2 setText:self.locationName2];
            
        }
        else if(indexPath.row==2)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"SecondDetailCell"];
            [((DetailCell*)cell).finderName setText:user_name];
            [((DetailCell*)cell).foundDate setText:[dateFormatter stringFromDate:self.foundDate]];
            
        }
        else if(indexPath.row==3)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"ThirdDetailCell"];
            [((DetailCell*)cell).cleanerName setText:user_name];
            [((DetailCell*)cell).cleanedDate setText:[dateFormatter stringFromDate:self.cleanedDate]];
        }

    }
    else if(indexPath.section==2)
    {
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"ThirdBar"];
        else if(indexPath.row==1)
            cell = [tableView dequeueReusableCellWithIdentifier:@"FourthDetailCell"];
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
    if(section == 0)
        title = @"Details";
    else if(section == 1)
        title = @"Timeline";
    else if(section == 2)
        title = @"Comments";
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
    NSString *location_id = [NSString stringWithFormat:@"%f,%f",
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
    location.found_date=[self.foundDate timeIntervalSince1970];
    location.cleaned_date=[self.cleanedDate timeIntervalSince1970];
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
    NSString *dirtyPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@a.png", location_id]];
    NSString *cleanPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@b.png", location_id]];
    UIImage *cimage = [PhotoDetailsVC scaleImage:self.dirtyPhoto toSize:CGSizeMake(320.0,320.0)];
    [UIImagePNGRepresentation(cimage) writeToFile:dirtyPath atomically:YES];
    NSURL* dirtyURL = [NSURL fileURLWithPath:dirtyPath];
    
    UIImage* cimage2 = [PhotoDetailsVC scaleImage:self.cleanedPhoto toSize:CGSizeMake(320.0,320.0)];
    [UIImagePNGRepresentation(cimage2) writeToFile:cleanPath atomically:YES];
    NSURL* cleanURL = [NSURL fileURLWithPath:cleanPath];

    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = dirtyURL;
    uploadRequest.bucket = @"cleanthecreeks";
    uploadRequest.contentType = @"image/png";
    uploadRequest.key = [NSString stringWithFormat:@"%f,%fa",
                         self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
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
        
        if (task.result)
        {
            NSLog(@"First photo uploaded");
        }
        return nil;
    }];
    if(secondPhototaken)
    {
        AWSS3TransferManagerUploadRequest *seconduploadRequest = [AWSS3TransferManagerUploadRequest new];
        seconduploadRequest.body = dirtyURL;
        seconduploadRequest.bucket = @"cleanthecreeks";
        seconduploadRequest.contentType = @"image/png";
        seconduploadRequest.body = cleanURL;
        seconduploadRequest.key = [NSString stringWithFormat:@"%f,%fb",
                             self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
        [[transferManager upload:seconduploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
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
                NSLog(@"Second photo uploaded");
            }
            return nil;
        }];
    }
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
        self.dirtyPhoto=photo;
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.detailTable reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    if(secondPhototaken)
    {
        secondPhototaken=false;
        
    }
    else
    {
        [self.tabBarController setSelectedIndex:1];
        [self.tabBarController.tabBar setHidden:NO];
        //[self.navigationController popViewControllerAnimated:YES];
    }
}

+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end