//
//  Constants.m
//  MovieAp
//
//  Created by ChiP on 9/4/14.
//  Copyright (c) 2014 organization. All rights reserved.
//

#import "Constants.h"

@interface Constants () {
    
}

@end

@implementation Constants

+(NSString *)APIKEY
{
    return @"?api_key=<your apikey here>";
}

+(NSString *)baseURL
{
    return @"http://api.themoviedb.org/3/movie/";
}

+(NSString *)nowPlaying
{
    return @"now_playing";
}

+(NSString *)topRated
{
    return @"top_rated";
}

+(NSString *)upcoming
{
    return @"upcoming";
}

+(NSString *)popular
{
    return @"popular";
}

+(NSString *)imageBaseURL
{
    return @"http://image.tmdb.org/t/p/";
}

+(NSString *)SMALL
{
    return @"w92";
}

+(NSString *)LARGE
{
    return @"w342";
}

+(NSString *)PROFILE
{
    return @"w45";
}

+(NSArray *) getTypeArray
{
    static NSArray *array;
    if(array == NULL)
        array = [NSArray arrayWithObjects:@"now_playing", @"top_rated", @"upcoming", @"popular", nil];
    return array;
}

+(NSArray *) getTitleArray
{
    static NSArray *array;
    if(array == NULL)
        array = [NSArray arrayWithObjects:@"Now Playing", @"Top Rated", @"Upcoming", @"Popular", nil];
    return array;
}

+(NSString *) getURLString:(int)type
{
    return [NSString stringWithFormat:@"%@%@%@", [Constants baseURL], [[Constants getTypeArray] objectAtIndex:type], [Constants APIKEY]];
    
}

@end

