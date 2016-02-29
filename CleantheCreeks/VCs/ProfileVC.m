#import "ProfileVC.h"

@implementation ProfileVC

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.profileTopBar setHeaderStyle:YES title:@"DANCARTER86" rightBtnHidden:NO];
	// Do any additional setup after loading the view.
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
