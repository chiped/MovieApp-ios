#define APIKEY @"?api_key=<your_api_key_here>"
#define BASE_URL @"http://api.themoviedb.org/3/movie/"
#define IMAGE_BASE_URL @"http://image.tmdb.org/t/p/"
#define SMALL_IMAGE_SIZE @"w92"
#define LARGE_IMAGE_SIZE @"w342"
#define PROFILE_IMAGE_SIZE @"w45"
#define TYPE_ARRAY @[@"now_playing", @"top_rated", @"upcoming", @"popular"]
#define TITLE_ARRAY @[@"Now Playing", @"Top Rated", @"Upcoming", @"Popular"]

@interface Constants : NSObject

+(NSString *) getURLString:(int) type;

@end
