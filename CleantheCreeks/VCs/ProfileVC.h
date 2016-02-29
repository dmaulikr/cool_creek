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

@end
