//
//  FollowVC.h
//  Clean the Creek
//
//  Created by Andy Johansson on 04/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "AppDelegate.h"
@interface FollowVC : BaseVC<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *followSegment;
@property (weak, nonatomic) IBOutlet UITableView *followTable;
@property (strong, nonatomic) NSMutableArray * displayArray;
@property (nonatomic) int displayIndex;
@property (strong, nonatomic) AppDelegate * appDelegate;
- (IBAction)followingChange:(id)sender;
@property (strong,nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSString * current_user_id;
@end
