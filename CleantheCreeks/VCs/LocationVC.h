#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface LocationVC : UIViewController<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *locationTable;
@property (strong,nonatomic) NSMutableArray * locationArray;
@property (strong,nonatomic) NSMutableDictionary * imageArray;
@property (weak, nonatomic) IBOutlet UIButton *listButton;

- (IBAction)listButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
- (IBAction)mapButtonClicked:(id)sender;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (retain) CLLocation * currentLocation;
@end
