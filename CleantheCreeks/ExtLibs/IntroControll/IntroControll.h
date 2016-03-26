#import <UIKit/UIKit.h>
#import "IntroView.h"
#import "FirstPageView.h"
#import "LastPageView.h"
@interface IntroControll : UIView<UIScrollViewDelegate>

@property (nonatomic, strong) NSArray*pages;
@property (nonatomic, strong)UIImageView *backgroundImage1;
@property (nonatomic, strong)UIImageView *backgroundImage2;
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UIPageControl *pageControl;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic)int currentPhotoNum;
- (id)initWithFrame:(CGRect)frame pages:(NSArray*)pages;

@end
