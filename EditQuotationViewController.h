//
//  EditQuotationViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

#import "Quotation.h"
#import "SelectCategoriesViewController.h"


@interface EditQuotationViewController : UIViewController  <MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, SelectCategoriesViewControllerDelegate, UIPopoverControllerDelegate>
{
    CGRect  topFrame;
    CGRect  bottomFrame;
    int     rows;
}


@property (nonatomic, strong) UIPopoverController* selectCategoriesPopoverController;

@property (nonatomic, strong) Quotation *quotation;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UITextView *quotationTextView;
@property (nonatomic, weak) IBOutlet UITextField *sourceTextField;
@property (nonatomic, weak) IBOutlet UITextField *categoryTextField;
@property (nonatomic, weak) IBOutlet UIView *sourceCategoryView;

@property (nonatomic, strong) NSString *quotationString;
@property (nonatomic, strong) NSString *sourceString;
@property (nonatomic, strong) NSString *categoryString;

@property (nonatomic, weak) IBOutlet UIImageView *background;

@property (nonatomic, strong) IBOutlet UIButton* returnToQuoteButton;


- (IBAction)shareAlert:(id)sender;
- (void)saveQuote;

-(IBAction)sourceDidBeginEditing:(id)sender;
-(IBAction)categoryDidBeginEditing:(id)sender;

@end
