//
//  MapView.m
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/9/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "MapView.h"
#import "LocationOverlayView.h"

#import "Location.h"
#import "LocationAnnotation.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSS3/AWSS3.h>
@implementation MapView


- (IBAction)listButtonClicked:(id)sender
{
}
-(void)viewDidLoad
{
    if(!([CLLocationManager authorizationStatus]==kCLAuthorizationStatusRestricted ||[CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied))
    {
        if(self.locationManager==nil){
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
        }
    }
    self.mapView.delegate=self;

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
                 CLLocationDistance distance=[exitingLocation distanceFromLocation:newLocation];
                 distance=distance/1000.0;
                 
                 
                 NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded-myImage.jpg"];
                 NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                 if(distance<100000.0)
                 {
                     
                     // Construct the download request.
                     AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                     
                     downloadRequest.bucket = @"cleanthecreeks";
                     downloadRequest.key = location.location_id;
                     downloadRequest.downloadingFileURL = downloadingFileURL;
                     LocationAnnotation *annotation = [[LocationAnnotation alloc] init];
                    
                     annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                     annotation.title = @"Title";
                     
                     annotation.subtitle = @"subtitle";
                     annotation.image=[UIImage imageNamed:@"PlaceIcon"];
                     [self.mapView addAnnotation:annotation];
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
                             annotation.image=[UIImage imageWithContentsOfFile:downloadingFilePath];
                             
                         }
                         return nil;
                     }];
                 }
                 
             }
             
         }
         return nil;
     }];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    LocationOverlayView *annotationView = [[LocationOverlayView alloc] initWithAnnotation:annotation reuseIdentifier:@"Attraction"];
    annotationView.canShowCallout = YES;
    return annotationView;
}
@end
