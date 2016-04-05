#import "ProfileVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "User.h"
#import "Location.h"
#import "ProfileViewCell.h"
#import "FollowVC.h"
#import "AppDelegate.h"
#import <UIScrollView+InfiniteScroll.h>
#import "CustomInfiniteIndicator.h"

@interface ProfileVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@property (nonatomic,strong) CustomInfiniteIndicator *infiniteIndicator;
@end
@implementation ProfileVC

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationArray=[[NSMutableArray alloc]init];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.profileTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    
    self.displayItemCount=3;
    
    self.profileTable.estimatedRowHeight = 323.f;
    self.profileTable.rowHeight = UITableViewAutomaticDimension;
    
    self.profileTable.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    self.infiniteIndicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    self.profileTable.infiniteScrollIndicatorView = self.infiniteIndicator;
    
    [self.profileTable addInfiniteScrollWithHandler:^(UITableView* tableView) {
        self.displayItemCount += 2;
        self.displayItemCount = MIN(self.locationArray.count,self.displayItemCount);
        [self.infiniteIndicator startAnimating];
        [tableView reloadData];
        [tableView finishInfiniteScroll];
    }];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    if(!self.mode)
    {
        
        [self.tabBarController.tabBar setHidden:NO];
        
    }
    else
    {
        [self.tabBarController.tabBar setHidden:YES];
        
    }
    [self.profileTopBar setHeaderStyle:!self.mode title:@"" rightBtnHidden:self.mode];
    [self.refreshControl beginRefreshing];
    
    [self updateData];
    
}

-(void) loadProfileImage:(NSString *) user_id
{
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=100&&height=100", user_id];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userImageURL]];
        if ( data != nil )
        {
            self.profileImage = [[UIImage alloc]init];
            self.profileImage = [UIImage imageWithData: data];
            [self.profileTable reloadData];
        }
    });
    
}

-(void) loadImage:(Location *)location
{
    NSString * url=[location.location_id stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    NSString *firstPicture = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@a", url];
    NSString *secondPicture = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@b", url];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: firstPicture]];
        if ( data !=nil )
        {
            [self.firstArray setObject:[UIImage imageWithData: data] forKey:location.location_id];
            
        }
        NSData * data2 = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: secondPicture]];
        if ( data2 != nil )
        {
            
            [self.secondArray setObject:[UIImage imageWithData: data2] forKey:location.location_id];
            
        }
        [self.profileTable reloadData];
    });
    
}

-(void) updateData
{
    self.kudoCount=0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(!self.mode)
    {
        self.current_user_id = [defaults objectForKey:@"user_id"];
        
    }
    self.firstArray=[[NSMutableDictionary alloc] init];
    self.secondArray=[[NSMutableDictionary alloc] init];
    self.dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[self.dynamoDBObjectMapper load:[User class] hashKey:self.current_user_id rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             self.profile_user=task.result;
             [self.profileTopBar setHeaderStyle:!self.mode title:self.profile_user.user_name rightBtnHidden:self.mode];
             
             [self loadProfileImage:self.profile_user.user_id];
             self.locationArray=[[NSMutableArray alloc]init];
             
             self.appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
             
             AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
             scanExpression.filterExpression = @"cleaner_id = :val";
             scanExpression.expressionAttributeValues = @{@":val":self.current_user_id};
             [[self.dynamoDBObjectMapper scan:[Location class]
                                   expression:scanExpression]
              continueWithBlock:^id(AWSTask *task) {
                  if (task.result) {
                      AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                      self.formattedCleansCount = [NSString stringWithFormat:@"%lu",(unsigned long)paginatedOutput.items.count];
                      for (Location *location in paginatedOutput.items)
                      {
                          if([location.isDirty isEqualToString:@"false"]) //cleaned
                          {
                              //Counting item count
                              [self.locationArray addObject:location];
                              
                              //Loading images for the location
                              [self loadImage:location];
                              
                              //Adding total kudo count
                              self.kudoCount+=location.kudos.count;
                              
                          }
                          
                      }
                      self.displayItemCount = MIN(self.locationArray.count,self.displayItemCount);
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if([self.locationArray count]>0)
                              self.locationArray = (NSMutableArray*)[self.locationArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                  double first = ((Location*)a).cleaned_date;
                                  double second = ((Location*)b).cleaned_date;
                                  return first<second;
                              }];
                          
                          [self.profileTable reloadData];
                          [self.refreshControl endRefreshing];
                          
                      });
                  }
                  
                  return nil;
              }];
             AWSDynamoDBScanExpression *scanExpression2 = [AWSDynamoDBScanExpression new];
             
             scanExpression2.filterExpression = @"founder_id = :val";
             scanExpression2.expressionAttributeValues = @{@":val":self.profile_user.user_id};
             [[self.dynamoDBObjectMapper scan:[Location class]
                                   expression:scanExpression2]
              continueWithBlock:^id(AWSTask *task) {
                  
                  if (task.result) {
                      AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                      self.formattedFindsCount = [NSString stringWithFormat:@"%lu",(unsigned long)paginatedOutput.items.count];
                      
                      [self.profileTable reloadData];
                  }
                  return nil;
              }];
             if(self.profile_user.followings)
                 self.appDelegate.followingArray=self.profile_user.followings;
             if(self.profile_user.followers)
                 self.appDelegate.followersArray=self.profile_user.followers;
             self.luser_location=[NSString stringWithFormat:@"%@, %@, %@",self.profile_user.location,self.profile_user.state,self.profile_user.country];
             
         }
         return nil;
     }];
    
}

-(void)followClicked:(UIButton*)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user= [defaults objectForKey:@"user_id"];
    User * currentuser=[self.appDelegate.userArray objectForKey:user];
    
    NSString * target_id=self.profile_user.user_id;
    User * targetuser=self.profile_user;
    
    
    NSMutableArray * followerArray=[[NSMutableArray alloc] init]; //Add current user to the follower list of the user on the table
    NSMutableArray * followingArray=[[NSMutableArray alloc] init];
    if(targetuser.followers!=nil)
        followerArray=targetuser.followers;
    
    if(currentuser.followings!=nil)
        followingArray=currentuser.followings;
    
    NSMutableDictionary *followerItem=[[NSMutableDictionary alloc]init];
    [followerItem setObject:user forKey:@"id"];
    double date =[[NSDate date]timeIntervalSince1970];
    NSNumber *dateObj = [[NSNumber alloc] initWithDouble:date];
    //NSString *dateString=[NSString stringWithFormat:@"%f",date];
    [followerItem setObject:dateObj forKey:@"time"];
    
    NSMutableDictionary *followingItem=[[NSMutableDictionary alloc]init];
    [followingItem setObject:target_id forKey:@"id"];
    [followingItem setObject:dateObj forKey:@"time"];
    
    bool selected=!sender.selected;
    
    //Updating current user followings
    
    if(followingArray!=nil)
    {
        NSMutableArray * removeArray=[[NSMutableArray alloc]init];
        for(NSDictionary *following in followingArray)
        {
            
            if([[following objectForKey:@"id"] isEqualToString:target_id])
            {
                [removeArray addObject:following];
            }
            
        }
        if([followingArray count]>0)
            [followingArray removeObjectsInArray:removeArray];
        //[followingArray removeObject:following];
    }
    if(selected)
    {
        [followingArray addObject:followingItem];
        
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
             if(![target_id isEqual:user])
             {
                 if(followerArray!=nil)
                 {
                     NSMutableArray * removeArray=[[NSMutableArray alloc]init];
                     for(NSDictionary *follower in followerArray)
                     {
                         if([[follower objectForKey:@"id"] isEqualToString:user])
                         {
                             [removeArray addObject:follower];
                             
                         }
                     }
                     [followerArray removeObjectsInArray:removeArray];
                     
                 }
                 
                 if(selected)
                     [followerArray addObject:followerItem];
                 
                 if([followerArray count]!=0)
                     targetuser.followers=[[NSMutableArray alloc] initWithArray:followerArray];
                 else
                     targetuser.followers=nil;
                 
                 [[dynamoDBObjectMapper save:targetuser configuration:updateMapperConfig]
                  continueWithBlock:^id(AWSTask *task) {
                      if (task.result) {
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self.appDelegate loadData];
                              sender.selected=!sender.selected;
                              sender.enabled=YES;
                              [self.profileTable reloadData];
                          });
                      }
                      
                      return nil;
                  }];
             }
             
         }
         
         return nil;
     }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount=0;
    if(section==0)
        rowCount=1;
    else if(section==1)
        rowCount=1;
    else
    {
        if([self.locationArray count]>0)
            rowCount=self.displayItemCount;
        else
            rowCount=0;
    }
    
    return rowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ProfileViewCell * cell=nil;
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            cell=[[UITableViewCell alloc]init];
            
            if(self.profile_user)
            {
                cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"profileViewCell"];
                if(self.profileImage)
                    [cell.userPhoto setImage:self.profileImage];
                
                [cell.user_name setText:self.profile_user.user_name ];
                [cell.user_quotes setText:self.profile_user.user_about];
                [cell.user_location setText:self.luser_location];
                [cell.user_email setText:self.profile_user.user_email];
                UITapGestureRecognizer *followingTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowing)];
                followingTap.numberOfTapsRequired=1;
                
                UITapGestureRecognizer *followersTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollower)];
                followersTap.numberOfTapsRequired=1;
                
                [cell.user_following addGestureRecognizer:followingTap];
                [cell.followingLabel addGestureRecognizer:followingTap];
                [cell.user_follows addGestureRecognizer:followersTap];
                [cell.followersLabel addGestureRecognizer:followersTap];
                [cell.btnFollow addTarget:self action:@selector(followClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.btnFollow.hidden=!self.mode;
                [cell.btnFollow setImage:[UIImage imageNamed:@"btnKudoSelect"] forState:UIControlStateNormal];
                [cell.btnFollow setImage:[UIImage imageNamed:@"btnKudoUnselect"] forState:UIControlStateSelected];
                if([AppDelegate isFollowing:self.profile_user])
                    cell.btnFollow.selected=YES;
                if(self.appDelegate.followingArray!=nil)
                    [cell.user_following setText:[NSString stringWithFormat:@"%lu",(unsigned long)[self.appDelegate.followingArray count]]];
                if(self.appDelegate.followersArray!=nil)
                    [cell.user_follows setText:[NSString stringWithFormat:@"%lu",(unsigned long)[self.appDelegate.followersArray count]]];
            }
        }
    }
    
    else if(indexPath.section==1)
    {
        if(indexPath.row==0)
        {
            if(self.profile_user)
            {
                cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"kudoCell"];
                [cell.user_cleans setTitle:self.formattedCleansCount forState:UIControlStateNormal];
                [cell.user_spotsfound setTitle:self.formattedFindsCount forState:UIControlStateNormal];
                [cell.user_kudos setTitle:[NSString stringWithFormat:@"%lu", (long)self.kudoCount] forState:UIControlStateNormal];
            }
        }
        
    }
    else if(indexPath.section>1)
    {
        if([self.locationArray count]>0)
        {
        if([self.locationArray objectAtIndex:indexPath.row])
        {
            cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"activityCell"];
            Location * location=[self.locationArray objectAtIndex:indexPath.row];
            NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@""];
            UIColor * color1 = [UIColor blackColor];
            UIColor * color2= [UIColor colorWithRed:(145/255.0) green:(145/255.0) blue:(145/255.0) alpha:1.0];
            NSDictionary * attributes1 = [NSDictionary dictionaryWithObject:color1 forKey:NSForegroundColorAttributeName];
            NSDictionary * attributes2 = [NSDictionary dictionaryWithObject:color2 forKey:NSForegroundColorAttributeName];
            if(self.profile_user.user_name!=nil)
            {
                NSAttributedString * nameStr = [[NSAttributedString alloc] initWithString:self.profile_user.user_name attributes:attributes1];
                [string appendAttributedString:nameStr];
            }
            
            NSAttributedString * middleStr = [[NSAttributedString alloc] initWithString:@" finished cleaning " attributes:attributes2];
            [string appendAttributedString:middleStr];
            
            if(location.location_name!=nil)
            {
                NSAttributedString * locationStr = [[NSAttributedString alloc] initWithString:location.location_name attributes:attributes1];
                [string appendAttributedString:locationStr];
            }
            [cell.comment setAttributedText:string];
            [cell.location setText: location.location_name];
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM dd, yyyy"];
            [cell.date setText:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:location.cleaned_date]]];
            [cell.kudoCount setText:[[NSString alloc]initWithFormat:@"%ld",(long)location.kudos.count]];
            if([self.firstArray objectForKey:location.location_id])
                [cell.beforePhoto setImage:[self.firstArray objectForKey:location.location_id]];
            if([self.secondArray objectForKey:location.location_id])
                [cell.afterPhoto setImage:[self.secondArray objectForKey:location.location_id]];
        }
        }
        
    }
    if(!cell){
        cell=[[UITableViewCell alloc]init];
    }
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma ProfileTopBarVCDelegate Implementation

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self performSegueWithIdentifier:@"ProfileVC2SettingVC" sender:nil];
}

-(void)showFollowing
{
    [self performSegueWithIdentifier:@"showFollowing" sender:self];
}

-(void)showFollower
{
    [self performSegueWithIdentifier:@"showFollowers" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    FollowVC *followVC=(FollowVC*)segue.destinationViewController;
    if([segue.identifier isEqual:@"showFollowing"])
    {
        followVC.displayIndex=0;
        [followVC.followSegment setSelectedSegmentIndex:0];
    }
    else if([segue.identifier isEqual:@"showFollowers"])
    {
        followVC.displayIndex=1;
        [followVC.followSegment setSelectedSegmentIndex:1];
    }
}


@end
