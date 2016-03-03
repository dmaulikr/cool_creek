#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AWSS3/AWSS3.h>
@interface ProfileVC : BaseVC<UITableViewDataSource, UITableViewDelegate>


@property (strong,nonatomic) NSMutableArray * locationArray;
@property (weak, nonatomic) IBOutlet UITableView *profileTable;

@property (strong,nonatomic) NSString *luser_id;
@property (strong,nonatomic) NSString *luser_name;
@property (strong,nonatomic) NSString *luser_email;
@property (strong,nonatomic) NSString *luser_location;
@property (strong,nonatomic) NSString *luser_about;
@property (strong,nonatomic) NSString *fb_username;

@property (strong,nonatomic) NSString *formattedCleansCount;
@property (strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property  NSInteger kudoCount;
@end
