//
//  LocationOverlayView.m
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/20/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "LocationOverlayView.h"
#import "LocationAnnotation.h"
@implementation LocationOverlayView
- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        LocationAnnotation *locAnnotation = self.annotation;
        
        self.image = locAnnotation.image;
    }
    
    return self;
}
@end
