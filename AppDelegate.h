//
//  AppDelegate.h
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


// Current update
// Add ability to copy and replace database in iTunes



#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Quotation.h"

NSString* const UIShouldRefresh;



@interface AppDelegate : UIResponder <UIApplicationDelegate>



@property (strong, nonatomic) UIWindow *window;

// core data
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSDictionary* options;



// used for setting random alerts
@property (nonatomic, strong) NSMutableArray *quotationsArray;
@property (nonatomic, strong) NSString *quote;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) Quotation *quotation;
@property (strong, nonatomic) NSTimeZone *timeZone;
@property (strong, nonatomic) NSUserDefaults* defaults;



// get quote from user tapped notification
@property (strong, nonatomic) Quotation* notificationQuotation;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)reloadStores;



// alert functions
- (void) scheduleNotificationWithInterval:(NSString *)q :(int)minutesBefore;
- (void) reloadAlerts;
- (void) removeAlerts;




@end
