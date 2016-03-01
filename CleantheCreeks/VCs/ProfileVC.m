#import "ProfileVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AWSS3/AWSS3.h>
#import "User.h"
#import "Location.h"
#import "ProfileViewCell.h"
@implementation ProfileVC

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    return self;
}


- (void)viewDidLoad
{
    self.locationArray=[[NSMutableArray alloc]init];
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.luser_id = [defaults objectForKey:@"user_id"];
    self.luser_name = [defaults objectForKey:@"user_name"];
    self.luser_email = [defaults objectForKey:@"user_email"];
    self.luser_location = [defaults objectForKey:@"user_location"];
    self.luser_about = [defaults objectForKey:@"user_about"];
    self.fb_username = [defaults objectForKey:@"username"];
    
    [self.user_name setText:self.luser_name];
    [self.user_email setText:self.luser_email];
    [self.user_location setText:self.luser_location];
    [self.user_quotes setText:self.luser_about];
    [self.profileTopBar setHeaderStyle:YES title:self.luser_name rightBtnHidden:NO];
     NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", self.luser_id];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userImageURL]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            [self.user_photo setImage:[UIImage imageWithData: data]];
        });
     
    });
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper load:[User class] hashKey:self.luser_id rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"The request failed. Error: [%@]", task.error);
        }
        if (task.exception) {
            NSLog(@"The request failed. Exception: [%@]", task.exception);
        }
        if (task.result) {
            
            User *user=task.result;
            NSArray * kudoArray=[[NSArray alloc]init];
            kudoArray=user.kudos;
            [self.user_kudos setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)[kudoArray count]] forState:UIControlStateNormal];
        }
    
     return nil;
    }];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.filterExpression = @"cleaner_id = :val";
    scanExpression.expressionAttributeValues = @{@":val":self.luser_id};
    [[dynamoDBObjectMapper scan:[Location class]
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
             NSString *formattedCleansCount = [NSString stringWithFormat:@"%lu",(unsigned long)paginatedOutput.items.count];
             for (Location *location in paginatedOutput.items)
             {
                 [self.locationArray addObject:location];
             }
             [self.user_cleans setTitle:formattedCleansCount forState:UIControlStateNormal];
             [self.profileTable reloadData];
         }
         
         return nil;
     }];
    
    scanExpression.filterExpression = @"founder_id = :val";
    scanExpression.expressionAttributeValues = @{@":val":self.luser_id};
    [[dynamoDBObjectMapper scan:[Location class]
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
             
             [self.user_spotsfound setTitle:formattedFindsCount forState:UIControlStateNormal];
         }
         return nil;
     }];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.locationArray count];
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ProfileViewCell * cell=nil;
    cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"profileViewCell"];
    if([self.locationArray count]>0)
    {
        Location * location=[self.locationArray objectAtIndex:indexPath.row];
        
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
        [cell.date setText:location.cleaned_date];
        
        //[cell.kudoCount setText:kudoCount];
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
                [cell.beforePhoto setImage:[UIImage imageWithContentsOfFile:downloadingFilePath]];
                
            }
            return nil;
        }];
        
        NSString * afterkey=[location.location_id stringByAppendingString:@"b"];
        NSString * afterPath = [NSTemporaryDirectory() stringByAppendingPathComponent:afterkey];
        NSURL * afterurl = [NSURL fileURLWithPath:afterPath];
        AWSS3TransferManagerDownloadRequest *afterdownloadRequest = [AWSS3TransferManagerDownloadRequest new];
        afterdownloadRequest.key = key;
        afterdownloadRequest.downloadingFileURL = afterurl;
        
        AWSS3TransferManager *aftertransferManager = [AWSS3TransferManager defaultS3TransferManager];
        [[aftertransferManager download:afterdownloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task2) {
            if (task2.result) {
                [cell.afterPhoto setImage:[UIImage imageWithContentsOfFile:afterPath]];
                
            }
            return nil;
        }];

    }
    if(!cell){
        cell=(ProfileViewCell*)[[UITableViewCell alloc]init];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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


@end
