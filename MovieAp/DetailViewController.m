#import "DetailViewController.h"
#import "CastCell.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *outerScrollView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *year;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (weak, nonatomic) IBOutlet UILabel *plot;
@property (weak, nonatomic) IBOutlet UILabel *genres;
@property (weak, nonatomic) IBOutlet UILabel *languages;
@property (weak, nonatomic) IBOutlet UILabel *productions;
@property (weak, nonatomic) IBOutlet UILabel *locaitons;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UITableView *castTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *castTableHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productionsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *genresHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *languagesHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *castLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *plotScrollerHeight;
@property (weak, nonatomic) IBOutlet UINavigationBar *actualNavigationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *overviewHeight;
@property (strong, nonatomic) NSMutableArray *castItems;
@property (strong, nonatomic) dispatch_queue_t castImagesQueue;
@property (strong, nonatomic) dispatch_queue_t downloadDataQueue;
@property (strong, nonatomic) NSMutableDictionary *castImageList;
@property (strong, nonatomic) NSString *genreString;
@property (strong, nonatomic) NSString *productionString;
@property (strong, nonatomic) NSString *languageString;
@property (strong, nonatomic) NSString *locationString;
@property (strong, nonatomic) NSString *plotString;
@property (strong, nonatomic) UIImage *posterImage;

- (void)configureView;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.castImageList = [[NSMutableDictionary alloc] initWithCapacity:10];
    [self configureView];
}

- (void)configureView
{
    if(!self.castImagesQueue)
        self.castImagesQueue = dispatch_queue_create("castImageLoading", NULL);
    
    if(!self.downloadDataQueue)
        self.downloadDataQueue = dispatch_queue_create("downloadData", NULL);
    
    self.actualNavigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:nil action:@selector(backAction)];

    if (self.movie) {
        self.name.text = [self.movie title];
        self.title = [self.movie title];
        self.actualNavigationBar.topItem.title = [self.movie title];
        self.year.text = [self.movie date];
        self.rating.text = [self.movie rating];
        
        [self.detailsView setHidden:YES];
        [self.activityView setHidden:NO];
        [self.activityView startAnimating];
        
        dispatch_async(self.downloadDataQueue, ^{
            [self downloadMovieDetails];
            [self downloadCastDetails];
            [self displayData];
        });
        
    }
}

-(void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - downloads tuf

-(void)downloadMovieDetails
{
        NSData *data;
        NSError *error=nil;
        data=[NSData dataWithContentsOfURL:[self.movie getMovieDetailsURL]];
        NSDictionary *jsonobject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSArray *genres = [jsonobject objectForKey:@"genres"];
        self.genreString = [Constants stringByJoiningArray:genres with:@", "];
        
        NSArray *productions = [jsonobject objectForKey:@"production_companies"];
        self.productionString = [Constants stringByJoiningArray:productions with:@", "];
        
        NSArray *languages = [jsonobject objectForKey:@"spoken_languages"];
        self.languageString = [Constants stringByJoiningArray:languages with:@", "];
        
        NSArray *countries = [jsonobject objectForKey:@"production_countries"];
        self.locationString = [Constants stringByJoiningArray:countries with:@", "];
        
        self.posterImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: [self.movie getLargePosterURL]]];
        
        self.plotString = [jsonobject objectForKey:@"overview"];
}

-(void)downloadCastDetails
{
    NSData *castdata=[NSData dataWithContentsOfURL:self.movie.castURL];
    NSError *error=nil;
    NSDictionary *castobject = [NSJSONSerialization JSONObjectWithData:castdata options:kNilOptions error:&error];
    
    NSArray *casts = [castobject objectForKey:@"cast"];
    self.castItems = [[NSMutableArray alloc] init];
    for(id cast in casts) {
        [self.castItems addObject:[[Cast alloc] initWithJSON:cast]];
    }
}

-(void)displayData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.poster.image = self.posterImage;
        
        if(!self.poster.image) {
            self.imageHeight.constant = 0;
        }
        
        if(self.plotString.class != [NSNull class]) {
            self.plot.text = self.plotString;
        } else {
            self.overviewHeight.constant = 0;
        }
        [self.plot sizeToFit];
        
        if(self.plot.frame.size.height < self.plotScrollerHeight.constant) {
            self.plotScrollerHeight.constant = self.plot.frame.size.height;
        }
        
        self.genres.text = self.genreString;
        [self.genres sizeToFit];
        self.productions.text = self.productionString;
        [self.productions sizeToFit];
        self.languages.text = self.languageString;
        [self.languages sizeToFit];
        self.locaitons.text = self.languageString;
        [self.locaitons sizeToFit];
        
        if(self.castItems.count == 0) {
            self.castLabelHeight.constant = 0;
        }
        
        [self.castTable reloadData];
        
        self.genresHeight.constant = self.genres.frame.size.height;
        self.productionsHeight.constant = self.productions.frame.size.height;
        self.locationsHeight.constant = self.locaitons.frame.size.height;
        self.languagesHeight.constant = self.languages.frame.size.height;
        if(self.castTableHeight.constant > [self castTable].contentSize.height) {
            self.castTableHeight.constant = [self castTable].contentSize.height;
        }
        
        [self.detailsView setHidden:NO];
        [self.activityView setHidden:YES];
        [self.activityView stopAnimating];
    });
}

-(void)downloadAndDisplayImageForCast:(Cast *)cast inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(self.castImagesQueue, ^{
        __block UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[cast photoURL]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            CastCell *newCell = (CastCell *)[tableView cellForRowAtIndexPath:indexPath];
            if(!image) {
                image = [UIImage imageNamed:@"noImage"];
            }
            newCell.castImage.image = image;
            [self.castImageList setObject:image forKey:indexPath];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    });
}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.castItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CastCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cast" forIndexPath:indexPath];
    
    Cast *cast = self.castItems[indexPath.row];
    cell.nameLabel.text = cast.name;
    cell.roleLabel.text = cast.role;
    cell.castImage.image = self.castImageList[indexPath];
    
    if(!self.castImageList[indexPath]) {
        [self downloadAndDisplayImageForCast:cast inTableView:tableView atIndexPath:indexPath];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float width = (tableView.frame.size.width - 4 - 30 - 4 - 4)/2.0 - 2;
    Cast *cast = self.castItems[indexPath.row];
    float nameHeight = [self heightByAdjustingString:cast.name toWidth:width];
    float roleHeight = [self heightByAdjustingString:cast.role toWidth:width];
    float height = MAX(40, MAX(nameHeight, roleHeight)) + 8;
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

@end
