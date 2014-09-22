#import "Movie.h"
#import "Cast.h"

@interface DetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic, readwrite) Movie *movie;

@end