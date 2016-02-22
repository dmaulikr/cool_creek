#import <UIKit/UIKit.h>
#import "PhotoDetailsVC.h"

@interface CameraVC : UIViewController<UIImagePickerControllerDelegate>
	-(void) takePhoto;
@property(strong,atomic) UIImage * cameraPicture;
@property(strong,atomic) NSURL* photoURL;

@end
