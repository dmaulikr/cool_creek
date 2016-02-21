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
    
}
- (IBAction)skip:(id)sender {
    [self.tabBarController setSelectedIndex:1];
    [self.tabBarController.tabBar setHidden:NO];
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
        [_mySLComposerSheet addImage:_fbPostImg.image]; //an image you could post
        //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
        [self presentViewController:_mySLComposerSheet animated:YES completion:nil];
    }
    [_mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                
                break;
            case SLComposeViewControllerResultDone:
                
                [self performSegueWithIdentifier:@"showFBSuccess" sender:self];
                break;
            default:
                break;
        }
    }];

}
@end
