#import "SlideVC.h"
#import "LocationVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "User.h"
#import "LocationVC.h"

@implementation SlideVC
UIImage *firstPicture;
UIImage *secondPicture;
UIButton *loginButton;
- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    self.wantsFullScreenLayout = YES;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    return self;
}

- (void) loadView {
    [super loadView];
    
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Track your Kudos with clean\nthe creek" image:@"back1.jpg" ToVC:self];
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Tag a dirty spot" image:@"back2.jpg" ToVC:self];
    IntroModel *model3 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Complete your deed and\nget kudos" image:@"back3.jpg" ToVC:self];
    IntroModel *model4 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Post your kudos to facebook" image:@"back4.jpg" ToVC:self];
    IntroModel *model5 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Show your facebook friends\nyour good deeds." image:@"back1.jpg" ToVC:self];
    IntroControll *control=[[IntroControll alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) pages:@[model1, model2, model3,model4,model5]];
       self.view =control;
    control.delegate=self;
    
    UITapGestureRecognizer *dtapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapLabelClicked)];
    dtapGestureRecognize.delegate = self;
    dtapGestureRecognize.numberOfTapsRequired = 1;
    UIButton *mapButton=[self.view viewWithTag:15];
    [mapButton addGestureRecognizer:dtapGestureRecognize];
    NSMutableArray * gestureArray=[[NSMutableArray alloc]init];
    for(int i=0;i<5;i++)
    {
        UITapGestureRecognizer *fbGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginButtonClicked)];
        fbGestureRecognize.delegate = self;
        fbGestureRecognize.numberOfTapsRequired = 1;
        UIButton *fbButton=[self.view viewWithTag:i+16];
        [fbButton addGestureRecognizer:fbGestureRecognize];
    }
}

-(void) mapLabelClicked
{
    [self performSegueWithIdentifier:@"viewAroundMe" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)moveToMainNav {
    [self performSegueWithIdentifier:@"Slide2MainTabNav" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"viewAroundMe"])
    {
        LocationVC* vc = (LocationVC*)segue.destinationViewController;
        vc.fromSlider=YES;
    }
}

-(void)loginButtonClicked
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile",@"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else
         {
             NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
             [parameters setValue:@"id,name,email,location,about" forKey:@"fields"];
             [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
              startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                  
                  if (!error) {
                      NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
                       NSUserDefaults *loginInfo = [NSUserDefaults standardUserDefaults];
                      NSString *fbUsername = [[result valueForKey:@"link"] lastPathComponent];
                      [loginInfo setObject:fbUsername forKey:@"username"];
                      [loginInfo setObject:result[@"id"] forKey:@"user_id"];
                      [loginInfo setObject:result[@"name"] forKey:@"user_name"];
                      [loginInfo setObject:result[@"email"] forKey:@"user_email"];
                      [loginInfo setObject:result[@"location"] forKey:@"user_location"];
                      [loginInfo setObject:result[@"about"] forKey:@"user_about"];
                      [loginInfo synchronize];
                      User * user_info = [User new];
                      user_info.user_id = result[@"id"];
                      //user_info.kudos = [[NSArray alloc]init];
                      user_info.user_name = result[@"name"];
                      user_info.device_token = [loginInfo objectForKey:@"devicetoken"];
                      user_info.user_email= [loginInfo objectForKey:@"user_email"];
                      user_info.user_about=[loginInfo objectForKey:@"user_about"];
                      
                      AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
                      updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorAppendSet;
                      AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
                      [[dynamoDBObjectMapper save:user_info configuration:updateMapperConfig]
                       continueWithBlock:^id(AWSTask *task) {
                           if (task.error) {
                               NSLog(@"The request failed. Error: [%@]", task.error);
                           }
                           if (task.exception) {
                               NSLog(@"The request failed. Exception: [%@]", task.exception);
                           }
                           if (task.result) {
                               NSLog(@"new user is registered");
                           }
                           return nil;
                       }];

                  }
              }];
            [self moveToMainNav];
             
         }
     }];
}

-(void) lastPage:(bool)show
{
    if(show)
        [loginButton setCenter:CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/67*42-loginButton.frame.size.height/2)];
    else
        [loginButton setCenter:CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/23*21-loginButton.frame.size.height/2)];
        
}
@end
