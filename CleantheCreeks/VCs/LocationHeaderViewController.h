//
//  LocationHeaderViewController.h
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/9/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationNav.h"
@protocol LocationHeaderDelegate<NSObject>
@optional
-(void) ShowList;
-(void) ShowMap;
@end

@interface LocationHeaderViewController : UIViewController<LocationHeaderDelegate>
@property (weak, nonatomic) IBOutlet UIButton *showListButton;
- (IBAction)listButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *showMapButton;
- (IBAction)mapButtonClicked:(id)sender;
@property(nonatomic, retain) id<LocationHeaderDelegate> delegate;
@property(nonatomic, retain) UINavigationController * navigationController;
@end
