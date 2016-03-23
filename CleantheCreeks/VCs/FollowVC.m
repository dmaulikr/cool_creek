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

#import <AWSS3/AWSS3.h>
#import "User.h"
#import "Location.h"
@interface FollowVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@property(nonatomic) int mode;
@end

@implementation FollowVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_name = [self.defaults objectForKey:@"user_name"];
    NSLog(@"%@", user_name);
    [self.profileTopBar setHeaderStyle:NO title:user_name rightBtnHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.followTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    
    [self.refreshControl beginRefreshing];
    
    [self loadData];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.followSegment setSelectedSegmentIndex:self.displayIndex];
}

-(void)loadData
{
    self.displayArray=[[NSMutableArray alloc]init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.appDelegate loadData];
        if(self.displayIndex==0)
            self.displayArray=self.appDelegate.followingArray;
        else if(self.displayIndex==1)
            self.displayArray=self.appDelegate.followersArray;
        [self.followTable reloadData];
        [self.refreshControl endRefreshing];
        
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
    cell.likeButton.tag=indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoSelect"] forState:UIControlStateNormal];
    [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoUnselect"] forState:UIControlStateSelected];
    if([AppDelegate isFollowing:user])
        cell.likeButton.selected=YES;
    if(!cell){
        cell = nil;
    }
    return cell;
}

-(void)likeBtnClicked:(UIButton*)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.current_user_id = [defaults objectForKey:@"user_id"];
    NSDictionary * target_user=[self.displayArray objectAtIndex:sender.tag];
    NSString * target_id=[target_user objectForKey:@"id"];
    User * targetuser=[self.appDelegate.userArray objectForKey:target_id];
    User * currentuser=[self.appDelegate.userArray objectForKey:self.current_user_id];
    
    NSMutableArray * followerArray=[[NSMutableArray alloc] init]; //Add current user to the follower list of the user on the table
    NSMutableArray * followingArray=[[NSMutableArray alloc] init];
    if(targetuser.followers!=nil)
        followerArray=targetuser.followers;
    
    if(currentuser.followings!=nil)
        followingArray=currentuser.followings;
    NSMutableDictionary *followerItem=[[NSMutableDictionary alloc]init];
    [followerItem setObject:self.current_user_id forKey:@"id"];
    double date =[[NSDate date]timeIntervalSince1970];
    NSString *dateString=[NSString stringWithFormat:@"%f",date];
    [followerItem setObject:dateString forKey:@"time"];

    NSMutableDictionary *followingItem=[[NSMutableDictionary alloc]init];
    [followingItem setObject:target_id forKey:@"id"];
    [followingItem setObject:dateString forKey:@"time"];

    bool selected=!sender.selected;
    
    //Updating current user followings
    if(selected)
        [followingArray addObject:followingItem];
    else
    {
        if(followingArray!=nil)
        {
            for(NSDictionary *following in followingArray)
            {
                if([[following objectForKey:@"id"] isEqualToString:target_id])
                {
                    [followingArray removeObject:following];
                    break;
                }
            }
        }
    }
    if([followingArray count]!=0)
        currentuser.followings=[[NSMutableArray alloc] initWithArray:followingArray];
    else
        currentuser.followings=nil;
   
    sender.enabled=NO;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
    updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
    
    [[dynamoDBObjectMapper save:currentuser configuration:updateMapperConfig]
     continueWithBlock:^id(AWSTask *task) {
        
         if (task.result) {
             
             //Updating target using followers
             if(![target_id isEqual:self.current_user_id])
             {
                 if(selected)
                     [followerArray addObject:followerItem];
                 else
                 {
                     if(followerArray!=nil)
                     {
                         for(NSDictionary *follower in followerArray)
                         {
                             if([[follower objectForKey:@"id"] isEqualToString:self.current_user_id])
                             {
                                 [followerArray removeObject:follower];
                                 break;
                             }
                         }
                     }
                 }
                 if([followerArray count]!=0)
                     targetuser.followers=[[NSMutableArray alloc] initWithArray:followerArray];
                 else
                     targetuser.followers=nil;
                 sender.enabled=NO;
                 
                 [[dynamoDBObjectMapper save:targetuser configuration:updateMapperConfig]
                  continueWithBlock:^id(AWSTask *task) {
                    if (task.result) {
                            sender.enabled=YES;
                          [self.appDelegate loadData];
                           sender.selected=!sender.selected;
                      }
                      
                      return nil;
                  }];
             }

         }
         
         return nil;
     }];
    
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
