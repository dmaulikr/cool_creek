//
//  KudoCell.m
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "CleaningDoneCell.h"
#import "Activity.h"

@implementation CleaningDoneCell
{
    //(void (^)(void)) callback;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)kudosBtnTapped:(id)sender {

    NSLog(@"%ld",(long)[sender tag]);

}

- (IBAction)giveKudosBtnTapped:(id)sender {
    UIButton * senderButton=(UIButton*)sender;
    bool selected=!senderButton.selected;
    Activity * activity=[self.parentVC.activityArray objectAtIndex:[sender tag]];
    Location * location=activity.activity_location;
    NSMutableArray * kudoArray=[[NSMutableArray alloc] init];
    if(location.kudos!=nil)
        kudoArray=location.kudos;
    NSMutableDictionary *kudoItem=[[NSMutableDictionary alloc]init];
    [kudoItem setObject:self.parentVC.current_user_id forKey:@"id"];
    double date =[[NSDate date]timeIntervalSince1970];
    NSString *dateString=[NSString stringWithFormat:@"%f",date];
    [kudoItem setObject:dateString forKey:@"time"];
    
    if(selected)
        [kudoArray addObject:kudoItem];
    else
    {
        if(kudoArray!=nil)
        {
            for(NSDictionary *kudo_gaver in kudoArray)
            {
                if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.parentVC.current_user_id])
                {
                    [kudoArray removeObject:kudo_gaver];
                    break;
                }
            }
        }
    }
    if([kudoArray count]!=0)
        location.kudos=[[NSMutableArray alloc] initWithArray:kudoArray];
    else
        location.kudos=nil;
    senderButton.enabled=NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
    updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
    
    [[dynamoDBObjectMapper save:location configuration:updateMapperConfig]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             senderButton.enabled=YES;
             [self.parentVC updateCell];
         }
         
         return nil;
     }];
}

@end
