//
//  Movie.m
//  MovieAp
//
//  Created by ChiP on 9/4/14.
//  Copyright (c) 2014 organization. All rights reserved.
//

#import "Movie.h"

@implementation Movie : NSObject 
-(Movie *)initWithJSON:(NSDictionary *)object
{
    self = [super init];
    self.movieId = [NSString stringWithFormat:@"%@", [object objectForKey:@"id"]];
    self.title = [NSString stringWithFormat:@"%@", [object objectForKey:@"original_title"]];
    self.date = [NSString stringWithFormat:@"%@", [object objectForKey:@"release_date"]];
    self.rating = [NSString stringWithFormat:@"%@", [object objectForKey:@"vote_average"]];
    self.posterPath = [NSString stringWithFormat:@"%@", [object objectForKey:@"poster_path"]];
    self.castURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", [Constants baseURL], self.movieId, @"/credits", [Constants APIKEY]]];
    return self;
}
-(NSURL *)getSmallPosterURL
{
    NSString *urlString;
    
    urlString = [NSString stringWithFormat:@"%@%@%@%@", [Constants imageBaseURL], [Constants SMALL], self.posterPath, [Constants APIKEY]];
    
    return [NSURL URLWithString:urlString];
}
-(NSURL *)getLargePosterURL
{
    NSString *urlString;
    
    urlString = [NSString stringWithFormat:@"%@%@%@%@", [Constants imageBaseURL], [Constants LARGE], self.posterPath, [Constants APIKEY]];
    
    return [NSURL URLWithString:urlString];
}
-(NSURL *)getMovieDetailsURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [Constants baseURL], self.movieId, [Constants APIKEY]]];
}
@end
