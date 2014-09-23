#import "Movie.h"
#import "Cast.h"

@interface DetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic, readwrite) Movie *movie;

@end