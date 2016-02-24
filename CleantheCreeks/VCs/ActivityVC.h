#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface ActivityVC : BaseVC<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tv;

@end
