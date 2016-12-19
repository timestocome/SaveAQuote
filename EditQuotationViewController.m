//
//  EditQuotationViewController.m
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditQuotationViewController.h"
#import "AppDelegate.h"



@implementation EditQuotationViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    self.sourceTextField.delegate = self;
    self.categoryTextField.delegate = self;
    self.quotationTextView.delegate = self;
    
    // update managedObject in case we've switched between iclould and local
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    // we added a new quote
    if ( self.quotation == NULL ){
        Quotation *q = (Quotation *)[NSEntityDescription insertNewObjectForEntityForName:@"Quotation" inManagedObjectContext:self.managedObjectContext];
        [self.quotation setDate:[NSDate date]];
        [self.quotation setSource:@""];
        [self.quotation setCategory:@""];
        [self.quotation setQuote:@"Quote"];
        
        
        self.quotation = q;
    }
    
    self.sourceString = [self.quotation source];
	self.quotationString = [self.quotation quote];
	self.categoryString = [self.quotation category];
    
    [self.sourceTextField setText:self.sourceString];
	[self.categoryTextField setText:self.categoryString];
	[self.quotationTextView setText:self.quotationString];
    
	
   	
    
    if ( self.view.bounds.size.height <= 500){
        bottomFrame = CGRectMake(10.0, -35.0, 300.0, 300.0);
        topFrame = CGRectMake(10.0, 65.0, 300.0, 300.0 );
    }else if ( self.view.bounds.size.height <= 568){
        bottomFrame = CGRectMake(10.0, 65.0, 300.0, 300.0);
        topFrame = CGRectMake(10.0, 65.0, 300.0, 300.0 );
    }else{
        NSLog(@"top and bottom frame not set");
    }
    
    
    
    // parallax effect
    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @-20.0;
    interpolationHorizontal.maximumRelativeValue = @20.0;
    
    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @-20.0;
    interpolationVertical.maximumRelativeValue = @20.0;
    
    [self.background addMotionEffect:interpolationHorizontal];
    [self.background addMotionEffect:interpolationVertical];
    
    
    // hide keyboard
    rows = 0;
    
    
    /// set up adjustable text
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.quotationTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.sourceTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.categoryTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    
}





-(void)preferredContentSizeChanged:(NSNotification *)notification
{
    self.quotationTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.sourceTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.categoryTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}





- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:1.0 animations:^{
        [self.sourceCategoryView setFrame:topFrame];
    }];
}




// dismiss keyboard from text view with return key
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        
        rows++;
        
        if ( rows >= 2 ){
            
            // resign text view
            [self.quotationTextView resignFirstResponder];
            
            return NO;
        }else{
            return YES;
        }
    }else{
        rows = 0;
    }
    
    
    return YES;
}


-(IBAction)sourceDidBeginEditing:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.sourceCategoryView setFrame:bottomFrame];
    }];
}



-(IBAction)categoryDidBeginEditing:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.sourceCategoryView setFrame:bottomFrame];
    }];
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.categoryTextField resignFirstResponder];
    [self.sourceTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.sourceCategoryView setFrame:topFrame];
    }];
    
    return YES;
}










- (void)selectCategoriesViewControllerDidFinish:(SelectCategoriesViewController *)controller
{
    [self.categoryTextField setText:controller.selectedCategory];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.selectCategoriesPopoverController dismissPopoverAnimated:YES];
        self.selectCategoriesPopoverController = nil;
    }
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.selectCategoriesPopoverController = nil;
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"categorySegue"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.selectCategoriesPopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}



- (IBAction)togglePopover:(id)sender
{
    if (self.selectCategoriesPopoverController) {
        [self.selectCategoriesPopoverController dismissPopoverAnimated:YES];
        self.selectCategoriesPopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"categorySegue" sender:sender];
    }
}




- (IBAction)shareAlert:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"%@\nSaveAQuote", [self.quotationTextView text]];
    NSArray *shareItem = @[message];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:shareItem applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}





- (void)saveQuote
{
    [self.quotation setDate:[NSDate date]];
	[self.quotation setSource:[self.sourceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[self.quotation setCategory:[self.categoryTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[self.quotation setQuote:[self.quotationTextView text]];
	
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}





- (void)viewWillDisappear:(BOOL)animated
{
    [self saveQuote];
}






@end
