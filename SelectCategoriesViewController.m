//
//  SelectCategoriesViewController.m
//  SaveAQuote
//
//  Created by Linda Cobb on 2/10/14.
//
//

#import "SelectCategoriesViewController.h"




@implementation SelectCategoriesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    [self categoryList];
    
    // parallax effect
    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @-30.0;
    interpolationHorizontal.maximumRelativeValue = @30.0;
    
    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @-30.0;
    interpolationVertical.maximumRelativeValue = @30.0;
    
    [self.background addMotionEffect:interpolationHorizontal];
    [self.background addMotionEffect:interpolationVertical];
    
}



-(IBAction)categoryList
{
    //  fetch data
    
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
    _categoriesArray = [NSArray arrayWithArray:[uniqueCategories allObjects]];
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    self.categoriesArray = [self.categoriesArray sortedArrayUsingDescriptors:@[sd]];

    
}



- (NSInteger)selectedRowInComponent:(NSInteger)component
{
    return [self.pickerView selectedRowInComponent:component];
}




- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // send category string back to edit view
    // put category string in category box
    
    _selectedCategory = [self.categoriesArray objectAtIndex:row];
    
    [self done:self];
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.categoriesArray.count;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.categoriesArray objectAtIndex:row];
}



- (IBAction)done:(id)sender
{
    [self.delegate selectCategoriesViewControllerDidFinish:self];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
