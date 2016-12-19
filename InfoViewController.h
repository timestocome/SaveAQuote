//
//  InfoViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "Quotation.h"


@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    int iCloudOn;
}


@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, weak) IBOutlet UIImageView *background;

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSArray* categoriesArray;
@property (nonatomic, strong) NSString* selectedCategory;
@property (nonatomic, weak) IBOutlet UIPickerView* pickerView;

-(IBAction)emailSupport:(id)sender;
-(IBAction)gift:(id)sender;
-(IBAction)share:(id)sender;
-(IBAction)rate:(id)sender;



@end
