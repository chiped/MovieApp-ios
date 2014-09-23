#import "DetailsViewController.h"
#import "PosterCell.h"
#import "CastCell.h"

#define POSTER_TITLE @"Poster"
#define OVERVIEW_TITLE @"Overview"
#define GENRE_TITLE @"Genre(s):"
#define PRODUCTION_TITLE @"Production(s):"
#define LANGUAGE_TITLE @"Language(s):"
#define LOCATION_TITLE @"Location(s):"
#define CAST_TITLE @"Cast"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (strong, nonatomic) NSMutableArray *castItems;
@property (strong, nonatomic) NSMutableDictionary *castImageList;
@property (strong, nonatomic) NSMutableArray *sectionHeaderTitles;
@property (strong, nonatomic) NSMutableArray *shouldHideRowsAtIndex;
@property (strong, nonatomic) dispatch_queue_t castImagesQueue;
@property (strong, nonatomic) dispatch_queue_t downloadDataQueue;
@property (strong, nonatomic) UIImage *poster;
@property (strong, nonatomic) NSMutableString *plotText;
@property (strong, nonatomic) NSString *genreString;
@property (strong, nonatomic) NSString *productionString;
@property (strong, nonatomic) NSString *languageString;
@property (strong, nonatomic) NSString *locationString;

@end

@implementation DetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.sectionHeaderTitles) {
        self.sectionHeaderTitles = [NSMutableArray arrayWithObjects:[NSNull null], POSTER_TITLE, OVERVIEW_TITLE, GENRE_TITLE, PRODUCTION_TITLE, LANGUAGE_TITLE, LOCATION_TITLE, CAST_TITLE, nil];
    }
    if(!self.shouldHideRowsAtIndex) {
        self.shouldHideRowsAtIndex  = [NSMutableArray arrayWithArray:@[@NO, @NO, @NO, @NO, @NO, @NO, @NO, @NO]];
    }
    self.castImageList = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    [self configureView];
}

- (void)configureView
{
    if(!self.castImagesQueue)
        self.castImagesQueue = dispatch_queue_create("castImageLoading", NULL);
    
    if(!self.downloadDataQueue)
        self.downloadDataQueue = dispatch_queue_create("downloadData", NULL);
    
    if (self.movie) {
        self.title = [self.movie title];
        
        [self.detailsView setHidden:YES];
        [self.spinner setHidden:NO];
        [self.spinner startAnimating];
        
        dispatch_async(self.downloadDataQueue, ^{            
            [self downloadMovieDetails];
            [self downloadCastDetails];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.detailsView setHidden:NO];
                [self.spinner setHidden:YES];
                [self.spinner stopAnimating];
            });
        });
    }
}

-(void) downloadMovieDetails
{
    NSData *data;
    NSError *error=nil;
    
    data=[NSData dataWithContentsOfURL:[self.movie getMovieDetailsURL]];
    NSDictionary *jsonobject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    self.poster = [UIImage imageWithData: [NSData dataWithContentsOfURL: [self.movie getLargePosterURL]]];
    if(!self.poster) {
        [self.sectionHeaderTitles removeObject:POSTER_TITLE];
    }
    self.plotText = [jsonobject objectForKey:@"overview"];
    if(!self.plotText || self.plotText.class == NSNull.class || [self.plotText isEqualToString:@""]) {
        [self.sectionHeaderTitles removeObject:OVERVIEW_TITLE];
    }
    
    NSArray *genres = [jsonobject objectForKey:@"genres"];
    self.genreString = [Constants stringByJoiningArray:genres with:@", "];
    if([self.genreString isEqualToString:@""]) {
        [self.sectionHeaderTitles removeObject:GENRE_TITLE];
    }
    
    NSArray *productions = [jsonobject objectForKey:@"production_companies"];
    self.productionString =[ Constants stringByJoiningArray:productions with:@", "];
    if([self.productionString isEqualToString:@""]) {
        [self.sectionHeaderTitles removeObject:PRODUCTION_TITLE];
    }
    
    NSArray *languages = [jsonobject objectForKey:@"spoken_languages"];
    self.languageString = [Constants stringByJoiningArray:languages with:@", "];
    if([self.languageString isEqualToString:@""]) {
        [self.sectionHeaderTitles removeObject:LANGUAGE_TITLE];
    }
    
    NSArray *countries = [jsonobject objectForKey:@"production_countries"];
    self.locationString = [Constants stringByJoiningArray:countries with:@", "];
    if([self.locationString isEqualToString:@""]) {
        [self.sectionHeaderTitles removeObject:LOCATION_TITLE];
    }

}

-(void) downloadCastDetails
{
    NSData *castdata=[NSData dataWithContentsOfURL:self.movie.castURL];
    NSError *error=nil;
    NSDictionary *castobject = [NSJSONSerialization JSONObjectWithData:castdata options:kNilOptions error:&error];
    
    NSArray *casts = [castobject objectForKey:@"cast"];
    self.castItems = [[NSMutableArray alloc] init];
    for(id cast in casts) {
        [self.castItems addObject:[[Cast alloc] initWithJSON:cast]];
    }
    if(self.castItems.count == 0) {
        [self.sectionHeaderTitles removeObject:CAST_TITLE];
    }
}

-(CGFloat)heightForHeaderRowAtIndexPath:(NSIndexPath *)indexPath
{
    float width = self.tableView.frame.size.width;
    if(indexPath.section == 0) {
        return [self heightByAdjustingString:self.movie.title toWidth:width];
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:POSTER_TITLE]) {
        float height = MAX([UIImage imageNamed:@"expandIcon"].size.height, 20);
        return height + 8;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:OVERVIEW_TITLE]) {
        float height = MAX([UIImage imageNamed:@"expandIcon"].size.height, 20);
        return height + 8;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:GENRE_TITLE]) {
        float height = MAX([UIImage imageNamed:@"expandIcon"].size.height, 20);
        return height + 8;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:PRODUCTION_TITLE]) {
        float height = MAX([UIImage imageNamed:@"expandIcon"].size.height, 20);
        return height + 8;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:LANGUAGE_TITLE]) {
        float height = MAX([UIImage imageNamed:@"expandIcon"].size.height, 20);
        return height + 8;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:LOCATION_TITLE]) {
        float height = MAX([UIImage imageNamed:@"expandIcon"].size.height, 20);
        return height + 8;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:CAST_TITLE])  {
        float height = MAX([UIImage imageNamed:@"expandIcon"].size.height, 20);
        return height + 8;
    } else {
        return 0;
    }
}

-(CGFloat)heightForActuaLRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    float width = self.tableView.frame.size.width;
    if(indexPath.section == 0) {
        height =  25;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:POSTER_TITLE]) {
        if(self.poster) {
            height = 216;
        }
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:OVERVIEW_TITLE]) {
        height = [self heightByAdjustingString:self.plotText toWidth:width];
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:GENRE_TITLE]) {
        height = [self heightByAdjustingString:self.genreString toWidth:width];
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:PRODUCTION_TITLE]) {
        height = [self heightByAdjustingString:self.productionString toWidth:width];
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:LANGUAGE_TITLE]) {
        height = [self heightByAdjustingString:self.languageString toWidth:width];
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:LOCATION_TITLE]) {
        height = [self heightByAdjustingString:self.locationString toWidth:width];
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:CAST_TITLE]) {
        width = (self.tableView.frame.size.width - 16 - 30 - 4 - 16)/2.0 - 2;
        Cast *cast = self.castItems[indexPath.row-1];
        float nameHeight = [self heightByAdjustingString:cast.name toWidth:width];
        float roleHeight = [self heightByAdjustingString:cast.role toWidth:width];
        height = MAX(40, MAX(nameHeight, roleHeight)) + 8;
    }
    return height;
}

-(CGFloat) heightByAdjustingString:(NSString *)string toWidth:(CGFloat)width
{
    CGRect size = [string
                   boundingRectWithSize:CGSizeMake(width, 999)
                   options:NSStringDrawingUsesLineFragmentOrigin
                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f]}
                   context:nil];
    return size.size.height;
}

-(UITableViewCell *)cellForHeaderRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"detailsCell"];
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    if(indexPath.section == 0) {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.movie.title;
    } else {
        if([self.shouldHideRowsAtIndex[indexPath.section] boolValue])
            cell.imageView.image = [UIImage imageNamed:@"expandIcon"];
        else
            cell.imageView.image = [UIImage imageNamed:@"collapseIcon"];
        cell.textLabel.text = self.sectionHeaderTitles[indexPath.section];
    }
    return cell;
}

-(UITableViewCell *)cellForCastRowAtIndexPath:(NSIndexPath *)indexPath
{
    CastCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"castCell"];
    cell.imageView.image = nil;
    Cast *cast = self.castItems[indexPath.row-1];
    cell.nameLabel.text = cast.name;
    cell.roleLabel.text = cast.role;
    cell.castImage.image = self.castImageList[indexPath];
    if(!self.castImageList[indexPath]) {
        cell.imageView.image = [UIImage imageNamed:@"noImage"];
        dispatch_async(self.castImagesQueue, ^{
            __block UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[cast photoURL]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                CastCell *newCell = (CastCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                if(!image) {
                    image = [UIImage imageNamed:@"noImage"];
                }
                newCell.castImage.image = image;
                [self.castImageList setObject:image forKey:indexPath];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    } //end if no image
    return cell;
}

-(UITableViewCell *)cellForActualRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"detailsCell"];
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    if (indexPath.section == 0) {
        cell.textLabel.text = self.movie.date;
        cell.detailTextLabel.text = self.movie.rating;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:POSTER_TITLE]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"posterCell"];
        ((PosterCell *)cell).posterImage.image = self.poster;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:OVERVIEW_TITLE]) {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.plotText;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:GENRE_TITLE]) {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.genreString;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:PRODUCTION_TITLE]) {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.productionString;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:LANGUAGE_TITLE])  {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.languageString;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:LOCATION_TITLE]) {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.locationString;
    } else if(indexPath.section == [self.sectionHeaderTitles indexOfObject:CAST_TITLE]) {
        cell = [self cellForCastRowAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - Table view methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        return [self heightForHeaderRowAtIndexPath:indexPath];
    } else {
        return [self heightForActuaLRowAtIndexPath:indexPath];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        return [self cellForHeaderRowAtIndexPath:indexPath];
    } else {
        return [self cellForActualRowAtIndexPath:indexPath];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 10.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 10, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+5, bounds.size.height-lineHeight, bounds.size.width-5, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionHeaderTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section > 0 && [self.shouldHideRowsAtIndex[section] boolValue])
        return 1;
    if(section == [self.sectionHeaderTitles indexOfObject:CAST_TITLE]) {
        return self.castItems.count + 1;
    }
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section > 0 && indexPath.row == 0) {
        if([self.shouldHideRowsAtIndex[indexPath.section] boolValue]) {
            self.shouldHideRowsAtIndex[indexPath.section] = @NO;
        } else {
            self.shouldHideRowsAtIndex[indexPath.section] = @YES;
        }
        [tableView reloadData];
    }
}

@end
