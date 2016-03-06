#import <UIKit/UIKit.h>
#import "PhotoDetailsVC.h"
#import "Location.h"
@interface CameraVC : UIViewController<UIImagePickerControllerDelegate>
	-(void) takePhoto;
@property(strong,atomic) UIImage * cameraPicture;
@property(strong,atomic) NSURL* photoURL;
@property(strong, nonatomic) Location * location;
@end
