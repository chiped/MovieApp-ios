#import "Cast.h"

@implementation Cast

-(Cast *)initWithJSON:(NSDictionary *)object
{
    self = [super init];
    self.name = [object objectForKey:@"name"];
    self.role = [object objectForKey:@"character"];
    self.photoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", IMAGE_BASE_URL, PROFILE_IMAGE_SIZE, [object objectForKey:@"profile_path"], APIKEY]] ;
    return self;
}

@end
