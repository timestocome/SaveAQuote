//
//  RandomQuoteViewController.m
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RandomQuoteViewController.h"
#import "AppDelegate.h"


@implementation RandomQuoteViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
          
    
    // swipe up fetches a new random quote for the user
	self.swipeGestureRecognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(getAnotherQuote)];
	self.swipeGestureRecognizerUp.direction = UISwipeGestureRecognizerDirectionUp;
	[self.view addGestureRecognizer:self.swipeGestureRecognizerUp];
	self.swipeGestureRecognizerUp.delegate = self;
    
    
    // tap does the same
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getAnotherQuote)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer.delegate = self;
    
    
    // parallax effect
    UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue = @-30.0;
    interpolationHorizontal.maximumRelativeValue = @30.0;
    
    UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = @-30.0;
    interpolationVertical.maximumRelativeValue = @30.0;
    
    [self.background addMotionEffect:interpolationHorizontal];
    [self.background addMotionEffect:interpolationVertical];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.quoteLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.sourceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

}



-(void)preferredContentSizeChanged:(NSNotification *)notification
{
    self.quoteLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.sourceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}




- (void)viewWillAppear:(BOOL)animated
{

    // update managedObject in case we've switched between iclould and local
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self reloadData];
    
	// load initital quote
	int count = (int)[self.quotationsArray count];
    Quotation *q;
	
	if ( count == 0 ){	// give user some help getting started
        
        // check for iCloud
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int iCloudOn = [[defaults objectForKey:@"iCloudOn"] intValue];

        if ( iCloudOn ){
            
            self.quote = @"\n\nGathering your thoughts from the cloud . . . .\n\n Random quotes will appear here once you have some quotes stored.\n\n To view a new quote swipe up.\n\n If you turn on random quotes in settings you will recieve a random alert with a quote about once a day.";
            self.source = @"";
            
        }else{        
            self.quote = @"\n\nEnter your quotes in Quotations.\n\nRandom quotes will show here once you have some quotes stored.\n\nTo view a new random quote, swipe up.\n\nIf you turn on random quotes in the settings you will recieve a random quote about once a day in an alert.\n\nTo use the iCloud to store your quotes turn it on in the settings view." ;
            self.source = @"";
		}
        
	}else{				// else load up users data
		double t = [[NSDate date] timeIntervalSince1970];
		int r = ((int)t) % count;
		
		q = (Quotation *)[self.quotationsArray objectAtIndex:r];
		self.quote = [q quote];
		self.source = [q source];
	}
    
    
    
    // check to see if user came here from a notification
    if ( appDelegate.notificationQuotation ){
        [self.quoteLabel setText:appDelegate.notificationQuotation.quote];
        [self.sourceLabel setText:appDelegate.notificationQuotation.source];
        _displayedQuotation = appDelegate.notificationQuotation;
    }else{
        [self.quoteLabel setText:self.quote];
        [self.sourceLabel setText:self.source];
        _displayedQuotation = q;
    }
    
	   
    // fade in
    [self.quoteLabel setAlpha:0.0];
    [self.sourceLabel setAlpha:0.0];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 1.0];
    
    [self.quoteLabel setAlpha:1.0];
    [self.sourceLabel setAlpha:1.0];
    
    [UIView commitAnimations];
    
}




-(void)reloadData
{
    
    //  fetch data **************************************************************
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quotation" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
    [request setFetchBatchSize:100];
    
    NSString* selectedCategory = [[NSUserDefaults standardUserDefaults] objectForKey:@"randomCategory"];
    if (selectedCategory == nil){
    }else if ( [selectedCategory compare:@"All"] == 0){
        
    }else{
        NSString *predicateString = [NSString stringWithFormat:@"category='%@'", selectedCategory];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    
    
	
	
	// load 'em up
	NSError *error; 
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) { NSLog (@"mutable array fetch fail");}		// Handle the error. 
	
	self.quotationsArray = [NSMutableArray arrayWithArray:mutableFetchResults];
}






-(IBAction)getAnotherQuote
{
    // obtain random quote
    int count = (int)[self.quotationsArray count];
	
	if ( count == 0 ){	// give user some help getting started
        self.quote = @"\n\nEnter your quotes in Quotations.\n\nRandom quotes will show here once you have some quotes stored.\n\nTo view a new random quote, swipe up.\n\nIf you turn on random quotes in the settings you will recieve a random quote about once a day in an alert.\n\nTo use the iCloud to store your quotes turn it on in the settings view." ;
        self.source = @"";
		
	}else{				// else load up users data
		
        int r = arc4random_uniform(count);
        
		Quotation *q = (Quotation *)[self.quotationsArray objectAtIndex:r];
		self.quote = [q quote];
		self.source = [q source];
	}
	

    
    // Change the text
     CATransition *animationIn = [CATransition animation];
    animationIn.duration = 2.0;
    animationIn.type = kCATransitionReveal;
    animationIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.quoteLabel.layer addAnimation:animationIn forKey:@"changeTextTransition"];
    [self.sourceLabel.layer addAnimation:animationIn forKey:@"changeTextTransistion"];
    
    self.quoteLabel.text = self.quote;
    [self.sourceLabel setText:self.source];
    

}






- (IBAction)editQuote:(id)sender
{
    
    // take user to proper detail view
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
    tabBarController.selectedViewController = [tabBarController.viewControllers objectAtIndex:1];
    
    UINavigationController *navigationController = [tabBarController.viewControllers objectAtIndex:1];
    ListOfQuotesViewController *listViewController = [navigationController.viewControllers objectAtIndex:0];
    
    [listViewController setSelectedQuotation:self.displayedQuotation];
    [listViewController performSegueWithIdentifier:@"showQuoteDetail" sender:self];

}




@end
