//
//  FacebookPostVC.h
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/18/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface FacebookPostVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *fbPostImg;
@property (weak, nonatomic) IBOutlet UIImageView *fbTopImage;
- (IBAction)skip:(id)sender;
@property(strong,nonatomic)SLComposeViewController *mySLComposerSheet;
@end
