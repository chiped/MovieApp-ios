#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Movie : NSObject

@property (strong, nonatomic, readwrite) NSString *movieId;
@property (strong, nonatomic, readwrite) NSString *title;
@property (strong, nonatomic, readwrite) NSString *rating;
@property (strong, nonatomic, readwrite) NSString *date;
@property (strong, nonatomic, readwrite) NSString *posterPath;
@property (strong, nonatomic, readwrite) NSURL *castURL;

-(Movie *) initWithJSON:(NSDictionary *) object;
-(NSURL *) getSmallPosterURL;
-(NSURL *) getLargePosterURL;
-(NSURL *) getMovieDetailsURL;

@end
