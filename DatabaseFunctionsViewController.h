//
//  DatabaseFunctionsViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 3/18/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AppDelegate.h"
#import "Quotation.h"


@interface DatabaseFunctionsViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    int iCloudOn;
}


@property (nonatomic, weak) IBOutlet UISwitch* iCloudSwitch;

- (void)removeTemporaryFiles;

- (IBAction)removeDuplicates:(id)sender;
- (IBAction)emailData:(id)sender;
- (IBAction)emailDatabase:(id)sender;
- (IBAction)iCloudSyncing:(id)sender;

- (void)removeMetadataFromLocalDatabase;




@end
