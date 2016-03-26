//
//  KudosVC.m
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "KudosVC.h"
#import "KudosCell.h"
#import "AppDelegate.h"
@interface KudosVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@end
@implementation KudosVC

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.profileTopBar setHeaderStyle:NO title:@"KUDOS" rightBtnHidden:YES];
    // Do any additional setup after loading the view.
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.kudoTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    [self updateData];
    self.kudoTable.estimatedRowHeight = 79.f;
    self.kudoTable.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) loadImage:(NSString*)user_id
{
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", user_id];
    
    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userImageURL]];
    if ( data == nil )
        return;
    [self.imageArray setObject:[UIImage imageWithData: data] forKey:user_id];
    [self.kudoTable reloadData];
}

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
}


-(void)updateData
{
    self.userArray=[[NSMutableArray alloc]init];
    
    self.imageArray=[[NSMutableDictionary alloc]init];
    [self.userArray removeAllObjects];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (User *user in paginatedOutput.items)
             {
                 for(NSMutableDictionary *kudo in self.location.kudos)
                 {
                     if([[kudo objectForKey:@"id"] isEqualToString:user.user_id])
                     {
                         [self.userArray addObject:user];
                         dispatch_async(dispatch_get_global_queue(0,0), ^{
                             [self loadImage:user.user_id];
                             
                         });
                     }
                 }
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.kudoTable reloadData];
                 [self.refreshControl endRefreshing];
                 
             });

            }
         return nil;
     }];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.location!=nil)
    {
        return [self.userArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    KudosCell *cell;
    
    if([self.userArray count]>0)
    {
        User * user=[self.userArray objectAtIndex:row];
        
        cell = (KudosCell*)[tableView dequeueReusableCellWithIdentifier:@"KudosCell" forIndexPath:indexPath];
        
        [cell.user_photo setImage:[self.imageArray objectForKey:user.user_id]];
        [cell.user_name setText:user.user_name];
        [cell.user_location setText:user.location];
        [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoSelect"] forState:UIControlStateNormal];
        [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoUnselect"] forState:UIControlStateSelected];
        for (NSMutableDictionary* following in user.followings)
        {
            NSString * user_id=[following objectForKey:@"id"];
            
            if([user_id isEqualToString:self.current_user_id])
            {
                
                [cell.likeButton setSelected:NO];
                break;
            }
        }
        cell.likeButton.tag=row;
        [cell.likeButton addTarget:self action:@selector(kudoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (cell == nil){
        return [[UITableViewCell alloc] init];
    }
    return cell;
}
-(void)kudoButtonClicked:(UIButton*)sender
{
    //[self.delegate giveKudoWithLocation:self.location assigned:!sender.selected];
    sender.selected=!sender.selected;
    
}

@end
