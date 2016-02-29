//
//  MainTabNav.m
//  CleantheCreeks
//
//  Created by Kimura EIJI on 1/28/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "MainTabNav.h"
#import <CoreLocation/CoreLocation.h>

@interface MainTabNav ()<CLLocationManagerDelegate,UINavigationControllerDelegate>

@end
CLLocationManager * locationManager;

@implementation MainTabNav

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedViewController=[self.viewControllers objectAtIndex:1];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
}

-(void) viewDidAppear:(BOOL)animated
{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
{
    if(tabBarController.selectedIndex==0)
    {
         self.selectedViewController=[self.viewControllers objectAtIndex:1];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

@end
