#import "ActivityVC.h"
#import "ActivityCell.h"
#import "KudoCell.h"

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
    
    self.tv.estimatedRowHeight = 65.f;
    self.tv.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    UITableViewCell *cell;
    if (row % 2 == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell" forIndexPath:indexPath];
        
        if (cell == nil){
            cell = [[UITableViewCell alloc] init];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"KudoCell" forIndexPath:indexPath];
        
        if (cell == nil){
            cell = [[UITableViewCell alloc] init];
        }
    }
    
    return cell;
}

@end
