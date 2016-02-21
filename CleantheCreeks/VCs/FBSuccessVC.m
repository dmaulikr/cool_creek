//
//  FBSuccessVC.m
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "FBSuccessVC.h"

@implementation FBSuccessVC
-(void)viewDidLoad
{
    [self.tabBarController.tabBar setHidden:NO];
}
- (IBAction)showFBPost:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    NSString *fb_base = @"fb://profile/";
    NSString *fb_url = [fb_base stringByAppendingString:user_id];
    NSURL *url = [NSURL URLWithString:fb_url];
    [[UIApplication sharedApplication] openURL:url];
}
@end
