#import "LocationVC.h"
#import "AppDelegate.h"

#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

#import <AWSS3/AWSS3.h>

#import "Location.h"
#import "locationCell.h"
#import "LocationOverlayView.h"
#import "LocationAnnotation.h"
#import "ActivityPhotoDetailsVC.h"
#import "CameraVC.h"
#import "Clean the Creek-Bridging-Header.h"
@implementation LocationVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [_locationManager requestWhenInUseAuthorization];
    _locationManager=[[CLLocationManager alloc] init];
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
        [_locationManager requestWhenInUseAuthorization];
    
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 500.f;
    self.locationManager=_locationManager;
    if([CLLocationManager locationServicesEnabled]){
        [self.locationManager startUpdatingLocation];
    }
    else{
        
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationArray = [[NSMutableArray alloc]init];
    [self.locationArray removeAllObjects];
    self.mapView.delegate=self;
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableViewDelegate Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([self.locationArray count]>0)
        return [self.locationArray count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    locationCell * cell=nil;
    cell = (locationCell*)[tableView dequeueReusableCellWithIdentifier:@"locationCell"];
    if([self.locationArray count]>0 && indexPath.row <= [self.locationArray count]-1)
    {
        Location * location=[self.locationArray objectAtIndex:indexPath.row];
        [cell.locationName setText:location.location_name];
        CLLocation*exitingLocation=[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
        CLLocationDistance distance=[exitingLocation distanceFromLocation:self.currentLocation];
        distance=distance/1000.0;
        NSString*distanceText=[[NSString alloc]initWithFormat:@"%.02fKM",distance];
        [cell.distance setText:distanceText];
        if(self.mainDelegate.locationData[location.location_id]!=nil)
        {
            cell.image.image=(UIImage*)(self.mainDelegate.locationData[location.location_id]);
        }
        cell.viewBtn.tag = indexPath.row;
        cell.moreBtn.tag = indexPath.row;
        
        [cell.viewBtn addTarget:self action:@selector(viewBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cleanBtn addTarget:self action:@selector(cleanBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(!cell){
        cell=(locationCell*)[[UITableViewCell alloc]init];
    }
    
    cell.delegate = self;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (40/667) * screenHeight, (40/667) * screenHeight)];
    [footerView addSubview:_spinner];
    
    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_spinner.superview != nil) {
        CGRect frm = _spinner.superview.frame;
        _spinner.center = CGPointMake(frm.size.width / 2, frm.size.height / 2);
    }
    [_spinner startAnimating];
    //loadDataonTableView()
}

-(void)viewBtnClicked:(UIButton*)sender
{
    self.selectedIndex=sender.tag;
    [self performSegueWithIdentifier:@"showLocationDetails" sender:self];
    
}

-(void)cleanBtnClicked:(UIButton*)sender
{
    self.selectedIndex=sender.tag;
    [self performSegueWithIdentifier:@"cleanLocation" sender:self];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if([self.locationArray count]>0)
    {
        NSInteger * selectedPath = self.selectedIndex;
        Location * location=[self.locationArray objectAtIndex:selectedPath];
        if([segue.identifier isEqualToString:@"showLocationDetails"])
        {
            ActivityPhotoDetailsVC* vc = (ActivityPhotoDetailsVC*)segue.destinationViewController;
            vc.location = [[Location alloc]init];
            NSLog(@"Item %d is selected",selectedPath);
            vc.location = location;
            vc.beforePhoto=(UIImage*)(self.mainDelegate.locationData[location.location_id]);
            vc.cleaned=NO;
        }
        else if([segue.identifier isEqualToString:@"cleanLocation"])
        {
            CameraVC* vc = (CameraVC*)segue.destinationViewController;
            vc.photoTaken = NO;
            vc.dirtyPhoto=(UIImage*)(self.mainDelegate.locationData[location.location_id]);
            vc.location = [[Location alloc]init];
            vc.location = location;
            
        }
    }
}
#pragma CLLocationDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.locationArray removeAllObjects];
    [self.mainDelegate.locationData removeAllObjects];
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
                  [self.btnCountry setTitle:placemark.country forState:UIControlStateNormal];
                  [self.btnState setTitle:[placemark.addressDictionary valueForKey:@"State"] forState:UIControlStateNormal];
                  [self.btnLocal setTitle:placemark.locality forState:UIControlStateNormal];
              }
     ];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[dynamoDBObjectMapper scan:[Location class] expression:scanExpression] continueWithBlock:^id(AWSTask *task) {
        if (task.result) {
            AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
            for (Location *location in paginatedOutput.items) {
                CLLocation*exitingLocation=[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
                CLLocationDistance distance=[exitingLocation distanceFromLocation:self.currentLocation];
                distance=distance/1000.0;
                NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:location.location_id];
                NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                if(distance<100.0 && [location.isDirty isEqualToString:@"true"])
                {
                    if(![self.locationArray containsObject:location])
                        [self.locationArray addObject:location];
                    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    downloadRequest.bucket = @"cleanthecreeks";
                    NSString * key=[location.location_id stringByAppendingString:@"a"];
                    downloadRequest.key = key;
                    downloadRequest.downloadingFileURL = downloadingFileURL;
                    LocationAnnotation *annotation=[[LocationAnnotation alloc]init];
                    annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                    
                    annotation.title = location.location_name;
                    annotation.subtitle = location.location_id;
                    self.mainDelegate.locationData[location.location_id]=[UIImage imageNamed:@"PlaceIcon"];
                    
                    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task2) {
                        if (task2.result) {
                            self.imageArray[key]=[UIImage imageWithContentsOfFile:downloadingFilePath];
                            self.mainDelegate.locationData[location.location_id]=[UIImage imageWithContentsOfFile:downloadingFilePath];
                            [self.locationTable reloadData];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.mapView addAnnotation:annotation];
                        });
                        
                        return nil;
                    }];
                    
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.locationTable reloadData];
        });
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
    [self.view bringSubviewToFront:self.mapView];
}

@end
