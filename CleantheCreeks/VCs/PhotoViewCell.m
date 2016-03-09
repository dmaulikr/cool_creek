//
//  photoViewCell.m
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/5/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "PhotoViewCell.h"

@implementation PhotoViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto)];
    singleTap.numberOfTapsRequired=1;
    [self.secondPhoto setUserInteractionEnabled:YES];
    [self.secondPhoto addGestureRecognizer:singleTap];
}

-(void) takePhoto
{
    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO)
    {
        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    }
    picker.delegate=self;
    [self.window.rootViewController presentViewController:picker animated:YES completion:nil];
}

-(void)tapDetected{
    NSLog(@"Tapped");
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * photo=[[UIImage alloc]init];
    photo=[info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.secondPhoto setImage:photo];
    [self.delegate setSecondPhoto:true photo:photo];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
