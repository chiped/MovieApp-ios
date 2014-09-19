#import "Constants.h"

@implementation Constants

+(NSString *) getURLString:(int)type
{
    return [NSString stringWithFormat:@"%@%@%@", BASE_URL, [TYPE_ARRAY objectAtIndex:type], APIKEY];
}

@end

