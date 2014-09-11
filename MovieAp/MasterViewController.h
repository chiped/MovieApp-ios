//
//  MasterViewController.h
//  MovieAp
//
//  Created by ChiP on 9/4/14.
//  Copyright (c) 2014 organization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "TableViewCell.h"

@interface MasterViewController : UIViewController<UISearchDisplayDelegate, UITableViewDelegate>
@property (readwrite) int type;
@end
