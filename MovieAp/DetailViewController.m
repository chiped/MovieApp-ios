//
//  DetailViewController.m
//  MovieAp
//
//  Created by ChiP on 9/4/14.
//  Copyright (c) 2014 organization. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () {
    NSMutableArray *_objects;
    dispatch_queue_t castImagesQueue;
    dispatch_queue_t downloadDataQueue;
    NSMutableDictionary *castImageList;
}
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailsViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productionsLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productionsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *genresLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *genresHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *languagesLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *languagesHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationsLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *castLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *plotScrollerHeight;
- (void)configureView;

@end

@implementation DetailViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cast" forIndexPath:indexPath];
    
    Cast *object = _objects[indexPath.row];
    cell.textLabel.text = [object name];
    cell.detailTextLabel.text = [object role];
    cell.imageView.image = castImageList[indexPath];
    
    if(!castImageList[indexPath]) {
        dispatch_async(castImagesQueue, ^{
            __block UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[object photoURL]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
                if(!image) {
                    image = [UIImage imageNamed:@"noImage"];
                }
                newCell.imageView.image = image;
                [castImageList setObject:image forKey:indexPath];
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    }
    
    return cell;
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if(!castImagesQueue)
        castImagesQueue = dispatch_queue_create("castImageLoading", NULL);
    
    if(!downloadDataQueue)
        downloadDataQueue = dispatch_queue_create("downloadData", NULL);

    if (self.movie) {
        self.name.text = [self.movie title];
        self.title = [self.movie title];
        self.year.text = [self.movie date];
        self.rating.text = [self.movie rating];
        
        [[self detailsView] setHidden:YES];
        [[self activityView] setHidden:NO];
                
        [[self activityView] startAnimating];
        __block NSData *data;
        __block NSError *error=nil;
        
        dispatch_async(downloadDataQueue, ^{
            data=[NSData dataWithContentsOfURL:[self.movie getMovieDetailsURL]];
            NSDictionary *jsonobject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSArray *genres = [jsonobject objectForKey:@"genres"];
            NSString *genreString =@"";
            for(int i=0;i<[genres count]; i++) {
                genreString = [genreString stringByAppendingString:[genres[i] objectForKey:@"name"]];
                if(i!=[genres count]-1)
                    genreString = [genreString stringByAppendingString:@","];
            }
            
            NSArray *productions = [jsonobject objectForKey:@"production_companies"];
            NSString *productionString =@"";
            for(int i=0;i<[productions count]; i++) {
                productionString = [productionString stringByAppendingString:[productions[i] objectForKey:@"name"]];
                if(i!=[productions count]-1)
                    productionString = [productionString stringByAppendingString:@","];
            }
            
            NSArray *languages = [jsonobject objectForKey:@"spoken_languages"];
            NSString *languageString =@"";
            for(int i=0;i<[languages count]; i++) {
                languageString = [languageString stringByAppendingString:[languages[i] objectForKey:@"name"]];
                if(i!=[languages count]-1)
                    languageString = [languageString stringByAppendingString:@","];
            }
            
            NSArray *countries = [jsonobject objectForKey:@"production_countries"];
            NSString *countryString =@"";
            for(int i=0;i<[countries count]; i++) {
                countryString = [countryString stringByAppendingString:[countries[i] objectForKey:@"name"]];
                if(i!=[countries count]-1)
                    countryString = [countryString stringByAppendingString:@","];
            }
            
            //fill cast deatils
            NSData *castdata=[NSData dataWithContentsOfURL:self.movie.castURL];
            error=nil;
            NSDictionary *castobject = [NSJSONSerialization JSONObjectWithData:castdata options:kNilOptions error:&error];
            
            NSArray *casts = [castobject objectForKey:@"cast"];
            _objects = [[NSMutableArray alloc] init];
            for(id cast in casts) {
                [_objects addObject:[[Cast alloc] initWithJSON:cast]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.poster.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [self.movie getLargePosterURL]]];
                
                if(!self.poster.image) {
                    self.imageHeight.constant = 0;
                }
                self.plot.text = [jsonobject objectForKey:@"overview"];
                [self.plot sizeToFit];
                
                if(self.plot.frame.size.height < self.plotScrollerHeight.constant) {
                    self.plotScrollerHeight.constant = self.plot.frame.size.height;
                }
                
                self.genres.text = genreString;
                [self.genres sizeToFit];
                self.productions.text = productionString;
                [self.productions sizeToFit];
                self.languages.text = languageString;
                [self.languages sizeToFit];
                self.locaitons.text = countryString;
                [self.locaitons sizeToFit];
                
                [[self castTable] reloadData];
                
                
                self.genresHeight.constant = self.genres.frame.size.height;
                if([genreString isEqualToString:@""]) {
                    self.genresLabelHeight.constant = 0;
                }
                self.productionsHeight.constant = self.productions.frame.size.height;
                if([productionString isEqualToString:@""])
                {
                    self.productionsLabelHeight.constant = 0;
                }
                self.locationsHeight.constant = self.locaitons.frame.size.height;
                if([countryString isEqualToString:@""]) {
                    self.locationsLabelHeight.constant = 0;
                }
                self.languagesHeight.constant = self.languages.frame.size.height;
                if([languageString isEqualToString:@""]) {
                    self.languagesLabelHeight.constant = 0;
                }
                if(_objects.count == 0) {
                    self.castLabelHeight.constant = 0;
                }
                
                self.castTableHeight.constant = [self castTable].contentSize.height;
                self.detailsViewHeight.constant = self.castTable.frame.origin.y + self.castTable.contentSize.height + 8;
                
                [[self detailsView] setHidden:NO];
                [[self activityView] setHidden:YES];
            });
        });
        [[self outerScrollView] setContentSize:CGSizeMake(320, 500)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    castImageList = [[NSMutableDictionary alloc] initWithCapacity:10];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
