//
//  PhotoDetails.h
//  CleantheCreeks
//
//  Created by Kimura Isoroku on 1/31/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "photoViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import "Location.h"

@interface PhotoDetailsVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CLLocationManagerDelegate,SetPhotoDelegate,UIImagePickerControllerDelegate>

@property (strong,nonatomic) UIImage*firstPicture;
@property (strong,nonatomic) NSURL*firstPath;

@property (weak, nonatomic) IBOutlet UITableView *detailTable;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (retain) CLLocation * currentLocation;
@property (nonatomic, strong) NSString* foundDate;
@property (nonatomic, strong) NSString* cleanedDate;
@property (nonatomic,strong) NSString* locationName1;
- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property(nonatomic, strong) NSString* locationName2;
@property(nonatomic, strong) NSString* countryName;
@property(nonatomic, strong) NSString* commentText;
@end

