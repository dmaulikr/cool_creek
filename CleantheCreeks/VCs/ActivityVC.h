#import <UIKit/UIKit.h>

@interface ActivityVC : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tv;

@end
