#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface ProfileVC : BaseVC

@property (weak, nonatomic) IBOutlet UIImageView *user_photo;
@property (weak, nonatomic) IBOutlet UILabel *user_location;
@property (weak, nonatomic) IBOutlet UILabel *user_following;
@property (weak, nonatomic) IBOutlet UILabel *user_followers;

@property (weak, nonatomic) IBOutlet UILabel *user_name;
@property (weak, nonatomic) IBOutlet UILabel *user_email;
@property (weak, nonatomic) IBOutlet UIButton *user_cleans;
@property (weak, nonatomic) IBOutlet UIButton *user_spotsfound;
@property (weak, nonatomic) IBOutlet UIButton *user_kudos;
@property (weak, nonatomic) IBOutlet UILabel *user_quotes;
@property (strong,nonatomic) NSMutableArray * locationArray;
@property (weak, nonatomic) IBOutlet UITableView *profileTable;

@property (strong,nonatomic) NSString *luser_id;
@property (strong,nonatomic) NSString *luser_name;
@property (strong,nonatomic) NSString *luser_email;
@property (strong,nonatomic) NSString *luser_location;
@property (strong,nonatomic) NSString *luser_about;
@property (strong,nonatomic) NSString *fb_username;
@end
