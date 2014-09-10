//
//  Cast.m
//  MovieAp
//
//  Created by ChiP on 9/4/14.
//  Copyright (c) 2014 organization. All rights reserved.
//

#import "Cast.h"

@implementation Cast
-(Cast *)initWithJSON:(NSDictionary *)object
{
    self = [super init];
    self.name = [object objectForKey:@"name"];
    self.role = [object objectForKey:@"character"];
    self.photoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", [Constants imageBaseURL], [Constants PROFILE], [object objectForKey:@"profile_path"], [Constants APIKEY]]] ;
    return self;
}
@end
