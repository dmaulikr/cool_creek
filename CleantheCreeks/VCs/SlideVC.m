#import "SlideVC.h"
#import "IntroControll.h"
#import "LocationVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "User.h"
@implementation SlideVC
UIImage*firstPicture;
UIImage*secondPicture;

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
}
-(void) mapLabelClicked:(UIButton*) sender
{
    [self performSegueWithIdentifier:@"ViewAroundMe" sender:self];
}
- (void)viewDidLoad
{
   
    [super viewDidLoad];
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,0,0)];
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setTitle:@"SIGN IN WITH FACEBOOK" forState:UIControlStateNormal];
    [loginButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    loginButton.backgroundColor = [UIColor colorWithRed:(1/255.0) green:(122/255.0) blue:(255/255.0) alpha:1.0];
    loginButton.layer.cornerRadius = 4.0f;
    loginButton.frame=CGRectMake(0, 0, self.view.frame.size.width*0.8, self.view.frame.size.width*0.15);
    [loginButton setCenter:CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/23*21-loginButton.frame.size.height/2)];
    [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
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
                       NSUserDefaults *loginInfo=[NSUserDefaults standardUserDefaults];
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
                      user_info.user_name=result[@"name"];
                      user_info.device_token=[loginInfo objectForKey:@"devicetoken"];
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

@end
