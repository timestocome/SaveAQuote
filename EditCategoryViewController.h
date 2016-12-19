//
//  EditCategoryViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 3/14/14.
//
//

#import <UIKit/UIKit.h>

#import "Quotation.h"
#import "AppDelegate.h"


@interface EditCategoryViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField* textField;
@property (nonatomic, strong) IBOutlet UILabel* label;

@property (nonatomic, strong) NSString* updatedCategoryString;
@property (nonatomic, strong) NSString* oldCategoryString;


@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSArray* categoriesArray;

@property (nonatomic, strong) Quotation* quotation;
@property (nonatomic, strong) NSArray* quotationsArray;

@property (nonatomic, strong) IBOutlet UIPickerView* pickerView;




@property (nonatomic, weak) IBOutlet UIImageView* background;


@end
