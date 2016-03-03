//
//  User.h
//  Clean the Creek
//
//  Created by Andy Johansson on 29/02/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#ifndef User_h
#define User_h
#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface User : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *user_id;

@property (nonatomic, strong) NSString *user_name;

@property (nonatomic, strong) NSMutableArray *followings;

@property (nonatomic, strong) NSMutableArray *followers;

@end

#endif /* User_h */
