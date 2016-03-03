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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.filterExpression = @"cleaner_id = :val";
    self.dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    scanExpression.expressionAttributeValues = @{@":val":user_id};
    [[self.dynamoDBObjectMapper scan:[Location class]
                          expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             for (Location *location in paginatedOutput.items)
             {
                
             
             }
             
         }
         
         return nil;
     }];

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
