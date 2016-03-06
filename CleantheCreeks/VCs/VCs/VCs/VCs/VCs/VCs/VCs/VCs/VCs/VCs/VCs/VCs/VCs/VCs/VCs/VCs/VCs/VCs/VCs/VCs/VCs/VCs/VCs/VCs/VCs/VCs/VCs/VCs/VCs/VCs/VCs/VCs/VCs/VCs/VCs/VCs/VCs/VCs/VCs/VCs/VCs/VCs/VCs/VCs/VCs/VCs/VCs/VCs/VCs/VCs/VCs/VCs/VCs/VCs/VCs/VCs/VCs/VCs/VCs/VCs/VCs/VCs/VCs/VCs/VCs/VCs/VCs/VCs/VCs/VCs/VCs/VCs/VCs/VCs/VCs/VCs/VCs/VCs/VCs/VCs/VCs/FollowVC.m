//
//  FollowVC.m
//  Clean the Creek
//
//  Created by Andy Johansson on 04/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "FollowVC.h"

@implementation FollowVC

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCell* cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"SecondDetailCell"];
}

@end
