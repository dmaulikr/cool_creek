#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
@interface LocationVC : UIViewController<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *locationTable;

@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *btnCountry;
@property (weak, nonatomic) IBOutlet UIButton *btnState;
@property (weak, nonatomic) IBOutlet UIButton *btnLocal;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (retain) CLLocation * currentLocation;
@property (strong,nonatomic) NSMutableArray * locationArray;
@property (strong,nonatomic) NSMutableDictionary * imageArray;
@property (strong,nonatomic )AppDelegate * mainDelegate;
- (IBAction)listButtonTapped:(id)sender;
- (IBAction)mapButtonTapped:(id)sender;

@end
