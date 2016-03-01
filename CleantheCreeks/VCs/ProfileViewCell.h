//
//  ProfileViewCell.h
//  Clean the Creek
//
//  Created by Andy Johansson on 01/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewCell : UITableViewCell<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *beforePhoto;
@property (weak, nonatomic) IBOutlet UIImageView *afterPhoto;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *kudoCount;
@property (weak, nonatomic) IBOutlet UILabel *comment;
@property (weak, nonatomic) IBOutlet UILabel *location;

@end
