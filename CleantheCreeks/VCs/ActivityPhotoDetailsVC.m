//
//  ActivityPhotoDetailsVC.m
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "ActivityPhotoDetailsVC.h"
#import "PhotoViewCell.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AWSS3/AWSS3.h>
#import "DetailCell.h"
@implementation ActivityPhotoDetailsVC

- (void) viewDidLoad{
    [super viewDidLoad];
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];

    AWSS3TransferManagerDownloadRequest *firstRequest = [AWSS3TransferManagerDownloadRequest new];
    firstRequest.bucket = @"cleanthecreeks";
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.location.location_id stringByAppendingString:@"a"]];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    NSString * beforeKey=[self.location.location_id stringByAppendingString:@"a"];
    firstRequest.key = beforeKey;
    firstRequest.downloadingFileURL = downloadingFileURL;
    [[transferManager download:firstRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task2) {
        if (task2.result) {
            self.beforePhoto = [UIImage imageWithContentsOfFile:downloadingFilePath];
            [self.tv reloadData];
        }
        
        return nil;
    }];
    if(self.cleaned)
    {
        AWSS3TransferManagerDownloadRequest *secondRequest = [AWSS3TransferManagerDownloadRequest new];
        NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.location.location_id stringByAppendingString:@"b"]];
        NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
        NSString * beforeKey=[self.location.location_id stringByAppendingString:@"b"];
        secondRequest.key = beforeKey;
        secondRequest.downloadingFileURL = downloadingFileURL;
        [[transferManager download:secondRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task2) {
            if (task2.result) {
                self.afterPhoto = [UIImage imageWithContentsOfFile:downloadingFilePath];
                [self.tv reloadData];
            }
            
            return nil;
        }];

    }
    [self.profileTopBar setHeaderStyle:NO title:@"GYRO BEACH" rightBtnHidden:YES];
}

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
   [self dismissVC];
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height=0;
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
            height=5;
        else if(indexPath.row==1)
            height=self.view.frame.size.height*0.3;
    }
    else if(indexPath.section==1)
    {
        if(indexPath.row==0)
            height=5;
        else if(indexPath.row==3)
        {
            
            height=self.view.frame.size.height*0.13;
        }
        else
            height=self.view.frame.size.height*0.13;
    }
    else if(indexPath.section==2)
    {
        if(indexPath.row==0)
            height=5;
        else
            height=self.view.frame.size.height*0.4;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count=0;
    if(section==0)
        count=2;
    else if(section==1)
        count=4;
    else if(section==2)
        count=2;
    return count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell=[[UITableViewCell alloc]init];
    
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"FirstBar"];
        else if(indexPath.row==1)
        {
            cell = (PhotoViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
            [((PhotoViewCell*)cell).firstPhoto setImage:self.beforePhoto];
            if(self.cleaned)
                [((PhotoViewCell*)cell).firstPhoto setImage:self.afterPhoto];
            
        }
    }
    else if(indexPath.section==1)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *user_name = [defaults objectForKey:@"user_name"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy"];
        
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"SecondBar"];
        else if(indexPath.row==1)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"FirstDetailCell"];
            
            [((DetailCell*)cell).locationName1 setText:self.location.location_name];
            NSString * subLocation = [[NSString alloc]initWithFormat:@"%@, %@, %@", self.location.locality, self.location.state, self.location.country];
            [((DetailCell*)cell).locationName2 setText:subLocation];
        }
        else if(indexPath.row==2)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"SecondDetailCell"];
            [((DetailCell*)cell).finderName setText:user_name];
          //  [((DetailCell*)cell).foundDate setText:[dateFormatter stringFromDate:self.foundDate]];
            
        }
        else if(indexPath.row==3)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"ThirdDetailCell"];
            [((DetailCell*)cell).cleanerName setText:user_name];
           // [((DetailCell*)cell).cleanedDate setText:[dateFormatter stringFromDate:self.cleanedDate]];
        }
        
    }
    else if(indexPath.section==2)
    {
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"ThirdBar"];
        else if(indexPath.row==1)
            cell = [tableView dequeueReusableCellWithIdentifier:@"FourthDetailCell"];
    }
    if(!cell){
        cell = nil;
        
    }
    return cell;
}



- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title;
    if(section == 0)
        title = @"Details";
    else if(section == 1)
        title = @"Timeline";
    else if(section == 2)
        title = @"Comments";
    return title;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *stringToSave = [textField.text stringByReplacingCharactersInRange:range withString:string];
  //  self./commentText=stringToSave;
    
    return YES;
}
@end
