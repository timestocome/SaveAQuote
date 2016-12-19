//
//  RandomQuoteViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "Quotation.h"
#import "EditQuotationViewController.h"
#import "ListOfQuotesViewController.h"




@interface RandomQuoteViewController : UIViewController <UIGestureRecognizerDelegate>



@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizerUp;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, weak) IBOutlet UILabel *quoteLabel;
@property (nonatomic, weak) IBOutlet UILabel *sourceLabel;

@property (nonatomic, weak) IBOutlet UIImageView *background;

@property (nonatomic, strong) NSString *quote;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSMutableArray *quotationsArray;
@property (nonatomic, strong) Quotation* displayedQuotation;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


-(IBAction)getAnotherQuote;

-(void)reloadData;
- (IBAction)editQuote:(id)sender;


@end
