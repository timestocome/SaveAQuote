//
//  InfoViewController.m
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
#import "AppDelegate.h"




@implementation InfoViewController






- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	_defaults = [NSUserDefaults standardUserDefaults];
    
    // parallax effect
    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @-30.0;
    interpolationHorizontal.maximumRelativeValue = @30.0;
    
    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @-30.0;
    interpolationVertical.maximumRelativeValue = @30.0;
    
    [self.background addMotionEffect:interpolationHorizontal];
    [self.background addMotionEffect:interpolationVertical];

    [self categoryList];
}





- (IBAction)emailSupport:(id)sender
{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			// send the email
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			            
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                [picker setSubject:[NSString stringWithFormat:@"Save a Quote V 9.10 iPad Request"]];
            }else{
                [picker setSubject:[NSString stringWithFormat:@"Save a Qutoe V 9.10 iPhone Request"]];
            }
			[picker setToRecipients:[NSArray arrayWithObject:@"timestocome@gmail.com"]];
			
            [self presentViewController:picker animated:YES completion:NULL];

			
		}else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Failed" message:@"Device unable to send email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Failed" message:@"Device unable to send email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
    
}



// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}







-(IBAction)gift:(id)sender
{
    NSString *GiftAppURL = [NSString stringWithFormat:@"itms-appss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=%d&productType=C&pricingParameter=STDQ&mt=8&ign-mscache=1", 403378939];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GiftAppURL]];
    
}


-(IBAction)share:(id)sender
{
    NSString *messageString = @"Save a Quote Link: itms-apps://itunes.apple.com/us/app/fit-test/id403378939?mt=8";
    NSArray *shareItem = @[messageString];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:shareItem applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
    
}


-(IBAction)rate:(id)sender
{
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id403378939"]];
    
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
    _selectedCategory = [self.categoriesArray objectAtIndex:row];
    [self.defaults setObject:self.selectedCategory forKey:@"randomCategory"];
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






@end
