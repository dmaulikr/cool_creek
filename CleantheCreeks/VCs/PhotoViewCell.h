//
//  PhotoViewCell.h
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/5/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetPhotoDelegate<NSObject>
@optional
-(void) setSecondPhoto:(BOOL)set;
@end
@interface PhotoViewCell : UITableViewCell<UIImagePickerControllerDelegate,UITableViewDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *firstPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *secondPhoto;
@property(nonatomic, retain) id<SetPhotoDelegate> delegate;
@end