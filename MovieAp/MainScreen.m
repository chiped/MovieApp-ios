#import "MainScreen.h"
#import "MasterViewController.h"

@interface MainScreen ()

@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) dispatch_queue_t checkInternetQueue;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainScreen

+(BOOL)hasConnectivity {
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if(data) {
        return YES;
    }
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.checkInternetQueue) {
        self.checkInternetQueue = dispatch_queue_create("check_internet", NULL);
    }
    [self.mainView setHidden:YES];
    [self.spinner setHidden:NO];
    [self.spinner startAnimating];
    
    dispatch_async(self.checkInternetQueue, ^{
        __block bool hasInternet = [MainScreen hasConnectivity];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!hasInternet) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                                message:@"You must be connected to the internet to use this app."
                                                               delegate:self
                                                      cancelButtonTitle:@"Close app"
                                                      otherButtonTitles:@"Retry", nil];
                [alert show];
            }
            [self.mainView setHidden:NO];
            [self.spinner setHidden:YES];
            [self.spinner stopAnimating];
        });
    });
    
    self.titles = TITLE_ARRAY;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        exit(0);
    } else {
        [self viewDidLoad];
    }
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"main" forIndexPath:indexPath];
    
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    MasterViewController *dest = [segue destinationViewController];
    [dest setType:indexPath.row];
}

@end