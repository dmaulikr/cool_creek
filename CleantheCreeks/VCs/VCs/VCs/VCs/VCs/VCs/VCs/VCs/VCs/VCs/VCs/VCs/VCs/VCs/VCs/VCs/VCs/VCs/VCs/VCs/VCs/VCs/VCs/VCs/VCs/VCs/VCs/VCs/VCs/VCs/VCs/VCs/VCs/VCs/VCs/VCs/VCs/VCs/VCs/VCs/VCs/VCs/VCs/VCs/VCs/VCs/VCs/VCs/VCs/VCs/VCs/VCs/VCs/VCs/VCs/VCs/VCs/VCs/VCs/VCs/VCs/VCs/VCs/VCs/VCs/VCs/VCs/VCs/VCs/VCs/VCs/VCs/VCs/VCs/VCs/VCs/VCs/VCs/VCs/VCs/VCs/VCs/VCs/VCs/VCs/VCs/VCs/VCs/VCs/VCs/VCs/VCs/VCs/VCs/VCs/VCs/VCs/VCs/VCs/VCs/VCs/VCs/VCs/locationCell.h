//
//  locationCell.h
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/6/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationVC.h"

@interface locationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *locationName;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@property (weak, nonatomic) IBOutlet UIButton *cleanBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;

@property (weak, nonatomic) LocationVC *delegate;
- (IBAction)moreBtnTapped:(id)sender;

@end
