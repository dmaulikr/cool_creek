//
//  SettingVC.h
//  Clean the Creek
//
//  Created by a on 2/23/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface SettingVC : BaseVC
@property (weak, nonatomic) IBOutlet UISwitch *switchComments;
@property (weak, nonatomic) IBOutlet UISwitch *switchKudos;
@property (weak, nonatomic) IBOutlet UISwitch *switchFollows;
@property (weak, nonatomic) IBOutlet UISwitch *switchTag;
@property (weak, nonatomic) IBOutlet UISwitch *switchNewLocation;
- (IBAction)switchCommentUpdate:(id)sender;
- (IBAction)switchKudoUpdated:(id)sender;
- (IBAction)switchFollowUpdate:(id)sender;
- (IBAction)switchTagUpdated:(id)sender;
- (IBAction)switchLocationUpdate:(id)sender;
- (IBAction)measurementUpdate:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *measurementButton;

@end
