//
//  DetailViewController.h
//  MovieAp
//
//  Created by ChiP on 9/4/14.
//  Copyright (c) 2014 organization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"
#import "Cast.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic, readwrite) Movie *movie;

@end
