#import "Movie.h"

@implementation Movie : NSObject

-(Movie *)initWithJSON:(NSDictionary *)object
{
    self = [super init];
    self.movieId = [NSString stringWithFormat:@"%@", [object objectForKey:@"id"]];
    self.title = [NSString stringWithFormat:@"%@", [object objectForKey:@"original_title"]];
    self.date = [NSString stringWithFormat:@"%@", [object objectForKey:@"release_date"]];
    NSDecimalNumber *avgRating = [object objectForKey:@"vote_average"];
    self.rating = [NSString stringWithFormat:@"%2.1f", avgRating.doubleValue];
    self.posterPath = [NSString stringWithFormat:@"%@", [object objectForKey:@"poster_path"]];
    self.castURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", BASE_URL, self.movieId, @"/credits", APIKEY]];
    return self;
}

-(NSURL *)getSmallPosterURL
{
    NSString *urlString;
    urlString = [NSString stringWithFormat:@"%@%@%@%@", IMAGE_BASE_URL, SMALL_IMAGE_SIZE, self.posterPath, APIKEY];
    return [NSURL URLWithString:urlString];
}

-(NSURL *)getLargePosterURL
{
    NSString *urlString;
    urlString = [NSString stringWithFormat:@"%@%@%@%@", IMAGE_BASE_URL, LARGE_IMAGE_SIZE, self.posterPath, APIKEY];
    return [NSURL URLWithString:urlString];
}

-(NSURL *)getMovieDetailsURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", BASE_URL, self.movieId, APIKEY]];
}

@end
