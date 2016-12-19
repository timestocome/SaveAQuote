//
//  CategoryViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CategoryDetailViewController.h"


@interface CategoryViewController : UITableViewController <NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) CategoryDetailViewController *categoryDetailViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *sectionsArray;
@property (strong, nonatomic) NSArray *categoriesArray;

@property (nonatomic, weak) IBOutlet UIImageView *background;



@end
