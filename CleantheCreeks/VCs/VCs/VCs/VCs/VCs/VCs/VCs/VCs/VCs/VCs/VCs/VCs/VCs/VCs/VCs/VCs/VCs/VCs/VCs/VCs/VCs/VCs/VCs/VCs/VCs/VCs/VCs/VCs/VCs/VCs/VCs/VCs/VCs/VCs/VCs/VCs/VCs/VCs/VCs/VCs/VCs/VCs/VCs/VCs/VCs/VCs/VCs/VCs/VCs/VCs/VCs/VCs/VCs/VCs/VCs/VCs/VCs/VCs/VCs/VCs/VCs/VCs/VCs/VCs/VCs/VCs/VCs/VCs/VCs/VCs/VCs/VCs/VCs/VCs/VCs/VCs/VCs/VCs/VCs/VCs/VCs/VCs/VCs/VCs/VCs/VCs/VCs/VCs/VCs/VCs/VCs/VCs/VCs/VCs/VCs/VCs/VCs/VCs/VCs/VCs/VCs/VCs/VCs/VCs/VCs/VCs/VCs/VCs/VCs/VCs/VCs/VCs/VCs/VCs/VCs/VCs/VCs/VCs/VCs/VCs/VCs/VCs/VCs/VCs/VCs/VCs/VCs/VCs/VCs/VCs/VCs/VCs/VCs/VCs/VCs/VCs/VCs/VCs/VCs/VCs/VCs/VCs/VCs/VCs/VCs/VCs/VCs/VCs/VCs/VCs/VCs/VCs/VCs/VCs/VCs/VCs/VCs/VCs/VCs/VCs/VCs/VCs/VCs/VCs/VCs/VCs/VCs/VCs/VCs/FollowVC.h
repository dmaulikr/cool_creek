//
//  FollowVC.h
//  Clean the Creek
//
//  Created by Andy Johansson on 04/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *followSegment;
@property (weak, nonatomic) IBOutlet UITableView *followTable;

@end
