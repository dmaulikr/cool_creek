//
//  ActivityPhotoDetailsVC.h
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface ActivityPhotoDetailsVC : BaseVC<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tv;

@end