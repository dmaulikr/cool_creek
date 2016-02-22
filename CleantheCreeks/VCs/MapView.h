//
//  MapView.h
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/9/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationHeaderViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface MapView : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
- (IBAction)listButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) NSMutableArray * locationArray;

@end
