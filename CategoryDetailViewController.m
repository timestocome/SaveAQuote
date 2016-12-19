//
//  CategoryDetailViewController.m
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryDetailViewController.h"
#import "AppDelegate.h"
#import "EditQuotationViewController.h"




@implementation CategoryDetailViewController


@synthesize managedObjectContext = __managedObjectContext;








- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // check for changes from iCloud
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"com.timestocomemobile.refetchData" object:nil];
    
    self.title = self.categoryType;

    [self reloadData];
}


- (void)viewDidLoad
{
    // parallax effect
    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @-30.0;
    interpolationHorizontal.maximumRelativeValue = @30.0;
    
    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @-30.0;
    interpolationVertical.maximumRelativeValue = @30.0;
    
    [self.background addMotionEffect:interpolationHorizontal];
    [self.background addMotionEffect:interpolationVertical];
    
    /// set up adjustable text
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

}



- (void)reloadData
{
        
	// fetch data
	self.managedObjectContext = self.managedObjectContext;
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	

	NSString *predicateString = [NSString stringWithFormat:@"category='%@'", self.categoryType];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	[request setPredicate:predicate];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quotation" inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity]; 
	
	
	// sort stored objects by type
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]; 
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil]; 
	[request setSortDescriptors:sortDescriptors]; 
		
	// load 'em up
	NSError *error; 
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy]; 
	if (mutableFetchResults == nil) { NSLog (@"mutable array fetch fail");}		// Handle the error. 
	
	//store results in local array
	[self setQuotationsArray:mutableFetchResults]; 
	

	[self.tableView reloadData];
}








- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.quotationsArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryQuoteCell"];
    
    UILabel *quoteLabel = (UILabel *)[cell viewWithTag:101];
    quoteLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    quoteLabel.text = [[self.quotationsArray objectAtIndex:indexPath.row]valueForKey:@"quote"];
    
    UILabel *sourceLabel = (UILabel *)[cell viewWithTag:102];
    sourceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    sourceLabel.text = [[self.quotationsArray objectAtIndex:indexPath.row] valueForKey:@"source"];
    
    return cell;
}




-(void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showQuote"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Quotation *quote = [self.quotationsArray objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setQuotation:quote];
        
    }
}









@end

