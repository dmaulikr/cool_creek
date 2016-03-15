//
//  FacebookPostVC.m
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/18/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "FacebookPostVC.h"
#import "MainTabnav.h"
@implementation FacebookPostVC
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.profileTopBar setHeaderStyle:YES title:@"LOCATION DETAILS" rightBtnHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.firstPhoto!=nil)
       [self.fbFirstImg setImage:self.firstPhoto];
    if(self.secondPhoto!=nil)
        [self.fbLastImage setImage:self.secondPhoto];
    
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"controller class: %@", NSStringFromClass([viewController class]));
    NSLog(@"controller title: %@", viewController.title);
    
    [self dismissVC];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)skip:(id)sender {
    [self.tabBarController.tabBar setHidden:NO];
    [self.tabBarController setSelectedIndex:1];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

 - (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    CGFloat size=MIN(firstWidth, firstHeight);
    // build merged size
    
    CGSize mergedSize = CGSizeMake((size*2), size);
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, size, size)];
    //[second drawInRect:CGRectMake(firstWidth, 0, secondWidth, secondHeight)];
    [second drawInRect:CGRectMake(size-1, 0, size, size)
             blendMode:kCGBlendModeNormal alpha:1.0];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (IBAction)FBPost:(id)sender {
    /*UIImage *bottomImage =fbPostImage.
     UIImage *image       = [UIImage imageNamed:@"top.png"]; //foreground image
     
     CGSize newSize = CGSizeMake(width, height);
     UIGraphicsBeginImageContext( newSize );
     
     // Use existing opacity as is
     [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
     
     // Apply supplied opacity if applicable
     [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.8];*/
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
    {
        _mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        _mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
        [_mySLComposerSheet setInitialText:[NSString stringWithFormat:@"Clean the Creek",_mySLComposerSheet.serviceType]]; //the message you want to post
        UIImage * fbPostImg=[self mergeImage:self.firstPhoto withImage:self.secondPhoto];
        [_mySLComposerSheet addImage:fbPostImg]; //an image you could post
        [_mySLComposerSheet setTitle:@"Look what I just cleaned up #cleanthecreek"];
        //[_mySLComposerSheet addURL:[NSURL URLWithString:@"http://www.cleanthecreek.com"]];
        [self presentViewController:_mySLComposerSheet animated:YES completion:nil];
    }
    [_mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:
                [self performSegueWithIdentifier:@"showFBSuccess" sender:self];
                [self.tabBarController.tabBar setHidden:NO];
                break;
            default:
                break;
        }
    }];
    
}
@end
