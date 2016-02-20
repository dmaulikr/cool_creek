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
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(moveToSlide) userInfo:nil repeats:false];
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

@end
