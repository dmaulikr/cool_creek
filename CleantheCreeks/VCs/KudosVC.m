//
//  KudosVC.m
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "KudosVC.h"

@implementation KudosVC

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.profileTopBar setHeaderStyle:NO title:@"KUDOS" rightBtnHidden:YES];
}
#pragma ProfileTopBarVCDelegate Implementation

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

@end
