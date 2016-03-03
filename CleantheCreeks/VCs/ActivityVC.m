#import "ActivityVC.h"
#import "CleaningCommentCell.h"
#import "CleaningDoneCell.h"
#import "Location.h"
@implementation ActivityVC

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   /*( NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[dynamoDBObjectMapper scan:[Location class] expression:scanExpression] continueWithBlock:^id(AWSTask *task) {
        if (task.result) {
            AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
            for (Location *location in paginatedOutput.items) {
                NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:location.location_id];
                NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                if(distance<100.0)
                {
                    if(![self.locationArray containsObject:location])
                        [self.locationArray addObject:location];
                    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    downloadRequest.bucket = @"cleanthecreeks";
                    NSString * key=[location.location_id stringByAppendingString:@"a"];
                    downloadRequest.key = key;
                    downloadRequest.downloadingFileURL = downloadingFileURL;
                    LocationAnnotation *annotation=[[LocationAnnotation alloc]init];
                    annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                    
                    annotation.title = location.location_name;
                    annotation.subtitle = location.location_id;
                    self.mainDelegate.locationData[location.location_id]=[UIImage imageNamed:@"PlaceIcon"];
                    
                    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task2) {
                        if (task2.result) {
                            self.imageArray[key]=[UIImage imageWithContentsOfFile:downloadingFilePath];
                            self.mainDelegate.locationData[location.location_id]=[UIImage imageWithContentsOfFile:downloadingFilePath];
                            [self.locationTable reloadData];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.mapView addAnnotation:annotation];
                        });
                        
                        return nil;
                    }];
                    
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.locationTable reloadData];
        });
        return nil;
        
    }];

*/
    self.tv.estimatedRowHeight = 65.f;
    self.tv.rowHeight = UITableViewAutomaticDimension;
    
    [self.profileTopBar setHeaderStyle:YES title:@"ACTIVITY" rightBtnHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableView Delegate Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    UITableViewCell *cell;
    if (row % 2 == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"CleaningCommentCell" forIndexPath:indexPath];
        
        if (cell == nil){
            cell = [[UITableViewCell alloc] init];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"CleaningDoneCell" forIndexPath:indexPath];
        
        if (cell == nil){
            cell = [[UITableViewCell alloc] init];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"ActivityVC2ActivityPhotoDetailVC" sender:nil];
}

#pragma ProfileTopBarVCDelegate Implementation

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

@end
