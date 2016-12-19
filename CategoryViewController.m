//
//  CategoryViewController.m
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"
#import "AppDelegate.h"




@implementation CategoryViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {}
    
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    /// set up adjustable text
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getCategories];
	[self.tableView reloadData];
	
}



- (void)getCategories
{
    
	if ( !self.managedObjectContext ){
        // check for changes and reload data
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
    }
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quotation" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
    
	// sort stored objects by type
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	
	// load 'em up
	NSError *error;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) { NSLog (@"mutable array fetch fail");}		// Handle the error.
    
	// pull out unique types of categories
	int arrayItemsCount = (int)[mutableFetchResults count];
	NSMutableArray* objectsArray = [[NSMutableArray alloc] initWithCapacity:[mutableFetchResults count]];
    
	for ( int i=0; i<arrayItemsCount; i++){
		
		Quotation *quotation = [mutableFetchResults objectAtIndex:i];
		NSString *category = [quotation category];
        if ( category != nil){
            category = [category stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [objectsArray addObject:category];
        }
	}
    
    NSSet* uniqueCategories = [NSSet setWithArray:objectsArray];
    _sectionsArray = [NSArray arrayWithArray:[uniqueCategories allObjects]];
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    self.sectionsArray = [self.sectionsArray sortedArrayUsingDescriptors:@[sd]];

    
}








- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sectionsArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
  
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:101];
    categoryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    categoryLabel.text = [self.sectionsArray objectAtIndex:indexPath.row];
        
    return cell;
}


-(void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}






- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showQuotesInCategory"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *cat = [self.sectionsArray objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setCategoryType:cat];
    }
}




@end

