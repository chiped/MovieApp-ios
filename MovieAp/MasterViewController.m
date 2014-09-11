//
//  MasterViewController.m
//  MovieAp
//
//  Created by ChiP on 9/4/14.
//  Copyright (c) 2014 organization. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
    NSMutableArray *filteredResults;
    Constants *constants;
    dispatch_queue_t getMovieImages;
    dispatch_queue_t getMovieList;
    NSMutableDictionary *movieImagesList;
    int page;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    page = 1;
    
    if(!getMovieImages)
        getMovieImages = dispatch_queue_create("get movie images", NULL);
    
    if(!getMovieList)
        getMovieList = dispatch_queue_create("get movie list", NULL);
    
    [[self mainView] setHidden:YES];
    [[self indicator] setHidden:NO];
    [[self indicator] startAnimating];

    [self.searchDisplayController.searchResultsTableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"result cell"];
    
    NSString *str=[Constants getURLString:[self type]];
    NSURL *url=[NSURL URLWithString:str];
    __block NSData *data;
    
    _objects = [[NSMutableArray alloc] init];
    
    dispatch_async(getMovieList, ^{
        data =[NSData dataWithContentsOfURL:url];
        movieImagesList = [[NSMutableDictionary alloc] initWithCapacity:20];
        
        NSError *error=nil;
        NSDictionary *jsonobject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSArray *movies = [jsonobject objectForKey:@"results"];
        
        for(id movie in movies)
        {
            [_objects addObject:[[Movie alloc] initWithJSON:movie]];
        }
        //[NSThread sleepForTimeInterval:5];
        
        filteredResults = [NSMutableArray arrayWithArray:_objects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self tableView] reloadData];
            [[self mainView] setHidden:NO];
            [[self indicator] setHidden:YES];
            [[self indicator] startAnimating];
        });
    });
    
    [self setTitle:[[Constants getTitleArray] objectAtIndex:[self type]]];
}

-(void)filterContentForSearchText: (NSString*)searchText scope:(NSString*)scope
{
    [filteredResults removeAllObjects];
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if(searchText.length == 0) {
        filteredResults = [NSMutableArray arrayWithArray:_objects] ;
        return;
    }
    NSPredicate *basicPredicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[c] %@", searchText];
    NSLog(@"SELF.title MATCHES '.*(%@).*'", searchText);
    
    NSPredicate *advancedPredicate = [[NSPredicate alloc]init];
    NSArray *words = [searchText componentsSeparatedByString:@" "];
    for(NSString *word in words) {
        if(word.length > 0) {
            advancedPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"SELF.title CONTAINS[c] %@", word]]];
        }
    }
    
    filteredResults = [NSMutableArray arrayWithArray:[_objects filteredArrayUsingPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:@[basicPredicate, advancedPredicate]]]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]] ];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return filteredResults.count;
    }
    return _objects.count;
}

- (TableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell;
    Movie *object;
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"result cell" forIndexPath:indexPath];
        object = filteredResults[indexPath.row];
        cell.textLabel.text = object.title;
        cell.imageView.image = movieImagesList[object.movieId];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        object = _objects[indexPath.row];
    }
    
    cell.name.text = [object title];
    cell.rating.text = [object rating];
    cell.year.text = [object date];
    
    cell.poster.image = movieImagesList[object.movieId];
    
    if(!movieImagesList[indexPath]) {
        dispatch_async(getMovieImages, ^{
            __block UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [object getSmallPosterURL]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                TableViewCell *newcell = (TableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                if(!image) {
                    image = [UIImage imageNamed:@"noImage"];
                }
                newcell.poster.image = image;
                [movieImagesList setObject:image forKey:object.movieId];
            });
        });
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
*/
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"showDetail" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath;
    Movie *object;
    if([self.searchDisplayController isActive]) {
        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        object = filteredResults[indexPath.row];
    } else {
        indexPath = [self.tableView indexPathForSelectedRow];
        object = _objects[indexPath.row];
    }
    [[segue destinationViewController] setMovie:object];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrolOffset = scrollView.contentOffset.y;
    if(scrolOffset+scrollViewHeight == scrollContentSizeHeight)
    {
        
        page++;
        NSString *str=[NSString stringWithFormat:@"%@%@%d", [Constants getURLString:[self type]], @"&page=", page];
        
        __block NSURL *url=[NSURL URLWithString:str];
        
        dispatch_async(getMovieList, ^{
            NSData *data=[NSData dataWithContentsOfURL:url];
            NSError *error=nil;
            
            NSDictionary *jsonobject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSArray *movies = [jsonobject objectForKey:@"results"];
            
            for(id movie in movies)
            {
                [_objects addObject:[[Movie alloc] initWithJSON:movie]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{                
                [self.tableView reloadData];
            });
        
        });
    }
    
}
@end
