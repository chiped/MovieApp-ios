//
//  Constants.h
//  MovieAp
//
//  Created by ChiP on 9/4/14.
//  Copyright (c) 2014 organization. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject
+(NSString *) imageBaseURL;
+(NSString *) LARGE;
+(NSString *) SMALL;
+(NSString *) PROFILE;
+(NSString *) baseURL;
+(NSString *) getURLString:(int) type;
+(NSString *) APIKEY;
+(NSArray *) getTitleArray;
@end
