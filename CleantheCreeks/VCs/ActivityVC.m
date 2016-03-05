#import "ActivityVC.h"
#import "CleaningCommentCell.h"
#import "CleaningDoneCell.h"
#import "Location.h"
#import "User.h"
#import "Activity.h"
#import <CoreLocation/CoreLocation.h>
@implementation ActivityVC

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    return self;
}


- (void)viewDidLoad
{
    
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    self.userArray=[[NSMutableDictionary alloc]init];
   
    self.activityArray=[[NSMutableArray alloc]init];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (User *user in paginatedOutput.items)
             {
                 [self.userArray setObject:user forKey:user.user_id];
                 
             }
             User * current_user = [self.userArray objectForKey:user_id];
             AWSDynamoDBObjectMapper *dynamoDBObjectMapper2 = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
             AWSDynamoDBScanExpression *scanExpression2 = [AWSDynamoDBScanExpression new];
             [[dynamoDBObjectMapper2 scan:[Location class] expression:scanExpression2] continueWithBlock:^id(AWSTask *task) {
                 if (task.result) {
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     for (Location *location in paginatedOutput.items) {
                         for(NSDictionary * iterator in current_user.followings)
                         {
                             NSString * person_id=[iterator objectForKey:@"id"];
                             
                             // Adding finders to the activity array
                             if([location.founder_id isEqualToString:person_id])
                             {
                                 Activity *activity=[[Activity alloc]init];
                                 activity.activity_id = person_id;
                                 activity.activity_time=location.found_date;
                                 activity.activity_type = @"find";
                                 activity.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                                 [self.activityArray addObject:activity];
                             }
                             
                             //Adding clearners to the activity array
                             if([location.cleaner_id isEqualToString:person_id])
                             {
                                 Activity *activity=[[Activity alloc]init];
                                 activity.activity_id = person_id;
                                 activity.activity_time=location.cleaned_date;
                                 activity.activity_type = @"clean";
                                 activity.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                                 [self.activityArray addObject:activity];
                             }
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
                                 [self.activityArray addObject:activity];
                             }
                             
                         }
                         // Adding kudos
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
                         
                         // Adding followings
                         for(NSDictionary * item in current_user.followers)
                         {
                             NSString * follower_id=[item objectForKey:@"id"];
                             NSString * following_date=[item objectForKey:@"time"];
                             // Adding finders to the activity array
                             Activity *activity=[[Activity alloc]init];
                             activity.activity_id = follower_id;
                             activity.activity_time=[following_date doubleValue];
                             activity.activity_type = @"follower";
                             [self.activityArray addObject:activity];
                             
                         }
                         
                     }
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tv reloadData];
                 });
                 return nil;
                 
             }];

             
         }
         return nil;
     }];

    self.tv.estimatedRowHeight = 65.f;
    self.tv.rowHeight = UITableViewAutomaticDimension;
    
    [self.profileTopBar setHeaderStyle:YES title:@"ACTIVITY" rightBtnHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableView Delegate Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.activityArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    UITableViewCell *cell;
    Activity * activity = [self.activityArray objectAtIndex:row];
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", activity.activity_id];
    if([activity.activity_type isEqualToString: @"clean"])
    {
        cell = (CleaningDoneCell*)[tableView dequeueReusableCellWithIdentifier:@"CleaningDoneCell" forIndexPath:indexPath];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userImageURL]];
            if ( data == nil )
                return;
            // WARNING: is the cell still using the same data by this point??
            [((CleaningDoneCell*)cell).profileAvatar setImage:[UIImage imageWithData: data]];
        });
        User * user=[self.userArray objectForKey:activity.activity_id];
        [self getLocationName:activity.coordinate];
        [((CleaningDoneCell*)cell).lblContent setAttributedText:[self generateString:user.user_name content:@" has finished cleaning " location:self.user_location]];
        [((CleaningDoneCell*)cell).activityHours setText:[self timeDifference:activity.activity_time]];
        
        if (cell == nil){
            cell = [[UITableViewCell alloc] init];
        }
    }
    else
    {
        cell = (CleaningCommentCell*)[tableView dequeueReusableCellWithIdentifier:@"CleaningCommentCell" forIndexPath:indexPath];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userImageURL]];
            if ( data == nil )
                return;
            // WARNING: is the cell still using the same data by this point??
            [((CleaningCommentCell*)cell).profileAvatar setImage:[UIImage imageWithData: data]];
        });
        if (cell == nil){
            cell = [[UITableViewCell alloc] init];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"ActivityVC2ActivityPhotoDetailVC" sender:nil];
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
    NSTimeInterval currentTime=[[NSDate date] timeIntervalSince1970];
    NSDate *date=[[NSDate alloc] initWithTimeIntervalSince1970:currentTime-activityDate];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd HH"];
    NSString *localDateString = [dateFormatter stringFromDate:date];
    return localDateString;
}
- (void) getLocationName:(CLLocationCoordinate2D) coordinate
{
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSString * locationName=[[NSString alloc]init];
    [ceo reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError *error)
    {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        self.user_location = [placemark.addressDictionary valueForKey:@"Name"];
    }
    ];
    
}
@end
