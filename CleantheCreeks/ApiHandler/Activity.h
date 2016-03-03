//
//  Activity.h
//  Clean the Creek
//
//  Created by Andy Johansson on 03/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#ifndef Activity_h
#define Activity_h
#import <Foundation/Foundation.h>
@interface Activity :NSObject

@property (nonatomic, strong) NSString * activity_time;

@property (nonatomic, strong) NSString *activity_type;
@property (nonatomic, strong) NSString *activity_location;

@end
#endif /* Activity_h */
