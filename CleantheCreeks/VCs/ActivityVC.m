#import "ActivityVC.h"
#import "CleaningCommentCell.h"
#import "CleaningDoneCell.h"
#import "User.h"
#import "Activity.h"
#import "ActivityPhotoDetailsVC.h"
#import "KudosVC.h"
#import <CoreLocation/CoreLocation.h>
#import <UIScrollView+InfiniteScroll.h>
#import "CustomInfiniteIndicator.h"
#import "ProfileVC.h"
@interface ActivityVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@property (nonatomic,strong) CustomInfiniteIndicator *infiniteIndicator;
@end

@implementation ActivityVC



-(void) viewDidLoad
{
    [super viewDidLoad];
    self.displayItemCount=8;
    
    [self.profileTopBar setHeaderStyle:YES title:@"ACTIVITY" rightBtnHidden:YES];
    // Do any additional setup after loading the view.
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tv addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [self updateData];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.current_user_id = [self.defaults objectForKey:@"user_id"];
    self.tv.estimatedRowHeight = 65.f;
    self.tv.rowHeight = UITableViewAutomaticDimension;
    
    self.tv.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    self.infiniteIndicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    self.tv.infiniteScrollIndicatorView = self.infiniteIndicator;
    self.appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self.tv addInfiniteScrollWithHandler:^(UITableView* tableView) {
        self.displayItemCount+=5;
        self.displayItemCount = MIN(self.activityArray.count,self.displayItemCount);
        [self.infiniteIndicator startAnimating];
        [tableView reloadData];
        [tableView finishInfiniteScroll];
    }];
        
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ActivityVC"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    self.appDelegate.notificationCount=0;
    [[[[[self tabBarController] tabBar] items]
      objectAtIndex:2] setBadgeValue:nil];
    [self.refreshControl beginRefreshing];
    [self updateCell];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableView Delegate Implementation
-(void) updateData
{
    self.appDelegate.userArray=[[NSMutableDictionary alloc]init];
    self.imageArray=[[NSMutableDictionary alloc]init];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [self networkError];
             [self.refreshControl endRefreshing];
         }
         if (task.exception) {
             [self networkError];
             [self.refreshControl endRefreshing];
         }
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             dispatch_async(dispatch_get_main_queue(), ^{
                 for (User *user in paginatedOutput.items)
                 {
                     [self.appDelegate.userArray setObject:user forKey:user.user_id];
                     //[self loadImage:user.user_id];
                 }
                 [self updateCell];
                 
             });
         }
         return nil;
     }];
}

-(void) updateCell
{
    self.activityArray=[[NSMutableArray alloc]init];
    if([self.appDelegate.userArray count]>0)
    {
        User * current_user = [self.appDelegate.userArray objectForKey:self.current_user_id];
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper2 = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        AWSDynamoDBScanExpression *scanExpression2 = [AWSDynamoDBScanExpression new];
        [[dynamoDBObjectMapper2 scan:[Location class] expression:scanExpression2] continueWithBlock:^id(AWSTask *task) {
            if (task.error) {
                [self networkError];
                
            }
            if (task.exception) {
                [self networkError];
            }
            if (task.result) {
                AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                //My followers
                for(NSDictionary * item in current_user.followers)
                {
                    NSString * follower_id=[item objectForKey:@"id"];
                    NSNumber * following_date=[item objectForKey:@"time"];
                    // Adding finders to the activity array
                    Activity *activity=[[Activity alloc]init];
                    activity.activity_id = follower_id;
                    activity.activity_time=[following_date doubleValue];
                    activity.activity_type = @"follow";
                    [self.activityArray addObject:activity];
                }
                
                //Adding find and clean activites for following users
                for (Location *location in paginatedOutput.items) {
                    CLLocation*exitingLocation=[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
                    CLLocationDistance distance=[exitingLocation distanceFromLocation:self.appDelegate.currentLocation];
                    distance=distance/1000.0;
                    
                    if(distance>=100.00)
                    {
                        for(NSDictionary * iterator in current_user.followings)
                        {
                            NSString * person_id=[iterator objectForKey:@"id"];
                            
                            //Adding following cleaners to the activity array
                            if([location.cleaner_id isEqualToString:person_id] && ![location.founder_id isEqualToString:self.current_user_id]&&[location.isDirty isEqualToString:@"false"])
                            {
                                Activity *activity=[[Activity alloc]init];
                                activity.activity_id = location.cleaner_id;
                                activity.activity_time=location.cleaned_date;
                                activity.activity_type = @"clean";
                                activity.activity_location = location;
                                activity.kudo_count = [location.kudos count];
                                if(location.kudos!=nil)
                                {
                                    for(NSDictionary *kudo_gaver in location.kudos)
                                    {
                                        if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.current_user_id])
                                        {
                                            activity.kudo_assigned=YES;
                                            break;
                                        }
                                    }
                                }
                                [self.activityArray addObject:activity];
                            }
                            // Adding finders to the activity array
                            else if([location.founder_id isEqualToString:person_id] && ![location.founder_id isEqualToString:self.current_user_id] )
                            {
                                Activity *activity=[[Activity alloc]init];
                                activity.activity_id = location.founder_id;
                                activity.activity_time=location.found_date;
                                activity.activity_type = @"find";
                                activity.activity_location = location;
                                
                                [self.activityArray addObject:activity];
                            }
                        }
                        
                        // Showing cleaned activities on my found areas
                        if([location.founder_id isEqualToString:self.current_user_id] && [location.isDirty isEqualToString:@"false"])
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
                                    if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.current_user_id])
                                    {
                                        activity.kudo_assigned=YES;
                                        break;
                                    }
                                }
                            }
                            [self.activityArray addObject:activity];
                        }
                        else if([location.founder_id isEqualToString:self.current_user_id])
                            {
                                Activity *activity=[[Activity alloc]init];
                                activity.activity_id = location.founder_id;
                                activity.activity_time=location.found_date;
                                activity.activity_type = @"find";
                                activity.activity_location = location;
                                
                                [self.activityArray addObject:activity];
                            }
                    }
                    
                    else //within 100kms
                    {
                       
                        // Showing cleaned activities witin 100kms
                        if([location.isDirty isEqualToString:@"false"])
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
                                    if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.current_user_id])
                                    {
                                        activity.kudo_assigned=YES;
                                        break;
                                    }
                                }
                            }
                            [self.activityArray addObject:activity];
                        }
                        else  //Showing all found activities
                        {
                            Activity *activity=[[Activity alloc]init];
                            activity.activity_id = location.founder_id;
                            activity.activity_time=location.found_date;
                            activity.activity_type = @"find";
                            activity.activity_location = location;
                            
                            [self.activityArray addObject:activity];
                        }
                    }
                    
                    
                    // Adding commenters
                    if([location.founder_id isEqualToString:self.current_user_id])
                    {
                        for(NSDictionary * item in location.comments)
                        {
                            NSString * commenter_id=[item objectForKey:@"id"];
                            NSString * comment_date=[item objectForKey:@"time"];
                            Activity *activity=[[Activity alloc]init];
                            activity.activity_id=commenter_id;
                            activity.activity_time = [comment_date doubleValue];
                            activity.activity_type = @"comment";
                            activity.activity_location = location;
                            [self.activityArray addObject:activity];
                        }
                        
                    }
                    
                    // Adding kudos
                    if([location.cleaner_id isEqualToString:self.current_user_id])
                    {
                        for(NSDictionary * iterator in location.kudos)
                        {
                            NSString * kudo_person_id=[iterator objectForKey:@"id"];
                            NSString * kudo_date=[iterator objectForKey:@"time"];
                            // Adding finders to the activity array
                            Activity *activity=[[Activity alloc]init];
                            activity.activity_id = kudo_person_id;
                            activity.activity_time = [kudo_date doubleValue];
                            activity.activity_type = @"kudo";
                            
                            [self.activityArray addObject:activity];
                            
                        }
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.activityArray = (NSMutableArray*)[self.activityArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                        double first = ((Activity*)a).activity_time;
                        double second = ((Activity*)b).activity_time;
                        return first<second;
                    }];
                    self.displayItemCount=MIN(self.activityArray.count,self.displayItemCount);
                    [self.tv reloadData];
                    [self.refreshControl endRefreshing];
                    
                });
            }
            
            return nil;
        }];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height=0;
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
            height=5;
            
    }
    else if(indexPath.section>0)
    {
        height=tableView.rowHeight;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0)
        return 1;
    else if(section==1)
    {
        if([self.activityArray count]>0)
            return self.displayItemCount;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    UITableViewCell *cell;
    if(indexPath.section == 0)
        cell=[tableView dequeueReusableCellWithIdentifier:@"Separator" forIndexPath:indexPath];
    else if(indexPath.section == 1)
    {
        if([self.activityArray count]>0)
        {
            Activity * activity = [self.activityArray objectAtIndex:row];
            User * user=[self.appDelegate.userArray objectForKey:activity.activity_id];
            UITapGestureRecognizer *followTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProfile:)];
            followTap.numberOfTapsRequired=1;
            if([activity.activity_type isEqualToString: @"clean"])
            {
                cell = (CleaningDoneCell*)[tableView dequeueReusableCellWithIdentifier:@"CleaningDoneCell" forIndexPath:indexPath];
                
                [((CleaningDoneCell*)cell).lblContent setAttributedText:[self generateString:user.user_name content:@" has finished cleaning " location:activity.activity_location.location_name]];
                [((CleaningDoneCell*)cell).activityHours setText:[self timeDifference:activity.activity_time]];
                [((CleaningDoneCell*)cell).kudoCounter setTitle:[[NSString alloc] initWithFormat:@"%d Kudos",activity.kudo_count] forState:UIControlStateNormal];
                if([self.imageArray objectForKey:activity.activity_id]!=nil)
                {
                    [((CleaningDoneCell*)cell).profileAvatar setImage: [self.imageArray objectForKey:user.user_id]];
                }
                else
                {
                    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", activity.activity_id];
                    NSURL *url = [NSURL URLWithString:userImageURL];
                    
                    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    {
                                        if(image)
                                            [self.imageArray setObject:image forKey:user.user_id];
                                    }
                                    if(cell)
                                        [((CleaningDoneCell*)cell).profileAvatar setImage: image];
                                });
                            }
                        }
                    }];
                    [task resume];
                }
                
                [((CleaningDoneCell*)cell).btnKudos setTitle:@"You Gave Kudos" forState:UIControlStateSelected];
                [((CleaningDoneCell*)cell).btnKudos setImage:[UIImage imageNamed:@"IconKudos3"] forState:UIControlStateSelected];
                [((CleaningDoneCell*)cell).btnKudos setTitle:@"Give Kudos" forState:UIControlStateNormal];
                [((CleaningDoneCell*)cell).btnKudos setImage:[UIImage imageNamed:@"IconKudos2"] forState:UIControlStateNormal];
                
                ((CleaningDoneCell*)cell).btnKudos.selected=activity.kudo_assigned;
                
                ((CleaningDoneCell*)cell).btnKudos.tag = indexPath.row;
                ((CleaningDoneCell*)cell).btnKudoCount.tag = indexPath.row;
                [((CleaningDoneCell*)cell).btnKudoCount addTarget:self action:@selector(kudoCountClicked:) forControlEvents:UIControlEventTouchUpInside];
                ((CleaningDoneCell*)cell).parentVC = self;
                [((CleaningDoneCell*)cell).profileAvatar addGestureRecognizer:followTap];
                ((CleaningDoneCell*)cell).profileAvatar.userInteractionEnabled=YES;
                ((CleaningDoneCell*)cell).profileAvatar.tag = indexPath.row;
                [((CleaningDoneCell*)cell).activityHours setText:[self timeDifference:activity.activity_time]];
                
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
                    [((CleaningCommentCell*)cell).lblContent setAttributedText:[self generateString:user.user_name content:@" started follwing you\n" location:@""]];
                }
                
                [((CleaningCommentCell*)cell).profileAvatar addGestureRecognizer:followTap];
                ((CleaningCommentCell*)cell).profileAvatar.userInteractionEnabled=YES;
                ((CleaningCommentCell*)cell).profileAvatar.tag = indexPath.row;
                [((CleaningCommentCell*)cell).activityHours setText:[self timeDifference:activity.activity_time]];
                if([self.imageArray objectForKey:activity.activity_id]!=nil)
                {
                    [((CleaningCommentCell*)cell).profileAvatar setImage: [self.imageArray objectForKey:user.user_id]];
                }
                else
                {
                    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", activity.activity_id];
                    NSURL *url = [NSURL URLWithString:userImageURL];
                    
                    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    {
                                        [self.imageArray setObject:image forKey:user.user_id];
                                    }
                                    if(cell)
                                        [((CleaningCommentCell*)cell).profileAvatar setImage: image];
                                });
                            }
                        }
                    }];
                    [task resume];
                }
            }
        }
    }
    if (cell == nil){
        cell = [[UITableViewCell alloc] init];
    }
    return cell;
}

-(void) showProfile:(id)sender
{
    
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    self.selectedImgIndex = gesture.view.tag;
    NSLog(@"%u",self.selectedImgIndex);
    Activity * selectedActivity = [self.activityArray objectAtIndex:self.selectedImgIndex];
    if(![selectedActivity.activity_id isEqualToString:self.current_user_id])
    {
        
        [self performSegueWithIdentifier:@"showProfile" sender:self];
    }
}

-(void) kudoCountClicked:(UIButton*)sender
{
    Activity * activity=[self.activityArray objectAtIndex:sender.tag];
    self.selectedLocation=[[Location alloc]init];
    self.selectedLocation=activity.activity_location;
    [self performSegueWithIdentifier:@"showKudos" sender:nil];
}

-(void) giveKudoWithLocation:(Location*) location assigned:(bool)assigned
{
    
    NSMutableArray * kudoArray=[[NSMutableArray alloc] init];
    if(location.kudos!=nil)
        kudoArray=location.kudos;
    NSMutableDictionary *kudoItem=[[NSMutableDictionary alloc]init];
    [kudoItem setObject:self.current_user_id forKey:@"id"];
    double date =[[NSDate date]timeIntervalSince1970];
    NSString *dateString=[NSString stringWithFormat:@"%f",date];
    [kudoItem setObject:dateString forKey:@"time"];
    
    if(kudoArray!=nil)
    {
        NSMutableArray *removeArray=[[NSMutableArray alloc]init];
        for(NSDictionary *kudo_gaver in kudoArray)
        {
            if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.current_user_id])
            {
                [removeArray addObject:kudo_gaver];
                
            }
        }
        [kudoArray removeObjectsInArray:removeArray];
    }
    if(assigned)
        [kudoArray addObject:kudoItem];
    if([kudoArray count]!=0)
        location.kudos=[[NSMutableArray alloc] initWithArray:kudoArray];
    else
        location.kudos=nil;
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
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self updateCell];
             });
             if(assigned)
             {
                 User * user=[self.appDelegate.userArray objectForKey:location.cleaner_id];
                 NSString * user_name = [self.defaults objectForKey:@"user_name"];
                 NSString * attributedString=[NSString stringWithFormat:@"%@ gave you kudos", user_name];
                 
                 [self.appDelegate send_notification:user message:attributedString];
                 NSLog(@"assigned");
             }
             else
                 NSLog(@"unassigned");
             
         }
         return nil;
     }];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.activityArray count]>0)
    {
        Activity * activity = [self.activityArray objectAtIndex:indexPath.row];
        self.selectedIndex=indexPath.row;
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
            vc.isKudoed=activity.kudo_assigned;
            if([activity.activity_type isEqualToString: @"clean"])
            {
                vc.cleaned=YES;
            }
            vc.delegate=self;
            
        }
        else if([segue.identifier isEqualToString:@"showKudos"])
        {
            KudosVC * vc=(KudosVC*)segue.destinationViewController;
            vc.location=self.selectedLocation;
            //vc.userArray=self.selectedLocation.kudos;
            vc.imageArray = [[NSMutableDictionary alloc] initWithDictionary:self.imageArray copyItems:YES];
            
        }
        else if([segue.identifier isEqualToString:@"showProfile"])
        {
            ProfileVC * vc=(ProfileVC*)segue.destinationViewController;
            Activity * activity=[self.activityArray objectAtIndex:self.selectedImgIndex];
            vc.profile_user_id = activity.activity_id;
            vc.mode = YES;
            self.appDelegate.shouldRefreshProfile = YES;
        }
        
    }
}

#pragma ProfileTopBarVCDelegate Implementation

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
