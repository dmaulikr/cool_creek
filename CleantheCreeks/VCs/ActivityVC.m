#import "ActivityVC.h"
#import "CleaningCommentCell.h"
#import "CleaningDoneCell.h"
#import "Location.h"
#import "User.h"
#import "Activity.h"
#import "ActivityPhotoDetailsVC.h"
#import <CoreLocation/CoreLocation.h>

@interface ActivityVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@end

@implementation ActivityVC

-(void) viewDidLoad
{
    [super viewDidLoad];
     self.displayItemCount=10;
    [self.profileTopBar setHeaderStyle:YES title:@"ACTIVITY" rightBtnHidden:YES];
    // Do any additional setup after loading the view.
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tv addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    [self updateData];
    
    self.tv.estimatedRowHeight = 65.f;
    self.tv.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) loadImage:(NSString*)activty
{
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", activty];
    
    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userImageURL]];
    if ( data == nil )
        return;
    [self.imageArray setObject:[UIImage imageWithData: data] forKey:activty];
    CGPoint offset = CGPointMake(self.tv.contentOffset.x,self.tv.contentOffset.y);
    [self.tv reloadData];
    [self.tv setContentOffset:offset];
    
}
#pragma UITableView Delegate Implementation
-(void) updateData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"]; //Current logged in user
    self.userArray=[[NSMutableDictionary alloc]init];
    
    self.activityArray=[[NSMutableArray alloc]init];
    self.imageArray=[[NSMutableDictionary alloc]init];
    [self.userArray removeAllObjects];
    [self.activityArray removeAllObjects];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (User *user in paginatedOutput.items)
             {
                 [self.userArray setObject:user forKey:user.user_id];
                 dispatch_async(dispatch_get_global_queue(0,0), ^{
                     [self loadImage:user.user_id];
                     
                     
                 });
             }
             if([self.userArray count]>0)
             {
             User * current_user = [self.userArray objectForKey:user_id];
             AWSDynamoDBObjectMapper *dynamoDBObjectMapper2 = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
             AWSDynamoDBScanExpression *scanExpression2 = [AWSDynamoDBScanExpression new];
             [[dynamoDBObjectMapper2 scan:[Location class] expression:scanExpression2] continueWithBlock:^id(AWSTask *task) {
                 if (task.result) {
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     
                     for(NSDictionary * item in current_user.followers)
                     {
                         NSString * follower_id=[item objectForKey:@"id"];
                         NSString * following_date=[item objectForKey:@"time"];
                         // Adding finders to the activity array
                         Activity *activity=[[Activity alloc]init];
                         activity.activity_id = follower_id;
                         activity.activity_time=[following_date doubleValue];
                         activity.activity_type = @"follow";
                         [self.activityArray addObject:activity];
                     }
                     for (Location *location in paginatedOutput.items) {
                         for(NSDictionary * iterator in current_user.followings)
                         {
                             NSString * person_id=[iterator objectForKey:@"id"];
                             
                             // Adding finders to the activity array
                             if([location.founder_id isEqualToString:person_id])
                             {
                                 Activity *activity=[[Activity alloc]init];
                                 activity.activity_id = location.founder_id;
                                 activity.activity_time=location.found_date;
                                 activity.activity_type = @"find";
                                 activity.activity_location = location;
                                 
                                 [self.activityArray addObject:activity];
                             }
                             
                             //Adding following cleaners to the activity array
                             if([location.cleaner_id isEqualToString:person_id])
                             {
                                 Activity *activity=[[Activity alloc]init];
                                 activity.activity_id = location.cleaner_id;
                                 activity.activity_time=location.cleaned_date;
                                 activity.activity_type = @"clean";
                                 activity.activity_location = location;
                                 activity.kudo_count=[location.kudos count];
                                 if(location.kudos!=nil)
                                 {
                                     for(NSDictionary *kudo_gaver in location.kudos)
                                     {
                                         if([[kudo_gaver objectForKey:@"id"] isEqualToString:user_id])
                                         {
                                             activity.kudo_assigned=YES;
                                             break;
                                         }
                                     }
                                 }
                                 [self.activityArray addObject:activity];
                             }
                         }
                         if([location.founder_id isEqualToString:user_id])
                         {
                             Activity *activity=[[Activity alloc]init];
                             activity.activity_id = location.cleaner_id;
                             activity.activity_time=location.cleaned_date;
                             activity.activity_type = @"clean";
                             activity.activity_location = location;
                             activity.kudo_count=[location.kudos count];
                             if(location.kudos!=nil)
                             {
                                 for(NSDictionary *kudo_gaver in location.kudos)
                                 {
                                     if([[kudo_gaver objectForKey:@"id"] isEqualToString:user_id])
                                     {
                                         activity.kudo_assigned=YES;
                                         break;
                                     }
                                 }
                             }
                             [self.activityArray addObject:activity];
                         }

                         if([location.founder_id isEqualToString:user_id])
                         {
                             // Adding commenters
                             for(NSDictionary * item in location.comments)
                             {
                                 NSString * commenter_id=[item objectForKey:@"id"];
                                 NSString * comment_date=[item objectForKey:@"time"];
                                 Activity *activity=[[Activity alloc]init];
                                 activity.activity_id=commenter_id;
                                 activity.activity_time = [comment_date doubleValue];
                                 activity.activity_type = @"clean";
                                 activity.activity_location = location;
                                 [self.activityArray addObject:activity];
                             }
                             
                         }
                         // Adding kudos
                         if([location.cleaner_id isEqualToString:user_id])
                         {
                             for(NSDictionary * iterator in location.kudos)
                             {
                                 NSString * kudo_person_id=[iterator objectForKey:@"id"];
                                 NSString * kudo_date=[iterator objectForKey:@"time"];
                                 // Adding finders to the activity array
                                 Activity *activity=[[Activity alloc]init];
                                 activity.activity_id = kudo_person_id;
                                 activity.activity_time=[kudo_date doubleValue];
                                 activity.activity_type = @"kudo";
                             
                                 [self.activityArray addObject:activity];

                             }
                         }
                         // Adding followings
                         
                     }
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.activityArray = (NSMutableArray*)[self.activityArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                             double first = ((Activity*)a).activity_time;
                             double second = ((Activity*)b).activity_time;
                             return first<second;
                         }];
                         CGPoint offset = CGPointMake(self.tv.contentOffset.x,self.tv.contentOffset.y);
                         [self.tv reloadData];
                         [self.tv setContentOffset:offset];
                         [self.refreshControl endRefreshing];
                         
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
    if(self.activityArray!=nil)
    {
        return [self.activityArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    UITableViewCell *cell;
    
    if([self.activityArray count]>0)
    {
        Activity * activity = [self.activityArray objectAtIndex:row];
        
        User * user=[self.userArray objectForKey:activity.activity_id];
        
        
        if([activity.activity_type isEqualToString: @"clean"])
        {
            cell = (CleaningDoneCell*)[tableView dequeueReusableCellWithIdentifier:@"CleaningDoneCell" forIndexPath:indexPath];
            
            [((CleaningDoneCell*)cell).lblContent setAttributedText:[self generateString:user.user_name content:@" has finished cleaning " location:activity.activity_location.location_name]];
            [((CleaningDoneCell*)cell).activityHours setText:[self timeDifference:activity.activity_time]];
            [((CleaningDoneCell*)cell).kudoCounter setTitle:[[NSString alloc] initWithFormat:@"%d Kudos",activity.kudo_count] forState:UIControlStateNormal];
            if([self.imageArray objectForKey:activity.activity_id]!=nil)
                [((CleaningDoneCell*)cell).profileAvatar setImage: [self.imageArray objectForKey:activity.activity_id]];
            if(activity.kudo_assigned)
               [((CleaningDoneCell*)cell).btnKudos setTitle:@"You Gave Kudos" forState:UIControlStateNormal];
            else
                [((CleaningDoneCell*)cell).btnKudos setTitle:@"Give Kudos" forState:UIControlStateNormal];
            ((CleaningDoneCell*)cell).btnKudos.tag = indexPath.row;
            [((CleaningDoneCell*)cell).btnKudos addTarget:self action:@selector(kudoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
              
        }
        else
        {
            cell = (CleaningCommentCell*)[tableView dequeueReusableCellWithIdentifier:@"CleaningCommentCell" forIndexPath:indexPath];
            if([activity.activity_type isEqualToString: @"find"])
            {
                [((CleaningCommentCell*)cell).lblContent setAttributedText:[self generateString:user.user_name content:@" found a new dirty spot " location:activity.activity_location.location_name]];
            }
            else if([activity.activity_type isEqualToString: @"comment"])
            {
                [((CleaningCommentCell*)cell).lblContent setAttributedText:[self generateString:user.user_name content:@" commented on your clean up location " location:@""]];
            }
            else if([activity.activity_type isEqualToString: @"kudo"])
            {
                [((CleaningCommentCell*)cell).lblContent setAttributedText:[self generateString:user.user_name content:@" gave you Kudos \n" location:@""]];
            }
            else if([activity.activity_type isEqualToString: @"follow"])
            {
                [((CleaningCommentCell*)cell).lblContent setAttributedText:[self generateString:user.user_name content:@" started follwing you" location:@""]];
            }
            
            [((CleaningCommentCell*)cell).activityHours setText:[self timeDifference:activity.activity_time]];
            if([self.imageArray objectForKey:activity.activity_id]!=nil)
                [((CleaningCommentCell*)cell).profileAvatar setImage: [self.imageArray objectForKey:user.user_id]];
        }
    }
    if (cell == nil){
        cell = [[UITableViewCell alloc] init];
    }
    return cell;
}

-(void)kudoBtnClicked:(UIButton*)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];

    if([self.activityArray count]>0)
    {
    Activity * activity=[self.activityArray objectAtIndex:sender.tag];
    //Activity * newActivity=activity;
    Location * location=activity.activity_location;
    
    NSMutableArray * kudoArray=[[NSMutableArray alloc] init];
    if(location.kudos!=nil)
        kudoArray=location.kudos;
    NSMutableDictionary *kudoItem=[[NSMutableDictionary alloc]init];
    [kudoItem setObject:user_id forKey:@"id"];
    double date =[[NSDate date]timeIntervalSince1970];
    NSString *dateString=[NSString stringWithFormat:@"%f",date];
    [kudoItem setObject:dateString forKey:@"time"];

    if(!activity.kudo_assigned)
    {
        [kudoArray addObject:kudoItem];
    }
    else
    {
        if(kudoArray!=nil)
        {
            for(NSDictionary *kudo_gaver in kudoArray)
            {
                if([[kudo_gaver objectForKey:@"id"] isEqualToString:user_id])
                {
                    [kudoArray removeObject:kudo_gaver];
                    
                }
            }
        }
    }
    if([kudoArray count]!=0)
        location.kudos=[[NSMutableArray alloc] initWithArray:kudoArray];
    else
        location.kudos=nil;
    //[self.activityArray replaceObjectAtIndex:_selectedIndex withObject:newActivity];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
    updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
    
    [[dynamoDBObjectMapper save:location configuration:updateMapperConfig]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             [self updateData];
         }
         return nil;
     }];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.activityArray count]>0)
    {
        Activity * activity = [self.activityArray objectAtIndex:indexPath.row];
        if([activity.activity_type isEqualToString: @"clean"] || [activity.activity_type isEqualToString: @"find"] || [activity.activity_type isEqualToString: @"comment"])
        {
            [self performSegueWithIdentifier:@"ActivityVC2ActivityPhotoDetailVC" sender:nil];
        
        }
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if([self.activityArray count]>0)
    {
        NSIndexPath * selectedPath= [self.tv indexPathForSelectedRow];
        Activity * activity=[self.activityArray objectAtIndex:selectedPath.row];
        
        if([segue.identifier isEqualToString:@"ActivityVC2ActivityPhotoDetailVC"])
        {
            ActivityPhotoDetailsVC* vc = (ActivityPhotoDetailsVC*)segue.destinationViewController;
            vc.location = [[Location alloc]init];
            vc.location = activity.activity_location;
            vc.cleaned=NO;
            if([activity.activity_type isEqualToString: @"clean"])
            {
                vc.cleaned=YES;
            }
        
        }
        
    }
}

#pragma ProfileTopBarVCDelegate Implementation

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

- (NSMutableAttributedString *)generateString:(NSString*)name content:(NSString*)content location:(NSString*) location
{
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@""];
    UIColor * color1 = [UIColor blackColor];
    UIColor * color2= [UIColor colorWithRed:(145/255.0) green:(145/255.0) blue:(145/255.0) alpha:1.0];
    NSDictionary * attributes1 = [NSDictionary dictionaryWithObject:color1 forKey:NSForegroundColorAttributeName];
    NSDictionary * attributes2 = [NSDictionary dictionaryWithObject:color2 forKey:NSForegroundColorAttributeName];
    if(name!=nil)
    {
        NSAttributedString * nameStr = [[NSAttributedString alloc] initWithString:name attributes:attributes1];
        [string appendAttributedString:nameStr];
    }
    if(content!=nil)
    {
        NSAttributedString * middleStr = [[NSAttributedString alloc] initWithString:content attributes:attributes2];
        [string appendAttributedString:middleStr];
    }
    if(location!=nil)
    {
        NSAttributedString * locationStr = [[NSAttributedString alloc] initWithString:location attributes:attributes1];
        [string appendAttributedString:locationStr];
    }
    return string;
}

-(NSString *) timeDifference: (double)activityDate
{
    NSDate *date =[[NSDate alloc]initWithTimeIntervalSince1970:activityDate];
    NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:date];
    NSString * timedifference=[[NSString alloc]init];
    int numberOfDays = secondsBetween / 86400;
    if (numberOfDays == 0)
    {
        int numberOfHours=secondsBetween/3600;
        if(numberOfHours>0)
            timedifference=[[NSString alloc]initWithFormat:@"%d hours ago", numberOfHours];
        else
        {
            int numberOfMins=secondsBetween/60;
            timedifference=[[NSString alloc]initWithFormat:@"%d mins ago", numberOfMins];
        }
    }
    else if(numberOfDays>30)
    {
        timedifference=@"More than 1 month ago";
    }
    else if(numberOfDays==1)
    {
        timedifference=[[NSString alloc]initWithFormat:@"%d day ago", numberOfDays];
    }
    else
    {
        timedifference=[[NSString alloc]initWithFormat:@"%d days ago", numberOfDays];
    }
    return timedifference;
}

@end
