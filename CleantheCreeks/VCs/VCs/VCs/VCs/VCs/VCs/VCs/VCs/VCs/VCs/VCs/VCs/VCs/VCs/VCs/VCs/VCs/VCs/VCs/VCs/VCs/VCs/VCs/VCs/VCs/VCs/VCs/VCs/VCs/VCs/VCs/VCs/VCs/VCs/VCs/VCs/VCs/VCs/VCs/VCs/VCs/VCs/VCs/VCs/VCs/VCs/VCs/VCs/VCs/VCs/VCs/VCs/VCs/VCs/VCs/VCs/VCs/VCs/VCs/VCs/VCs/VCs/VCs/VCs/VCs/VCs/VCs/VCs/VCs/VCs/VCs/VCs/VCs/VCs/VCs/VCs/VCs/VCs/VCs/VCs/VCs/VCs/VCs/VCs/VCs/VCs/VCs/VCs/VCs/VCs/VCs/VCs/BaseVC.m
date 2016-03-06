//
//  BaseVC.m
//  Clean the Creek
//
//  Created by a on 2/24/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "BaseVC.h"

@implementation BaseVC

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier  isEqual: @"ProfileTopBarVC"]){
        self.profileTopBar = (ProfileTopBarVC*)segue.destinationViewController;
        self.profileTopBar.delegate = self;
    }
}

- (void)dismissVC{
    if (self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma ProfileTopBarVCDelegate Implementation

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

@end
