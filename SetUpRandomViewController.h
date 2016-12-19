//
//  SetUpRandomViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 2/10/14.
//
//

#import <UIKit/UIKit.h>


@interface SetUpRandomViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    int iCloudOn;
    int alertsOn;
    int notificationTime;
}



@property (nonatomic, strong) NSUserDefaults *defaults;

@property (nonatomic, retain) IBOutlet UISlider *notificationTimeSlider;
@property (nonatomic, retain) IBOutlet UILabel *notificationTimeLabel;

@property (nonatomic, weak) IBOutlet UISwitch *quoteAlertsSwitch;

@property (nonatomic, weak) IBOutlet UIPickerView* pickerView;
@property (nonatomic, strong) NSArray* categoriesArray;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@property (nonatomic, weak) IBOutlet UIImageView *background;


-(IBAction)changeNotificationTime:(id)sender;
-(IBAction)alertsChanged:(id)sender;


@end
