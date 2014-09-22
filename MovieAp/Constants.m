#import "Constants.h"

@implementation Constants

+(NSString *) getURLString:(int)type
{
    return [NSString stringWithFormat:@"%@%@%@", BASE_URL, [TYPE_ARRAY objectAtIndex:type], APIKEY];
}

+ (NSString *) stringByJoiningArray:(NSArray *)array with:(NSString *)separator
{
    NSString *returnString =@"";
    for(int i=0;i<array.count; i++) {
        returnString = [returnString stringByAppendingString:[array[i] objectForKey:@"name"]];
        if(i!=array.count-1)
            returnString = [returnString stringByAppendingString:separator];
    }
    return returnString;
}

@end

