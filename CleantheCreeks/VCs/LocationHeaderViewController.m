//
//  LocationHeaderViewController.m
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/9/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "LocationHeaderViewController.h"


@implementation LocationHeaderViewController
-(void) viewDidLoad
{
    NSArray *viewControllers =     self.navigationController.viewControllers;
    int count = [viewControllers count];
    id previousController = [viewControllers objectAtIndex:count - 2];
    self.navigationController=(LocationNav*)previousController;
    
}
- (IBAction)listButtonClicked:(id)sender {
    [self.navigationController addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LocationListView"]];
    [_showListButton setBackgroundImage:[UIImage imageNamed:@"HeaderMenuBtnSelected"] forState:UIControlStateNormal];
    [_showMapButton setBackgroundImage:[UIImage imageNamed:@"HeaderMapBtnUnselected"] forState:UIControlStateNormal];
}
- (IBAction)mapButtonClicked:(id)sender {
    [self.navigationController addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LocationMapView"]];
    [_showListButton setImage:[UIImage imageNamed:@"HeaderMenuBtnUnselected"] forState:UIControlStateNormal];
    [_showMapButton setImage:[UIImage imageNamed:@"HeaderMapBtnSelected"] forState:UIControlStateNormal];
}

@end
