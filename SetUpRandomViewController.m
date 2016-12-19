//
//  SetUpRandomViewController.m
//  SaveAQuote
//
//  Created by Linda Cobb on 2/10/14.
//
//

#import "SetUpRandomViewController.h"
#import "AppDelegate.h"



@implementation SetUpRandomViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self categoryList];
   
    _defaults = [NSUserDefaults standardUserDefaults];
    
    alertsOn = [[self.defaults objectForKey:@"alertsOn"] intValue];
	[self.quoteAlertsSwitch setOn:alertsOn];
    
    notificationTime = [[self.defaults objectForKey:@"notificationTime"] intValue];
    [self.notificationTimeLabel setText:[NSString stringWithFormat:@"%d", notificationTime]];
    
    [self.notificationTimeSlider setValue:notificationTime];
    
    NSString* previousCategory = [self.defaults objectForKey:@"category"];
    int row = (int)[self.categoriesArray indexOfObject:previousCategory];
    if ( row > 0 && row < self.categoriesArray.count ){
        [self.pickerView selectRow:row inComponent:0 animated:YES];
    }
    
    
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




-(IBAction)changeNotificationTime:(id)sender
{
    notificationTime = [self.notificationTimeSlider value];
    [self.notificationTimeLabel setText:[NSString stringWithFormat:@"%d", notificationTime]];
    [self.defaults setObject:[NSNumber numberWithInt:notificationTime] forKey:@"notificationTime"];
}




-(IBAction)alertsChanged:(id)sender
{
	if ( self.quoteAlertsSwitch.on == YES ){
		[self.defaults setObject:[NSNumber numberWithInt:1] forKey:@"alertsOn"];
        
        
        // None of the code should even be compiled unless the Base SDK is iOS 8.0 or later
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        
        UIApplication *application = [UIApplication sharedApplication];
        
        // The following line must only run under iOS 8. This runtime check prevents
        
        
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
        #endif
	}else {
		[self.defaults setObject:[NSNumber numberWithInt:0] forKey:@"alertsOn"];
	}
}




//  fetch user categories
-(IBAction)categoryList
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
    [objectsArray addObject:@"All"];
    
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
    // save category to defaults
    [self.defaults setObject:[self.categoriesArray objectAtIndex:row] forKey:@"category"];
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




- (void)viewWillDisappear:(BOOL)animated
{
    
    [self.defaults synchronize];
    
    NSLog(@"Alerts on? %d, alert time %d, alert category %@", [[self.defaults objectForKey:@"alertsOn"] intValue], [[self.defaults objectForKey:@"notificationTime"] intValue], [self.defaults objectForKey:@"category"]);

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
	if ( self.quoteAlertsSwitch.on == YES ){
        [appDelegate reloadAlerts];
	}else {
        [appDelegate removeAlerts];
	}
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
