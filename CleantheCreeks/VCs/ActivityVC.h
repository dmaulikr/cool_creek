#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Location.h"
#import <AWSS3/AWSS3.h>
#import "AppDelegate.h"
#import "ActivityPhotoDetailsVC.h"

@interface ActivityVC : BaseVC<UITableViewDataSource, UITableViewDelegate,KudoDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property (strong,nonatomic) NSMutableArray * activityArray;
@property (strong,nonatomic) NSMutableDictionary * imageArray;
@property (strong,nonatomic) AppDelegate * appDelegate;
//@property (strong,nonatomic) NSMutableDictionary * userArray;
@property(nonatomic) int displayItemCount;

@property (strong, nonatomic) Location * selectedLocation;
@property(strong,nonatomic)NSString *current_user;
@property(strong,nonatomic)NSIndexPath * selectedIndex;
@property(strong, nonatomic)NSMutableArray * indexPathArray;

-(void) giveKudoWithIndex:(int) index assigned:(bool)assigned;
-(void) updateCell;

@property(strong, nonatomic) NSUserDefaults *defaults;


@end
