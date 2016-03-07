#import <UIKit/UIKit.h>
#import "PhotoDetailsVC.h"
#import "Location.h"
#import "BaseVC.h"
#import "PhotoDetailsVC.h"

@interface CameraVC : BaseVC<UIImagePickerControllerDelegate,CameraRefreshDelegate>
	-(void) takePhoto;
@property(weak,atomic) UIImage * cameraPicture;
@property(strong,atomic) NSURL* photoURL;
@property(strong, nonatomic) Location * location;
@property(strong, nonatomic) UIImage* dirtyPhoto;
@property(nonatomic) BOOL photoTaken;

@end
