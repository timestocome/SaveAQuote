//
//  ListOfQuotesViewController.m
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//




#import "ListOfQuotesViewController.h"
#import "Quotation.h"
#import "AppDelegate.h"
#import "RandomQuoteViewController.h"



@implementation ListOfQuotesViewController


@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

dispatch_queue_t mainQueue;







- (void)viewDidLoad
{
    [super viewDidLoad];

    
    UIBarButtonItem *addRecordItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addRecord:)];
    
    self.navigationItem.rightBarButtonItem = addRecordItem;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // listen for iCloud changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:@"com.timestocome.RefreshAllViews" object:[[UIApplication sharedApplication] delegate]];
    
    
    /// set up adjustable text
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    // load data
    NSArray *fetchedObjects = self.fetchedResultsController.fetchedObjects;
    
    
    // check for changes and reload data
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;

    
    self.searchResults = [fetchedObjects mutableCopy];


}




- (void)viewWillAppear:(BOOL)animated
{
    self.fetchedResultsController = nil;
    self.searchResults = nil;
    
    NSArray *fetchedObjects = self.fetchedResultsController.fetchedObjects;
    self.searchResults = [fetchedObjects mutableCopy];
    [self.tableView reloadData];
}




- (void)addRecord:(id)sender
{
    // move to edit screen
    if ( self.editQuotationViewController == NULL ){
        EditQuotationViewController *eqvc = [[EditQuotationViewController alloc] init];
        self.editQuotationViewController = eqvc;     
    }
        
    [self performSegueWithIdentifier:@"showQuoteDetail" sender:self];
}





- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil){ return __fetchedResultsController; }
    
    if ( !self.managedObjectContext ){
        // check for changes and reload data
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quotation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"source" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"quote" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]){
        NSLog(@"Unresolved error %@ %@", error, [error userInfo]);
    }
    
    NSArray *fetchedObjects = self.fetchedResultsController.fetchedObjects;
    self.searchResults = [fetchedObjects mutableCopy];

    
    return __fetchedResultsController;
}






- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
     //   NSLog(@"new table length %d", self.searchResults.count);
        return [self.searchResults count];
        
    }else{
        //return [self.searchResults count];
        return [[self.fetchedResultsController fetchedObjects]count];
    }

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    

    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        
        NSManagedObject *managedObject = [self.searchResults objectAtIndex:indexPath.row];
        
        UILabel *quoteLabel = (UILabel *)[cell viewWithTag:101];
        quoteLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        quoteLabel.text = [managedObject valueForKey:@"quote"];
        
        UILabel *sourceLabel = (UILabel *)[cell viewWithTag:102];
        sourceLabel.text = @"";
       // sourceLabel.text = [managedObject valueForKey:@"source"];
       // sourceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        
    }else{
        
       // NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSManagedObject *managedObject = [self.searchResults objectAtIndex:indexPath.row];

        
        UILabel *quoteLabel = (UILabel *)[cell viewWithTag:101];
        quoteLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        quoteLabel.text = [managedObject valueForKey:@"quote"];
        
        UILabel *sourceLabel = (UILabel *)[cell viewWithTag:102];
        quoteLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        sourceLabel.text = [managedObject valueForKey:@"source"];
        
    }

    return cell;
}



-(void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}





//// editing of table view
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath { return YES; }


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // delete from table and database
        //[self.managedObjectContext deleteObject:[self.searchResults objectAtIndex:indexPath.row]];
        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // save database changes
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];
    }   
}



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller { [self.tableView endUpdates]; }

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller { [self.tableView beginUpdates]; }


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
           [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
    }
}



- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;

    }
}




//// change to detail view for editing record
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        
        NSManagedObject *object = [self.searchResults objectAtIndex:indexPath.row];
        self.editQuotationViewController.quotation = (Quotation *)object;
        
    }else{
    
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.editQuotationViewController.quotation = (Quotation *)object;
    }

}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue identifier] isEqualToString:@"showQuoteDetail"]){

        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:(UITableViewCell *)sender];
     
        if ( [sender isKindOfClass:[RandomQuoteViewController class]]){
        
            [[segue destinationViewController] setQuotation:self.selectedQuotation];
        }else{
        
            if (indexPath != nil){
                [[segue destinationViewController] setQuotation:(Quotation *)[self.searchResults objectAtIndex:indexPath.row]];
            }else{
                NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
                [[segue destinationViewController] setQuotation:(Quotation *)[[self fetchedResultsController] objectAtIndexPath:indexPath]];
               // [[segue destinationViewController] setQuotation:(Quotation *)[self.searchResults objectAtIndex:indexPath.row]];

            }
        
        }
    }
}






- (void)reloadFetchedResults:(NSNotification*)note
{
    self.fetchedResultsController = nil;
    self.fetchedResultsController = [self fetchedResultsController];
    [self.tableView reloadData];
}













- (void)updateFilteredContentForSearchString:(NSString *)searchString
{
    //  seems to be only way around arc tossing data array out
    self.fetchedResultsController = nil;
    NSArray *tempResults = self.fetchedResultsController.fetchedObjects;
    

    
    // strip out all the leading and trailing spaces from search term
    NSString *strippedStr = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    if (strippedStr.length > 0){
        
        NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"self.quote CONTAINS[c] %@", strippedStr];
        
        tempResults = [tempResults filteredArrayUsingPredicate:sPredicate];
        
        // arc throws the array away if we do this
     //   self.searchResults = [[self.searchResults filteredArrayUsingPredicate:sPredicate] mutableCopy];

    }
    
    self.searchResults = [tempResults mutableCopy];
}





- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateFilteredContentForSearchString:searchString];
    
    return YES;
}






//// clean up 
- (void)viewDidUnload
{
    [super viewDidUnload];
}




-(void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}



@end

