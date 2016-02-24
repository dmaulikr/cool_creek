//
//  SettingVC.m
//  Clean the Creek
//
//  Created by a on 2/23/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "SettingVC.h"

@implementation SettingVC

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.profileTopBar setHeaderStyle:NO title:@"SETTINGS" rightBtnHidden:YES];
}

#pragma ProfileTopBarVCDelegate Implementation

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

@end
