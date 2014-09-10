//
//  Cast.h
//  MovieAp
//
//  Created by ChiP on 9/4/14.
//  Copyright (c) 2014 organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Cast : NSObject
@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) NSString *role;
@property (strong, nonatomic, readwrite) NSURL *photoURL;
-(Cast *)initWithJSON:(NSDictionary *) object;
@end
