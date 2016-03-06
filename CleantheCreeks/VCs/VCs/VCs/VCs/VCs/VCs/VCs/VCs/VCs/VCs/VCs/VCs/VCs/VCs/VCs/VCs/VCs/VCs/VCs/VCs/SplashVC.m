#import "SplashVC.h"

@implementation SplashVC

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
    if(user_id!=nil)
    {
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(moveToMainNav) userInfo:nil repeats:false];
    }
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(moveToSlide) userInfo:nil repeats:false];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)moveToSlide {
    [self performSegueWithIdentifier:@"Splash2Slide" sender:self];
}
- (void) moveToMainNav
{
    [self performSegueWithIdentifier:@"skip2MainNav" sender:self];
}

@end