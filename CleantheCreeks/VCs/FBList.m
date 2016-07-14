//
//  FBList.m
//  CTC
//
//  Created by Andy on 7/11/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "FBList.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "KudosCell.h"

@interface FBList ()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@end

@implementation FBList

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"FBFriends"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.profileTopBar setHeaderStyle:NO title:self.profile_user.user_name rightBtnHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.friendTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.current_user_id = [self.defaults objectForKey:@"user_id"];
    [self.refreshControl beginRefreshing];
    self.profileTopBar.rightBtn.enabled = NO;
    [self loadData];
    
}

-(void) loadData
{
//    self.friendsArray = [[NSMutableArray alloc]init];
//    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends" parameters:@{@"fields": @"id"} tokenString:[self.defaults objectForKey:@"fb_token"] version:nil HTTPMethod:@"GET"];
//    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//        // TODO: handle results or error of request.
//        self.friendsArray = (NSMutableArray*)result;
//        [self.refreshControl endRefreshing];
//        [self.friendTable reloadData];
//        
//    }];
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://www.mydomain.com/myapplink"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];
    
    // Present the dialog. Assumes self is a view controller
    // which implements the protocol `FBSDKAppInviteDialogDelegate`.
    [FBSDKAppInviteDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.friendsArray count]>0)
        return [self.friendsArray count];
    else
        return 0;
}

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITapGestureRecognizer *followTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProfile:)];
    followTap.numberOfTapsRequired=1;
    
    UITapGestureRecognizer *followTap2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProfile:)];
    followTap2.numberOfTapsRequired=1;
    KudosCell* cell = (KudosCell*)[tableView dequeueReusableCellWithIdentifier:@"KudosCell"];
    if([self.friendsArray count]>0)
    {
        
        NSDictionary * current_user=[self.friendsArray objectAtIndex:indexPath.row];
        NSDictionary * user_id=[current_user objectForKey:@"id"];
        User * user=[self.appDelegate.userArray objectForKey:user_id];
        
        [cell.user_photo setImage:[self.imageArray objectForKey:user.user_id]];
        
        if([self.imageArray objectForKey:user.user_id]!=nil)
        {
            [cell.user_photo setImage: [self.imageArray objectForKey:user.user_id]];
        }
        else
        {
            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", user.user_id];
            if([user.has_photo isEqualToString:@"yes"])
                userImageURL = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@", user.user_id];
            NSURL *url = [NSURL URLWithString:userImageURL];
            
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            {
                                [self.imageArray setObject:image forKey:user.user_id];
                                
                            }
                            if(cell)
                                [cell.user_photo setImage: image];
                        });
                    }
                }
            }];
            [task resume];
        }
        
        cell.likeButton.hidden = [user.user_id isEqualToString:self.current_user_id];
        [cell.user_name setText:user.user_name];
        [cell.user_location setText:[NSString stringWithFormat:@"%@, %@, %@", user.location, user.state, user.country]];
        cell.likeButton.tag = indexPath.row;
        [cell.likeButton addTarget:self action:@selector(likeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoSelect"] forState:UIControlStateNormal];
        [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoUnselect"] forState:UIControlStateSelected];
        
        [cell.user_photo addGestureRecognizer:followTap];
        cell.user_photo.userInteractionEnabled = YES;
        
        [cell.user_name addGestureRecognizer:followTap2];
        cell.user_name.userInteractionEnabled = YES;
        
        cell.user_photo.tag = indexPath.row;
        cell.user_name.tag = indexPath.row;
        if([AppDelegate isFollowing:user])
            cell.likeButton.selected = YES;
        else
            cell.likeButton.selected =NO;
    }
    if(!cell){
        cell = nil;
    }
    return cell;
}


@end
