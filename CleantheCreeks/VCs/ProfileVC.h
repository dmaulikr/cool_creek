#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface ProfileVC : BaseVC

@property (weak, nonatomic) IBOutlet UIImageView *user_photo;
@property (weak, nonatomic) IBOutlet UILabel *user_location;
@property (weak, nonatomic) IBOutlet UILabel *user_following;
@property (weak, nonatomic) IBOutlet UILabel *user_followers;


@end
