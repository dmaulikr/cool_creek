//
//  FollowVC.m
//  Clean the Creek
//
//  Created by Andy Johansson on 04/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "FollowVC.h"
#import "KudosCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AWSS3/AWSS3.h>
#import "User.h"
#import "Location.h"
@implementation FollowVC

-(void)viewDidLoad
{
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_name = [defaults objectForKey:@"user_name"];
    NSLog(@"%@", user_name);
    self.appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self.profileTopBar setHeaderStyle:NO title:user_name rightBtnHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    
    [self.followSegment setSelectedSegmentIndex:self.displayIndex];
    [self loadData:self.displayIndex];
}
-(void)loadData:(int)mode
{
    self.displayArray=[[NSMutableArray alloc]init];
    if(mode==0)
        self.displayArray=self.appDelegate.followingArray;
    else
        self.displayArray=self.appDelegate.followersArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.followTable reloadData];
    });
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.displayArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KudosCell* cell = (KudosCell*)[tableView dequeueReusableCellWithIdentifier:@"KudosCell"];
    NSDictionary * current_user=[self.displayArray objectAtIndex:indexPath.row];
    NSDictionary * user_id=[current_user objectForKey:@"id"];
    User * user=[self.appDelegate.userArray objectForKey:user_id];
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", user_id];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userImageURL]];
        if ( data == nil )
            return;
        [cell.user_photo setImage:[UIImage imageWithData: data]];
    });
    
    [cell.user_name setText:user.user_name];
    [cell.user_location setText:[NSString stringWithFormat:@"%@, %@, %@", user.location, user.state, user.country]];
    
    if(![AppDelegate isFollowing:user])
        [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoSelect"] forState:UIControlStateNormal];
    if(!cell){
        cell = nil;
    }
    return cell;
}


- (IBAction)followingChange:(id)sender {
    if(self.followSegment.selectedSegmentIndex==0)
        self.displayArray=self.appDelegate.followingArray;
    else
        self.displayArray=self.appDelegate.followersArray;
    [self.followTable reloadData];
}

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}
@end
