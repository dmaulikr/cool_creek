//
//  AppDelegate.h
//  CleantheCreeks
//
//  Created by ship8-2 on 1/27/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//Add a location manager property to this app delegate
@property (strong, nonatomic) CLLocationManager *locationManager;


-(NSString *)getAddressFromLatLon:(double)pdblLatitude:(double)pdblLongitude;

@end

