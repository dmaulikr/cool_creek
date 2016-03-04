#import "ProfileVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "User.h"
#import "Location.h"
#import "ProfileViewCell.h"
#import "FollowVC.h"
#import "AppDelegate.h"
@implementation ProfileVC

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.kudoCount=0;
    self.locationArray=[[NSMutableArray alloc]init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.luser_id = [defaults objectForKey:@"user_id"];
    self.luser_name = [defaults objectForKey:@"user_name"];
    self.luser_email = [defaults objectForKey:@"user_email"];
    self.luser_location = [defaults objectForKey:@"user_location"];
    self.luser_about = [defaults objectForKey:@"user_about"];
    self.fb_username = [defaults objectForKey:@"username"];
   
    [self.profileTopBar setHeaderStyle:YES title:self.luser_name rightBtnHidden:NO];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.filterExpression = @"cleaner_id = :val";
    self.dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    scanExpression.expressionAttributeValues = @{@":val":self.luser_id};
    self.appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [[self.dynamoDBObjectMapper scan:[Location class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             self.formattedCleansCount = [NSString stringWithFormat:@"%lu",(unsigned long)paginatedOutput.items.count];
             for (Location *location in paginatedOutput.items)
             {
                 [self.locationArray addObject:location];
                 self.kudoCount+=location.kudos.count;
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.profileTable reloadData];
                 
             });
             
         }
         
         return nil;
     }];
   
    self.profileTable.estimatedRowHeight = 323.f;
    self.profileTable.rowHeight = UITableViewAutomaticDimension;

}

-(void) viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount;
    rowCount=[self.locationArray count]+2;
    return rowCount;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height=223;
    if(indexPath.row==0)
        height=230;
    else if (indexPath.row==1)
        height=65;
    else
        height=335;
    return height;
}*/

-(void) loadData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             for (User *user in paginatedOutput.items)
             {
                 [self.appDelegate.userArray setObject:user forKey:user.user_id];
                 if([user.user_id isEqualToString:user_id])
                 {
                     self.appDelegate.followingArray=user.followings;
                     self.appDelegate.followersArray=user.followers;
                 }
             }
             
             
         }
         return nil;
     }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ProfileViewCell * cell=nil;
    
    if(indexPath.row==0)
    {
        cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"profileViewCell"];
        NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", self.luser_id];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userImageURL]];
            if ( data == nil )
                return;
            // WARNING: is the cell still using the same data by this point??
            [cell.userPhoto setImage:[UIImage imageWithData: data]];
        });
        
        [cell.user_name setText:self.luser_name ];
        [cell.user_quotes setText:self.luser_about];
        [cell.user_location setText:self.luser_location];
        [cell.user_email setText:self.luser_email];
        UITapGestureRecognizer *followingTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowing)];
        followingTap.numberOfTapsRequired=1;
    
        UITapGestureRecognizer *followersTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollower)];
        followersTap.numberOfTapsRequired=1;
        
        [cell.user_following addGestureRecognizer:followingTap];
        [cell.followingLabel addGestureRecognizer:followingTap];
        [cell.user_follows addGestureRecognizer:followersTap];
        [cell.followersLabel addGestureRecognizer:followersTap];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadData];
            [cell.user_following setText:[NSString stringWithFormat:@"%d",[self.appDelegate.followingArray count]]];
            [cell.user_follows setText:[NSString stringWithFormat:@"%d",[self.appDelegate.followersArray count]]];
            
        });
        NSLog(@"%@, %@, %@, %@", self.luser_name, self.luser_about, self.luser_location, self.luser_email);
        
    }
    else if(indexPath.row==1)
    {
        cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"kudoCell"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.user_cleans setTitle:self.formattedCleansCount forState:UIControlStateNormal];
            
        });
        
        [cell.user_kudos setTitle:[NSString stringWithFormat:@"%lu", (long)self.kudoCount] forState:UIControlStateNormal];
        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        
        scanExpression.filterExpression = @"founder_id = :val";
        scanExpression.expressionAttributeValues = @{@":val":self.luser_id};
        [[self.dynamoDBObjectMapper scan:[Location class]
                              expression:scanExpression]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
             }
             if (task.exception) {
                 NSLog(@"The request failed. Exception: [%@]", task.exception);
             }
             if (task.result) {
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 NSString *formattedFindsCount = [NSString stringWithFormat:@"%lu",(unsigned long)paginatedOutput.items.count];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [cell.user_spotsfound setTitle:formattedFindsCount forState:UIControlStateNormal];
                 });
             }
             return nil;
         }];
        

    }
    else
    {
        cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"activityCell"];
        Location * location=[self.locationArray objectAtIndex:indexPath.row-2];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@""];
        UIColor * color1 = [UIColor blackColor];
        UIColor * color2= [UIColor colorWithRed:(145/255.0) green:(145/255.0) blue:(145/255.0) alpha:1.0];
        NSDictionary * attributes1 = [NSDictionary dictionaryWithObject:color1 forKey:NSForegroundColorAttributeName];
        NSDictionary * attributes2 = [NSDictionary dictionaryWithObject:color2 forKey:NSForegroundColorAttributeName];
        
        NSAttributedString * nameStr = [[NSAttributedString alloc] initWithString:self.luser_name attributes:attributes1];
        [string appendAttributedString:nameStr];
        NSAttributedString * middleStr = [[NSAttributedString alloc] initWithString:@" finished cleaning " attributes:attributes2];
        [string appendAttributedString:middleStr];
        NSAttributedString * locationStr = [[NSAttributedString alloc] initWithString:location.location_name attributes:attributes1];
        [string appendAttributedString:locationStr];
        
        [cell.comment setAttributedText:string];
        [cell.location setText: location.location_name];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy"];
        [cell.date setText:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:location.cleaned_date]]];
        [cell.kudoCount setText:[[NSString alloc]initWithFormat:@"%ld",(long)location.kudos.count]];
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
        downloadRequest.bucket = @"cleanthecreeks";
        NSString * key=[location.location_id stringByAppendingString:@"a"];
        NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
        NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
        downloadRequest.key = key;
        downloadRequest.downloadingFileURL = downloadingFileURL;
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task2) {
            if (task2.result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.beforePhoto setImage:[UIImage imageWithContentsOfFile:downloadingFilePath]];
                });
            }
            return nil;
        }];
        
        NSString * afterkey=[location.location_id stringByAppendingString:@"b"];
        NSString * afterPath = [NSTemporaryDirectory() stringByAppendingPathComponent:afterkey];
        NSURL * afterurl = [NSURL fileURLWithPath:afterPath];
        AWSS3TransferManagerDownloadRequest *afterdownloadRequest = [AWSS3TransferManagerDownloadRequest new];
        afterdownloadRequest.bucket = @"cleanthecreeks";
        afterdownloadRequest.key = afterkey;
        afterdownloadRequest.downloadingFileURL = afterurl;
        AWSS3TransferManager *aftertransferManager = [AWSS3TransferManager defaultS3TransferManager];
        [[aftertransferManager download:afterdownloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task2) {
            if (task2.result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.afterPhoto setImage:[UIImage imageWithContentsOfFile:afterPath]];
                });
                
            }
            return nil;
        }];
        
    }
    if(!cell){
        cell=(ProfileViewCell*)[[UITableViewCell alloc]init];
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
