#import "LocationVC.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSS3/AWSS3.h>
#import "Location.h"
#import "locationCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#include "AppDelegate.h"

@implementation LocationVC
- (void)viewWillAppear:(BOOL)animated
{
    [self.locationArray removeAllObjects];
    [self.imageArray removeAllObjects];
    [_locationManager requestWhenInUseAuthorization];
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

    
}
- (void)viewDidLoad
{
    CGFloat tableBorderLeft = 20;
    CGFloat tableBorderRight = 20;
    
    CGRect tableRect=self.locationTable.frame;
    tableRect.origin.x+=tableBorderLeft;
    tableRect.size.width -= tableBorderLeft + tableBorderRight; // reduce the width of the table
    
    //self.locationTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self.locationTable setFrame:tableRect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.locationArray count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    locationCell * cell=nil;
    cell = (locationCell*)[tableView dequeueReusableCellWithIdentifier:@"locationCell"];
    if([self.locationArray count]>0)
    {
        Location * location=[self.locationArray objectAtIndex:indexPath.row];
        [cell.locationName setText:location.location_name];
        
        CLLocation*exitingLocation=[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
        CLLocationDistance distance=[exitingLocation distanceFromLocation:self.currentLocation];
        distance=distance/1000.0;
        NSString*distanceText=[[NSString alloc]initWithFormat:@"%.02fKM",distance];
        [cell.distance setText:distanceText];
        
        // Construct the download request.
        if([self.imageArray objectForKey:location.location_id])
            cell.image.image=(UIImage*)[self.imageArray objectForKey:location.location_id];
    }
    if(!cell)
    {
        cell=(locationCell*)[[UITableViewCell alloc]init];
    }
    return cell;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    self.locationArray = [[NSMutableArray alloc]init];
    self.imageArray = [[NSMutableDictionary alloc]init];
    self.currentLocation=newLocation;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[dynamoDBObjectMapper scan:[Location class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (Location *location in paginatedOutput.items) {
                 CLLocation*exitingLocation=[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
                 CLLocationDistance distance=[exitingLocation distanceFromLocation:self.currentLocation];
                 distance=distance/1000.0;
                
                 
                 NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded-myImage.jpg"];
                 NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                 if(distance<100.0)
                 {
                     [self.locationArray addObject:location];
                 // Construct the download request.
                     AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                     
                     downloadRequest.bucket = @"cleanthecreeks";
                     downloadRequest.key = location.location_id;
                     downloadRequest.downloadingFileURL = downloadingFileURL;
                     [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
                         if (task.error){
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
                        AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                             self.imageArray[location.location_id]=[UIImage imageWithContentsOfFile:downloadingFilePath];
                             
                         }
                         return nil;
                     }];
                 }
                 
             }
             [self.locationTable reloadData];
             
         }
         return nil;
     }];
   
    [self.locationManager stopUpdatingLocation];
    
}

@end
