#import "LocationVC.h"
#import "AppDelegate.h"

#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AWSS3/AWSS3.h>

#import "Location.h"
#import "locationCell.h"
#import "LocationOverlayView.h"
#import "LocationAnnotation.h"
@implementation LocationVC

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
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
    }else{
        
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationArray = [[NSMutableArray alloc]init];
    self.imageArray = [[NSMutableDictionary alloc]init];
    self.mapView.delegate=self;
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableViewDelegate Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.locationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
        NSString * key=[location.location_id stringByAppendingString:@"a"];
        if(self.mainDelegate.locationData[location.location_id])
            cell.image.image=(UIImage*)[self.imageArray objectForKey:location.location_id];
    }
    
    if(!cell){
        cell=(locationCell*)[[UITableViewCell alloc]init];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma CLLocationDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.locationArray removeAllObjects];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.2;
    span.longitudeDelta = 0.2;
    CLLocationCoordinate2D cLocation;
    cLocation.latitude = newLocation.coordinate.latitude;
    cLocation.longitude = newLocation.coordinate.longitude;
    region.span = span;
    region.center = cLocation;
    [self.mapView setRegion:region animated:YES];
    
    self.currentLocation=newLocation;
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    
    [ceo reverseGeocodeLocation:self.currentLocation
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  //String to hold address
                  NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                  [self.btnCountry setTitle:placemark.country forState:UIControlStateNormal];
                  [self.btnState setTitle:locatedAt forState:UIControlStateNormal];
                  [self.btnLocal setTitle:placemark.locality forState:UIControlStateNormal];
              }
     ];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[dynamoDBObjectMapper scan:[Location class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             //NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             //NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (Location *location in paginatedOutput.items) {
                 CLLocation*exitingLocation=[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
                 CLLocationDistance distance=[exitingLocation distanceFromLocation:self.currentLocation];
                 distance=distance/1000.0;
                 NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded-myImage.jpg"];
                 NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                 if(distance<100.0 && location.isDirty==@"true")
                 {
                     NSString * key=[location.location_id stringByAppendingString:@"a"];
                     [self.locationArray addObject:location];
                     
                     AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                     downloadRequest.bucket = @"cleanthecreeks";
                     downloadRequest.key = key;
                     downloadRequest.downloadingFileURL = downloadingFileURL;
                     LocationAnnotation *annotation=[[LocationAnnotation alloc]init];
                     annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                     
                     annotation.title=location.location_name;
                     annotation.subtitle = location.location_id;
                     [self.mainDelegate.locationData setValue:annotation forKey:location.location_id];
                     self.mainDelegate.locationData[annotation.subtitle]=[UIImage imageNamed:@"PlaceIcon"];
                     [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
                         if (task.error){
                             if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                 switch (task.error.code) {
                                     case AWSS3TransferManagerErrorCancelled:
                                     case AWSS3TransferManagerErrorPaused:
                                         break;
                                         
                                     default:
                                         //  NSLog(@"Error: %@", task.error);
                                         break;
                                 }
                             } else {
                                 // Unknown error.
                                 //NSLog(@"Error: %@", task.error);
                             }
                         }
                         
                         if (task.result) {
                             AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                             //self.imageArray[key]=[UIImage imageWithContentsOfFile:downloadingFilePath];
                             self.mainDelegate.locationData[annotation.subtitle]=[UIImage imageWithContentsOfFile:downloadingFilePath];
                             [self.mapView addAnnotation:annotation];
                             [self.locationTable reloadData];
                         }
                         return nil;
                     }];
                 }
                 
             }
             
         }
         
         return nil;
     }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    LocationOverlayView *annotationView = [[LocationOverlayView alloc] initWithAnnotation:annotation reuseIdentifier:@"Attraction"];
    annotationView.canShowCallout = YES;
    return annotationView;
}

- (IBAction)listButtonTapped:(id)sender{
    [self.locationTable setHidden:NO];
    [self.mapView setHidden:YES];
    [self.mapButton setImage:[UIImage imageNamed:@"HeaderMapBtnUnselected"] forState:UIControlStateNormal];
    [self.listButton setImage:[UIImage imageNamed:@"HeaderMenuBtnSelected"] forState:UIControlStateNormal];
}

- (IBAction)mapButtonTapped:(id)sender{
    [self.locationTable setHidden:YES];
    [self.mapView setHidden:NO];
    [self.mapButton setImage:[UIImage imageNamed:@"HeaderMapBtnSelected"] forState:UIControlStateNormal];
    [self.listButton setImage:[UIImage imageNamed:@"HeaderMenuBtnUnselected"] forState:UIControlStateNormal];
}

@end
