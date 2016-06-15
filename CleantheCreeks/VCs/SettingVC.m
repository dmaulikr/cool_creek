//
//  SettingVC.m
//  Clean the Creek
//
//  Created by a on 2/23/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "SettingVC.h"
#import "SlideVC.h"

@implementation SettingVC
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self.profileTopBar setHeaderStyle:NO title:@"SETTINGS" rightBtnHidden:YES];
    NSUserDefaults *settingInfo=[NSUserDefaults standardUserDefaults];
    
    NSString *commentStatus = [settingInfo objectForKey:@"switchComment"];
    if(commentStatus!=nil)
        [self.switchComments setOn:[commentStatus isEqualToString:@"YES"]];
    
    NSString *kudoStatus = [settingInfo objectForKey:@"switchKudo"];
    if(kudoStatus!=nil)
        [self.switchKudos setOn:[kudoStatus isEqualToString:@"YES"]];
    
    NSString *followStatus = [settingInfo objectForKey:@"switchFollow"];
    if(followStatus!=nil)
        [self.switchFollows setOn:[followStatus isEqualToString:@"YES"]];
    
    NSString *tagStatus = [settingInfo objectForKey:@"switchTag"];
    if(tagStatus!=nil)
        [self.switchTag setOn:[tagStatus isEqualToString:@"YES"]];
    
    NSString *locationStatus = [settingInfo objectForKey:@"switchLocation"];
    if(locationStatus!=nil)
        [self.switchNewLocation setOn:[locationStatus isEqualToString:@"YES"]];
    
    NSString *measurement = [settingInfo objectForKey:@"measurement"];
    if(measurement!=nil)
    {
        if([measurement isEqualToString:@"miles"])
        {
            
            [self.measurementButton setTitle:@"Miles" forState:UIControlStateNormal];
        }
        else
        {
            
            [self.measurementButton setTitle:@"Metric" forState:UIControlStateNormal];
        }
    }
    [self.tabBarController.tabBar setHidden:YES];
}

#pragma ProfileTopBarVCDelegate Implementation

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

- (IBAction)switchCommentUpdate:(id)sender {
    NSUserDefaults *settingInfo=[NSUserDefaults standardUserDefaults];
    BOOL value=((UISwitch*)sender).isOn;
    [settingInfo setObject:(value)? @"YES":@"NO" forKey:@"switchComment"];
    [settingInfo synchronize];
}

- (IBAction)switchKudoUpdated:(id)sender {
    NSUserDefaults *settingInfo=[NSUserDefaults standardUserDefaults];
    BOOL value=((UISwitch*)sender).isOn;
    [settingInfo setObject:(value)? @"YES":@"NO" forKey:@"switchKudo"];
    [settingInfo synchronize];
}

- (IBAction)switchFollowUpdate:(id)sender {
    NSUserDefaults *settingInfo=[NSUserDefaults standardUserDefaults];
    BOOL value=((UISwitch*)sender).isOn;
    [settingInfo setObject:(value)? @"YES":@"NO" forKey:@"switchFollow"];
    [settingInfo synchronize];
}

- (IBAction)switchTagUpdated:(id)sender {
    NSUserDefaults *settingInfo=[NSUserDefaults standardUserDefaults];
    BOOL value=((UISwitch*)sender).isOn;
    [settingInfo setObject:(value)? @"YES":@"NO" forKey:@"switchTag"];
    [settingInfo synchronize];
    
}

- (IBAction)switchLocationUpdate:(id)sender {
    NSUserDefaults *settingInfo=[NSUserDefaults standardUserDefaults];
    BOOL value=((UISwitch*)sender).isOn;
    [settingInfo setObject:(value)? @"YES":@"NO" forKey:@"switchLocation"];
    [settingInfo synchronize];
}

- (IBAction)measurementUpdate:(id)sender {
    NSUserDefaults *settingInfo=[NSUserDefaults standardUserDefaults];
    NSString *measurement = [self.measurementButton titleForState:UIControlStateNormal];
    if([measurement isEqualToString:@"Metric"])
    {
        [settingInfo setObject:@"miles" forKey:@"measurement"];
        [self.measurementButton setTitle:@"Miles" forState:UIControlStateNormal];
    }
    else
    {
        [settingInfo setObject:@"KM" forKey:@"measurement"];
        [self.measurementButton setTitle:@"Metric" forState:UIControlStateNormal];
    }
}

- (IBAction)signOut:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sign Out" message:@"Are you sure to sign out?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        NSDictionary * dict = [defs dictionaryRepresentation];
        for (id key in dict) {
            [defs removeObjectForKey:key];
        }
        [defs synchronize];
        
        SlideVC * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideVC"];
        
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
        [navC.navigationBar setHidden:YES];
        
        [self presentViewController:navC animated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:alertController animated:YES completion:nil];
    });
}
@end
