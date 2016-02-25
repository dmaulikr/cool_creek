//
//  LocationOverlayView.m
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/20/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "LocationOverlayView.h"
#import "LocationAnnotation.h"
#import "AppDelegate.h"
#import "PhotoDetailsVC.h"
@implementation LocationOverlayView
- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (self) {
        LocationAnnotation *locAnnotation = self.annotation;
        
         if([mainDelegate.locationData objectForKey:annotation.subtitle])
             self.image = [PhotoDetailsVC scaleImage:mainDelegate.locationData[annotation.subtitle] toSize:CGSizeMake(50.0,50.0)];
    }
    return self;
}
@end
