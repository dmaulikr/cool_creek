#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

#import <AWSS3/AWSS3.h>
#import "AppDelegate.h"

@interface ActivityVC : BaseVC<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property (strong,nonatomic) NSMutableArray * activityArray;
@property (strong,nonatomic) AppDelegate * appDelegate;
@property (strong,nonatomic) NSMutableDictionary * userArray;

@end
