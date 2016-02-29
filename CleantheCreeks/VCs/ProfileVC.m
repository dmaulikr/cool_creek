#import "ProfileVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AWSS3/AWSS3.h>
#import "User.h"
@implementation ProfileVC

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    NSString *user_name = [defaults objectForKey:@"user_name"];
    NSString *user_email = [defaults objectForKey:@"user_email"];
    NSString *user_location = [defaults objectForKey:@"user_location"];
    NSString *user_quotes = [defaults objectForKey:@"user_quotes"];
    [self.user_name setText:user_name];
    [self.user_email setText:user_email];
    [self.user_location setText:user_location];
    [self.user_quotes setText:user_quotes];
    [self.profileTopBar setHeaderStyle:NO title:user_name rightBtnHidden:YES];
     NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", user_id];
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
    
    [[dynamoDBObjectMapper load:[User class] hashKey:user_id rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
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
    
    [[dynamoDBObjectMapper load:[User class] hashKey:user_id rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
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
