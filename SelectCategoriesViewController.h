//
//  SelectCategoriesViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 2/10/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "Quotation.h"
#import "AppDelegate.h"



@class SelectCategoriesViewController;


@protocol SelectCategoriesViewControllerDelegate
- (void)selectCategoriesViewControllerDidFinish:(SelectCategoriesViewController *)controller;
@end




@interface SelectCategoriesViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) id <SelectCategoriesViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString* selectedCategory;

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSArray* categoriesArray;
@property (nonatomic, strong) Quotation* quotation;
@property (nonatomic, strong) IBOutlet UIPickerView* pickerView;

@property (nonatomic, weak) IBOutlet UIImageView *background;


- (IBAction)done:(id)sender;

@end
