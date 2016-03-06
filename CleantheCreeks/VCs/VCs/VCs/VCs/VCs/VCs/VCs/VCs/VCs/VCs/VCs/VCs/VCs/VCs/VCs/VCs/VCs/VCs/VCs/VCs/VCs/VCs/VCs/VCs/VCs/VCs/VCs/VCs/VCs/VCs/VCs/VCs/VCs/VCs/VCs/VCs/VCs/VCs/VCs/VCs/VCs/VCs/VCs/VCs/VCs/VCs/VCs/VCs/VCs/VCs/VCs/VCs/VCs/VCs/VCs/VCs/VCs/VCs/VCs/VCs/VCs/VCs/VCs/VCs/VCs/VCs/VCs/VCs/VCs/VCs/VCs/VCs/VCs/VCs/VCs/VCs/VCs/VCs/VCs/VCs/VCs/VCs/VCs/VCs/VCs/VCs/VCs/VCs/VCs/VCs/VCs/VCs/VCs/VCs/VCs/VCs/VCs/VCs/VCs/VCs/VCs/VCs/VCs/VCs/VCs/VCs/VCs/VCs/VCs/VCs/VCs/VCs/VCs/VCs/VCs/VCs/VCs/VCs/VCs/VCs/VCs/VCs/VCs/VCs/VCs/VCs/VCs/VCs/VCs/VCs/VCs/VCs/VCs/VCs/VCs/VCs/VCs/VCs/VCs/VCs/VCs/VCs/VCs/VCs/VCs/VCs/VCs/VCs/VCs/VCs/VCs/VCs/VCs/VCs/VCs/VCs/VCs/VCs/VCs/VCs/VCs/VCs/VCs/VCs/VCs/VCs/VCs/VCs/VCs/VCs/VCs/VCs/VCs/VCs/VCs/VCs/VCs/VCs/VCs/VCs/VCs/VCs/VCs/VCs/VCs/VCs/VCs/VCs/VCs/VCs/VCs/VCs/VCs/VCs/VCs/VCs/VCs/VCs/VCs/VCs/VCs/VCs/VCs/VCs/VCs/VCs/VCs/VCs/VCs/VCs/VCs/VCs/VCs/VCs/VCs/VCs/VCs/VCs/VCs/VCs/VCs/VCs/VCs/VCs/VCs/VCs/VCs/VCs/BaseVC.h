//
//  BaseVC.h
//  Clean the Creek
//
//  Created by a on 2/24/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileTopBarVC.h"

@interface BaseVC : UIViewController<ProfileTopBarVCDelegate>

@property (nonatomic, weak) ProfileTopBarVC* profileTopBar;

- (void)dismissVC;

@end
