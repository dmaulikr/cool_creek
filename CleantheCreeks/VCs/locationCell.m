//
//  locationCell.m
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/6/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "locationCell.h"

@implementation locationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cleanClicked:(id)sender {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Clone" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your editAction here
    }];
    editAction.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your deleteAction here
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction,editAction];
}
@end
