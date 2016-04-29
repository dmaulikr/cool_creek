//
//  FacebookPostVC.m
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/18/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "FacebookPostVC.h"
#import "MainTabnav.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
@implementation FacebookPostVC

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self.profileTopBar setHeaderStyle:YES title:@"LOCATION DETAILS" rightBtnHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_name = [defaults objectForKey:@"user_name"];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", user_id];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userImageURL]];
        if ( data != nil ){
            [self.user_photo setImage:[UIImage imageWithData:data]];
        }
        
    });
    self.user_name.adjustsFontSizeToFitWidth = YES;
    self.time.adjustsFontSizeToFitWidth=YES;
    [self.user_name setText:user_name];
    UIImage* img=[self mergeImage:self.firstPhoto withImage:self.secondPhoto bottomImage:[UIImage imageNamed:@"website2"]];
    
    [_fbImage setImage:img];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Facebook Posting"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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

- (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second bottomImage:(UIImage*)bottom
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    
    CGFloat size = MIN(firstWidth, firstHeight);
    // build merged size
    float bottomHeight = (CGFloat)(CGImageGetHeight(bottom.CGImage) / (CGFloat)CGImageGetWidth(bottom.CGImage)) * size*2;
    CGSize mergedSize = CGSizeMake((size*2), size+bottomHeight+10);
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, size, size)];
    //[second drawInRect:CGRectMake(firstWidth, 0, secondWidth, secondHeight)];
    [second drawInRect:CGRectMake(size-1, 0, size, size)
             blendMode:kCGBlendModeNormal alpha:1.0];
    [bottom drawInRect:CGRectMake(0, size, size*2, bottomHeight)];
    
    //Place logo
    UIImage * imgLogo=[UIImage imageNamed:@"SliderLogoSmall"];
    [imgLogo drawInRect:CGRectMake(5,5,imgLogo.size.width*2,imgLogo.size.height*2)];
    
    //Place before button
    UIImage * imgBefore=[UIImage imageNamed:@"btnBefore"];
    [imgBefore drawInRect:CGRectMake(size-imgBefore.size.width*2,5+imgLogo.size.height-imgBefore.size.height,imgBefore.size.width*2,imgBefore.size.height*2)];
    
    //Place after button
    if(self.cleaned)
    {
        UIImage * imgAfter=[UIImage imageNamed:@"btnAfter"];
        [imgAfter drawInRect:CGRectMake(size*2-imgAfter.size.width*2,5+imgLogo.size.height-imgAfter.size.height,imgAfter.size.width*2,imgAfter.size.height*2)];
    }
    //Place download button
    
    UIImage * imgDownload=[UIImage imageNamed:@"downloadImg"];
    [imgDownload drawInRect:CGRectMake(size - imgDownload.size.width,size-80-imgDownload.size.height,imgDownload.size.width*2,imgDownload.size.height*2)];
    
    //Draw text
    UIFont *font = [UIFont boldSystemFontOfSize:40];
    
    NSString *text = [[NSString alloc] initWithFormat:@"WWW.CLEANTHECREEK.COM | BY %@",[self.user_name.text uppercaseString]];
    CGRect rect = CGRectMake(40,size+bottomHeight-40,size*2-10, 40);
    [[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (IBAction)FBPost:(id)sender {
    UIImage * fbPostImg=[self mergeImage:self.firstPhoto withImage:self.secondPhoto bottomImage:[UIImage imageNamed:@"website2"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *imageData = UIImageJPEGRepresentation(fbPostImg, 0.4);
        NSString *imageString = [NSString stringWithFormat:@"Content-Disposition: form-data;    name=\"userfile\"; filename=\"%@\"\r\n", [NSString stringWithFormat:@"%@.jpg",self.locationID]];
        
        NSString *urlString = @"http://cleanthecreek.com/images/fb/upload.php";
        
        NSLog(@"upload url%@", urlString);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        NSString *boundary = @"--------------------------    -14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;     boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary]     dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:imageString ]     dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-    stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary]     dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
    });

    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
    {
        _mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        _mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
        [_mySLComposerSheet setInitialText:@"Clean the Creek"]; //the message you want to post
    
        [_mySLComposerSheet addImage:fbPostImg]; //an image you could post
        [_mySLComposerSheet setTitle:@"Look what I just cleaned up #cleanthecreek"];
        NSString * url = [NSString stringWithFormat:@"http://cleanthecreek.com/images/fb/fb-scrape.php?locationID=%@",self.locationID];
        [_mySLComposerSheet addURL:[NSURL URLWithString:url]];
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
