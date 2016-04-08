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
#import <UIScrollView+InfiniteScroll.h>
#import "CustomInfiniteIndicator.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@interface LocationVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@property (nonatomic,strong) CustomInfiniteIndicator *infiniteIndicator;
@property(strong,nonatomic) Location * annotationLocation;
@end


@implementation LocationVC

- (void)viewDidLoad{
    [super viewDidLoad];
    [_locationManager requestWhenInUseAuthorization];
    _locationManager=[[CLLocationManager alloc] init];
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
        [_locationManager requestWhenInUseAuthorization];
    
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100.f;
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
    self.mapView.showsUserLocation=YES;
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.locationTable addSubview:self.refreshControl];
    self.displayItemCount=8;
    
    [self.refreshControl beginRefreshing];
    [self updateData];
    
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    self.locationTable.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    self.infiniteIndicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    self.locationTable.infiniteScrollIndicatorView = self.infiniteIndicator;
    
    [self.locationTable addInfiniteScrollWithHandler:^(UITableView* tableView) {
        self.displayItemCount+=2;
        self.displayItemCount = MIN(self.locationArray.count,self.displayItemCount);
        [self.infiniteIndicator startAnimating];
        [tableView reloadData];
        [tableView finishInfiniteScroll];
    }];

    
    
}

- (IBAction)backBtnClicked:(id)sender {
    [self dismissVC];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:self.fromSlider];
    self.backBtn.hidden = !self.fromSlider;
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    if(self.mainDelegate.shouldRefreshLocation)
    {
        [self.refreshControl beginRefreshing];
        [self updateData];
        self.mainDelegate.shouldRefreshLocation = NO;
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableViewDelegate Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([self.locationArray count]>0)
        return self.displayItemCount;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    locationCell * cell = nil;
    cell = (locationCell*)[tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
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
        cell.cleanBtn.tag = indexPath.row;
        
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


-(void)viewBtnClicked:(UIButton*)sender
{
    self.selectedIndex=sender.tag;
    [self performSegueWithIdentifier:@"showLocationDetails" sender:self];
    
}

-(void)cleanBtnClicked:(UIButton*)sender
{
    if(self.fromSlider)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sign in with Facebook" message:@"In order to take a photo you must be signed in ot your facebook account." preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            [login
             logInWithReadPermissions: @[@"public_profile",@"email"]
             fromViewController:self
             handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                 if (error) {
                     NSLog(@"Process error");
                 } else if (result.isCancelled) {
                     NSLog(@"Cancelled");
                 }
                 else
                 {
                     NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                     [parameters setValue:@"id,name,email,location,about" forKey:@"fields"];
                     [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                          
                          if (!error) {
                              NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
                              NSUserDefaults *loginInfo = [NSUserDefaults standardUserDefaults];
                              NSString *fbUsername = [[result valueForKey:@"link"] lastPathComponent];
                              [loginInfo setObject:fbUsername forKey:@"username"];
                              [loginInfo setObject:result[@"id"] forKey:@"user_id"];
                              [loginInfo setObject:result[@"name"] forKey:@"user_name"];
                              [loginInfo setObject:result[@"email"] forKey:@"user_email"];
                              [loginInfo setObject:result[@"location"] forKey:@"user_location"];
                              [loginInfo setObject:result[@"about"] forKey:@"user_about"];
                              [loginInfo synchronize];
                              User * user_info = [User new];
                              user_info.user_id = result[@"id"];
                              //user_info.kudos = [[NSArray alloc]init];
                              user_info.user_name = result[@"name"];
                              user_info.device_token = [loginInfo objectForKey:@"devicetoken"];
                              user_info.user_email= [loginInfo objectForKey:@"user_email"];
                              user_info.user_about=[loginInfo objectForKey:@"user_about"];
                              
                              AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
                              updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorAppendSet;
                              AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
                              [[dynamoDBObjectMapper save:user_info configuration:updateMapperConfig]
                               continueWithBlock:^id(AWSTask *task) {
                                  
                                   if (task.result) {
                                       
                                        [self dismissVC];
                                   }
                                   return nil;
                               }];
                              
                            }
                          
                      }];
                     
                     
                 }
             }];

        }]];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
    else
    {
        self.selectedIndex = sender.tag;
        [self performSegueWithIdentifier:@"cleanLocation" sender:self];
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if([self.locationArray count]>0)
    {
        
        Location * location=[self.locationArray objectAtIndex:self.selectedIndex];
        if([segue.identifier isEqualToString:@"showLocationDetails"])
        {
            ActivityPhotoDetailsVC* vc = (ActivityPhotoDetailsVC*)segue.destinationViewController;
            vc.location = [[Location alloc]init];
            
            vc.location = location;
            vc.beforePhoto = (UIImage*)(self.mainDelegate.locationData[location.location_id]);
            vc.cleaned = NO;
            vc.fromLocationView = YES;
        }
        else if([segue.identifier isEqualToString:@"showMapDetails"])
        {
            ActivityPhotoDetailsVC* vc = (ActivityPhotoDetailsVC*)segue.destinationViewController;
            vc.location = self.annotationLocation;
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
- (void) updateData
{
    self.locationArray=[[NSMutableArray alloc]init];
    self.mainDelegate.locationData=[[NSMutableDictionary alloc] init];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.filterExpression = @"isDirty = :val";
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    scanExpression.expressionAttributeValues = @{@":val":@"true"};
    [[dynamoDBObjectMapper scan:[Location class] expression:scanExpression] continueWithBlock:^id(AWSTask *task) {
        if (task.result) {
            AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
            for (int i=0;i<paginatedOutput.items.count;i++) {
                Location * location= [paginatedOutput.items objectAtIndex:i];
                CLLocation*exitingLocation=[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
                CLLocationDistance distance=[exitingLocation distanceFromLocation:self.currentLocation];
                distance=distance/1000.0;
                
                //Setting the file download path
                NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:location.location_id];
                NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                
                if(![self.locationArray containsObject:location])
                    [self.locationArray addObject:location];
                
                //Setting the annotation
                LocationAnnotation *annotation=[[LocationAnnotation alloc]init];
                annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                
                annotation.title = location.location_name;
                annotation.subtitle = location.location_id;
                
                //Downloading files
                AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                downloadRequest.bucket = @"cleanthecreeks";
                NSString * key=[location.location_id stringByAppendingString:@"a"];
                downloadRequest.key = key;
                downloadRequest.downloadingFileURL = downloadingFileURL;
                
                self.mainDelegate.locationData[location.location_id]=[UIImage imageNamed:@"EmptyPhoto"];
                [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task2) {
                    if (task2.result) {
                        self.imageArray[key]=[UIImage imageWithContentsOfFile:downloadingFilePath];
                        self.mainDelegate.locationData[location.location_id]=[UIImage imageWithContentsOfFile:downloadingFilePath];
                        [self.locationTable reloadData];
                        [self.mapView addAnnotation:annotation];
                    }
                    return nil;
                }];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.locationArray = (NSMutableArray*)[self.locationArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    CLLocation*locationA=[[CLLocation alloc]initWithLatitude:((Location*)a).latitude longitude:((Location*)a).longitude];
                    CLLocationDistance distanceA=[locationA distanceFromLocation:self.currentLocation];
                    
                    CLLocation*locationB=[[CLLocation alloc]initWithLatitude:((Location*)b).latitude longitude:((Location*)b).longitude];
                    CLLocationDistance distanceB=[locationB distanceFromLocation:self.currentLocation];
                    return distanceA>distanceB;
                }];
                self.displayItemCount = MIN(self.locationArray.count,self.displayItemCount);
                [self.locationTable reloadData];
                
                [self.refreshControl endRefreshing];
                
            });
            
            
        }
        return nil;
        
    }];
    
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
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
    [self.mapView setShowsUserLocation:YES];
    self.currentLocation=newLocation;
    self.mainDelegate.currentLocation=newLocation;
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    [ceo reverseGeocodeLocation:self.currentLocation
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  [self.btnCountry setTitle:placemark.country forState:UIControlStateNormal];
                  [self.btnState setTitle:[placemark.addressDictionary valueForKey:@"State"] forState:UIControlStateNormal];
                  [self.btnLocal setTitle:placemark.locality forState:UIControlStateNormal];
              }
     ];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if(annotation == mapView.userLocation)
    {
        MKAnnotationView *pin = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"VoteSpotPin"];
        if (pin == nil)
        {
            
            pin = [[MKAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"CurrentPin"] ;
        }
        else
        {
            pin.annotation = annotation;
        }
        
        [pin setImage:[UIImage imageNamed:@"Dot"]];
        pin.canShowCallout = NO;
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pin;
        
    }
    else
    {
        LocationOverlayView *annotationView = [[LocationOverlayView alloc] initWithAnnotation:annotation reuseIdentifier:@"Attraction"];
        annotationView.canShowCallout = YES;
        return annotationView;
        
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    CLLocationCoordinate2D coordinate=[view.annotation coordinate];
    NSString * location_id=[NSString stringWithFormat:@"%f,%f",coordinate.latitude,coordinate.longitude];
    self.annotationLocation=[Location class];
    for(Location * loc in self.locationArray)
    {
        if([loc.location_id isEqualToString:location_id])
        {
            self.annotationLocation=loc;
            break;
        }
    }
    if(view.annotation !=mapView.userLocation)
        [self performSegueWithIdentifier:@"showMapDetails" sender:self];
    NSLog(@"selected annotation");
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
