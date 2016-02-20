//
//  FacebookPostVC.m
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/18/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "FacebookPostVC.h"
#import "MainTabnav.h"
@implementation FacebookPostVC

- (IBAction)skip:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.tabBarController.selectedViewController
    = [self.tabBarController.viewControllers objectAtIndex:1];
    
}
-(void)showtab
{
    [self.tabBarController setSelectedIndex:2];
}
@end
