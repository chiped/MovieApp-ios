#import "MasterViewController.h"
#import "DetailViewController.h"
#import "DetailsViewController.h"

@interface MasterViewController () {
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UISwitch *layoutSwitch;
@property (strong, nonatomic) NSMutableArray *movieItems;
@property (strong, nonatomic) NSMutableArray *filteredResults;
@property (strong, nonatomic) dispatch_queue_t getMovieImages;
@property (strong, nonatomic) dispatch_queue_t getMovieList;
@property (strong, nonatomic) NSMutableDictionary *movieImagesList;
@property (nonatomic) int page;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.page = 1;
    
    if(!self.getMovieImages)
        self.getMovieImages = dispatch_queue_create("get movie images", NULL);
    
    if(!self.getMovieList)
        self.getMovieList = dispatch_queue_create("get movie list", NULL);
    
    [self.mainView setHidden:YES];
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
    [self setTitle:[TITLE_ARRAY objectAtIndex:[self type]]];

    [self.searchDisplayController.searchResultsTableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"result cell"];
    
    self.movieItems = [[NSMutableArray alloc] init];
    self.movieImagesList = [[NSMutableDictionary alloc] initWithCapacity:20];
    
    [self downloadMovieList];
}

-(void)filterContentForSearchText: (NSString*)searchText scope:(NSString*)scope
{
    [self.filteredResults removeAllObjects];
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if(searchText.length == 0) {
        self.filteredResults = [NSMutableArray arrayWithArray:self.movieItems] ;
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[c] %@", searchText];
    
    NSArray *words = [searchText componentsSeparatedByString:@" "];
    for(NSString *word in words) {
        if(word.length > 0) {
            predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[c] %@", word]]];
        }
    }
    self.filteredResults = [NSMutableArray arrayWithArray:[self.movieItems filteredArrayUsingPredicate: predicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]] ];
    return YES;
}

#pragma mark - download stuff

-(void)downloadMovieList
{
    dispatch_async(self.getMovieList, ^{
        
        NSString *str=[NSString stringWithFormat:@"%@%@%d", [Constants getURLString:[self type]], @"&page=", self.page++];
        NSURL *url=[NSURL URLWithString:str];
        NSData *data =[NSData dataWithContentsOfURL:url];
        
        NSError *error=nil;
        NSDictionary *jsonobject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSArray *movies = [jsonobject objectForKey:@"results"];
        
        for(id movie in movies) {
            [self.movieItems addObject:[[Movie alloc] initWithJSON:movie]];
        }
        
        self.filteredResults = [NSMutableArray arrayWithArray:self.movieItems];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.mainView setHidden:NO];
            [self.indicator setHidden:YES];
            [self.indicator startAnimating];
        });
    });
}

- (void) downloadAndDisplayImageForMovie:(Movie *)movie inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(self.getMovieImages, ^{
        __block UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [movie getSmallPosterURL]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            TableViewCell *newcell = (TableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            if(!image) {
                image = [UIImage imageNamed:@"noImage"];
            }
            if(tableView == self.searchDisplayController.searchResultsTableView)
                newcell.imageView.image = image;
            else
                newcell.poster.image = image;
            [self.movieImagesList setObject:image forKey:movie.movieId];
        });
    });
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredResults.count;
    }
    return self.movieItems.count;
}

- (TableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell;
    Movie *movie;
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"result cell" forIndexPath:indexPath];
        movie = self.filteredResults[indexPath.row];
        cell.textLabel.text = movie.title;
        cell.imageView.image = self.movieImagesList[movie.movieId];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        movie = self.movieItems[indexPath.row];
    }
    
    cell.name.text = [movie title];
    cell.rating.text = [movie rating];
    cell.year.text = [movie date];
    cell.poster.image = self.movieImagesList[movie.movieId];
    
    if(!self.movieImagesList[movie.movieId]) {
        cell.poster.image = [UIImage imageNamed:@"noImage"];
        [self downloadAndDisplayImageForMovie:movie inTableView:tableView atIndexPath:indexPath];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.layoutSwitch isOn]) {
        [self performSegueWithIdentifier:@"showDetail" sender:self];
    } else {
        [self performSegueWithIdentifier:@"showOldDetail" sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath;
    Movie *movie;
    if([self.searchDisplayController isActive]) {
        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        movie = self.filteredResults[indexPath.row];
    } else {
        indexPath = [self.tableView indexPathForSelectedRow];
        movie = self.movieItems[indexPath.row];
    }
    [[segue destinationViewController] setMovie:movie];
}

#pragma mark reload more rows
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrolOffset = scrollView.contentOffset.y;
    if(scrolOffset+scrollViewHeight == scrollContentSizeHeight) {
        [self downloadMovieList];
    }    
}

@end