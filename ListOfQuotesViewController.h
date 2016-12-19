//
//  ListOfQuotesViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EditQuotationViewController.h"


@class Quotation;


@interface ListOfQuotesViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>


@property (nonatomic, strong) EditQuotationViewController *editQuotationViewController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) IBOutlet UIImageView *background;
@property (nonatomic, strong) Quotation* selectedQuotation;

- (void)addRecord:(id)sender;



@end
