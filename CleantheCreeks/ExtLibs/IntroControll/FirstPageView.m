#import "FirstPageView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@implementation FirstPageView

- (id)initWithFrame:(CGRect)frame model:(IntroModel*)model
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *imgLogo=[UIImage imageNamed:@"SliderLogoLarge"];
        UIImageView *imageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,imgLogo.size.width, imgLogo.size.height)];
        imageHolder.image=imgLogo;
        [imageHolder setCenter:CGPointMake(frame.size.width/2, frame.size.height*0.28)];
        [self addSubview:imageHolder];
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:model.titleText];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:24]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel sizeToFit];
        [titleLabel setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [self addSubview:titleLabel];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        [descriptionLabel setText:model.descriptionText];
        [descriptionLabel setFont:[UIFont systemFontOfSize:20]];
        [descriptionLabel setTextColor:[UIColor whiteColor]];
        
        [descriptionLabel setNumberOfLines:3];
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
        
      
        CGSize s = [descriptionLabel.text sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(frame.size.width-40, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        //three lines height
        CGSize three = [@"1 \n 2 \n 3" sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(frame.size.width-40, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        descriptionLabel.frame = CGRectMake((self.frame.size.width-s.width)/2, titleLabel.frame.origin.y+titleLabel.frame.size.height+30,s.width, MIN(s.height, three.height));

        [self addSubview:descriptionLabel];
        
    }
    return self;
}
@end
