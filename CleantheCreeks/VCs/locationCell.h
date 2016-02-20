//
//  locationCell.h
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/6/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface locationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *locationName;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UIButton *cleanButton;
- (IBAction)cleanClicked:(id)sender;

@end
