//
//  FBList.h
//  CTC
//
//  Created by Andy on 7/11/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "AppDelegate.h"
@interface FBList : BaseVC

@property (strong, nonatomic) NSMutableArray * friendsArray;
@property (nonatomic) long displayIndex;
@property (strong, nonatomic) AppDelegate * appDelegate;

@property (strong, nonatomic) User * profile_user;

@property (strong ,nonatomic) NSMutableDictionary* imageArray;

@property (weak, nonatomic) IBOutlet UITableView *friendTable;
@property(nonatomic) long selectedImgIndex;
@end
