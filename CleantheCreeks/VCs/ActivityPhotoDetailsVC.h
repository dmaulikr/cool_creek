//
//  ActivityPhotoDetailsVC.h
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "Location.h"
@protocol KudoDelegate<NSObject>
@optional
-(void) giveKudoWithLocation:(Location*)location assigned:(bool) assigned;
@end
@interface ActivityPhotoDetailsVC : BaseVC<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (strong, nonatomic) Location * location;
@property (nonatomic) BOOL cleaned,isKudoed;
@property (strong, nonatomic) UIImage * beforePhoto, *afterPhoto;
@property(nonatomic, retain) id<KudoDelegate> delegate;
@end
