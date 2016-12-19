//
//  AppDelegate.m
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "AppDelegate.h"
#import "RandomQuoteViewController.h"
#import "DatabaseFunctionsViewController.h"





@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationIconBadgeNumber = 0;
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    
    
   
    
    return YES;
}




- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _defaults = [NSUserDefaults standardUserDefaults];
    
    //check notification stack has plenty of stuff in it
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ( [[self.defaults objectForKey:@"alertsOn"]intValue] == 1){
            
           
            [self reloadAlerts];
        }
    });
    
    
    [self reloadStores];
}







- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ( application.applicationState == UIApplicationStateInactive){
        
        _notificationQuotation = [self findQuote:[notification.userInfo objectForKey:@"quote"] source:[notification.userInfo objectForKey:@"source"]];
        
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        [[tabBarController.viewControllers objectAtIndex:0] viewWillAppear:YES];

    }
}



-(Quotation *)findQuote:(NSString *)q source:(NSString *)s
{
    Quotation* quotation;
    
    //  fetch data **************************************************************
    // load stored objects
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quotation" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    
    // grab matching source only if we can to speed up the search
    if ( [s compare:@""] != 0 ){
        
        NSString *predicateString = [NSString stringWithFormat:@"source='%@'", s];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    
    
    // load 'em up
    NSError *error;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    // locate the quote - but we may only have a partial quote - notifications has a max chars
    int endOfList = (int)mutableFetchResults.count;
    
    for (int i=0; i<endOfList; i++){
        
        Quotation *quote = [mutableFetchResults objectAtIndex:i];
        
        // trim items we're comparing in case notification quote was truncated
        NSString *notificationString = q;
        NSString *quotationString = quote.quote;
        
        
        if ( [notificationString compare:quotationString] == 0 ){
            quotation = [mutableFetchResults objectAtIndex:i];
            i = endOfList;
        }
        
    }
    
    // no match found - edited or deleted, grab a random quote
    if ( quotation == nil ){
        
        [request setEntity:entity];
        [request setPredicate:nil];
        mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
       
        int random = arc4random_uniform((int)mutableFetchResults.count);
        quotation = [mutableFetchResults objectAtIndex:random];
    }
    
    return quotation;
}






- (void)applicationDidEnterBackground:(UIApplication *)application{ [self saveContext]; }
- (void)applicationWillResignActive:(UIApplication *)application { [self saveContext]; }
- (void)applicationWillTerminate:(UIApplication *)application { [self saveContext]; }


- (void)applicationWillEnterForeground:(UIApplication *)application {}





- (void)reloadStores
{
    [self saveContext];
    
    self.managedObjectContext = nil;
    self.persistentStoreCoordinator = nil;
    
    _options = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                nil];
    
    
    int iCloudOn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudOn"] intValue];
    
    if (  iCloudOn ){
        
        NSURL* transactionLogsURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        
        if ( transactionLogsURL ){  // icloud is available
            
            NSString* coreDataCloudContent = [[transactionLogsURL path] stringByAppendingPathComponent:ICLOUD_DATA];
            transactionLogsURL = [NSURL fileURLWithPath:coreDataCloudContent];
            NSLog(@"transaction logs url %@", transactionLogsURL);
            
            
            // convert old database to be compatible with new version of software
            _options = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                        [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                        @"Store", NSPersistentStoreUbiquitousContentNameKey,
                        transactionLogsURL, NSPersistentStoreUbiquitousContentURLKey,
                        nil];
        }
        
    }
    _persistentStoreCoordinator = [self persistentStoreCoordinator];
    _managedObjectContext = [self managedObjectContext];
    
}






- (void)storeDidChange:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSNumber* reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    NSInteger reason = -1;
    
    NSLog(@"change ? %@ userInfo %@ ", reasonForChange, userInfo    );
    
    // dunno why it changed so don't mess with it
    if ( !reasonForChange ){ return; }
    
    
    // init setup on a new device or server change, then save it to local defaults
    reason = [reasonForChange integerValue];
    if ( reason == NSUbiquitousKeyValueStoreServerChange || reason == NSUbiquitousKeyValueStoreInitialSyncChange ){
        
        NSArray* changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
        NSUbiquitousKeyValueStore* kvStore = [NSUbiquitousKeyValueStore defaultStore];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        [changedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL* stop){
            id value = [kvStore objectForKey:key];
            [defaults setObject:value forKey:key];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIShouldRefresh object:nil];
    }
}




- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}


- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistentStoreDidImportContent:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistentStoresWillChange:) name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:coordinator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistentStoresDidChange:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:coordinator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistentStoreDidImportUbiquitousContentChanges:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
    
    return _managedObjectContext;
}



- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:MODEL_NAME withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    if ( _managedObjectModel == NULL ){ NSLog(@"Cannot create ManagedObjectModel for %@", MODEL_NAME); }
    
    return _managedObjectModel;
}





- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:DATABASE_NAME];
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:self.options error:&error]) {
        NSLog(@"\n\nUnresolved error %@, %@\n\n", error, [error userInfo]);
        
        // all went well leave url for database view
    }else{
        
        if ( [[[NSUserDefaults standardUserDefaults]  objectForKey:@"iCloudOn"] intValue] ){
            NSURL *iCloudURL = [[[self.persistentStoreCoordinator persistentStores] objectAtIndex:0] URL];
            [[NSUserDefaults standardUserDefaults] setObject:[iCloudURL absoluteString] forKey:@"newiCloudStoreURL"];
        }else{
            // get local store meta data
            NSMutableDictionary *metadata = [[NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                                        URL:storeURL error:&error] mutableCopy];
            
            if ( metadata ){
                [metadata removeObjectForKey:@"com.apple.coredata.ubiquity.baseline.timestamp"];
                [metadata removeObjectForKey:@"com.apple.coredata.ubiquity.token"];
                [metadata removeObjectForKey:@"com.apple.coredata.ubiquity.ubiquitized"];
                
                if ([NSPersistentStoreCoordinator setMetadata:metadata forPersistentStoreOfType:NSSQLiteStoreType
                                                          URL:storeURL error:&error]) {
                }
            }
        }
    }
    
    return _persistentStoreCoordinator;
}




- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)notification
{
    NSLog(@"persistentStoreDidImportUbiquitiousContentChanges %@", notification);
}

- (void)persistentStoresWillChange:(NSNotification *)notification
{
    if ( [_managedObjectContext hasChanges]){
        NSError* error = nil;
        if (![_managedObjectContext save:&error]){
            NSLog(@"Error while trying to save data before store change  %@", error.localizedDescription );
        }
    }
    [_managedObjectContext reset];
}



- (void)persistentStoresDidChange:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PERSISTENT_STORE_CHANGED" object:nil];
}



- (void)persistentStoreDidImportContent:(NSNotification *)notification
{
    NSLog(@"persistent store imported content");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PERSISTENT_STORE_UPDATED" object:nil];
}
















- (void) scheduleNotificationWithInterval:(NSString *)q :(int)minutesBefore;
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
	if (localNotif == nil) {  return;  }
	
	localNotif.fireDate = [[NSDate date] dateByAddingTimeInterval:(minutesBefore*60)];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = q;
	localNotif.hasAction = NO;
	
	
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
	
}




- (void)removeAlerts
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}





-(void)reloadAlerts
{
    
	// reload up notifications
	// check user settings and turn off notifications or change timespan for alerts
	self.defaults = [NSUserDefaults standardUserDefaults];
	int quotesOn = [[self.defaults objectForKey:@"alertsOn"] intValue];
    NSString* categoryString = [self.defaults objectForKey:@"category"];
    
    int notificationTime = [[self.defaults objectForKey:@"notificationTime"] intValue];
    if ((notificationTime <=0) || (notificationTime > 24)){ notificationTime = 11; }

	
	UIApplication *app = [UIApplication sharedApplication];
	NSArray *oldNotifications = [app scheduledLocalNotifications];
	int stackCount = (int)[oldNotifications count];
    
    NSLog(@"*********************************   stackCount %d", stackCount);

	if ( (quotesOn == 1) && (stackCount < 32) ){
        
        
		//  fetch data **************************************************************
		// load stored objects
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quotation" inManagedObjectContext:self.managedObjectContext];
		[request setEntity:entity];
        
        
        // ? specific category
        if ( [categoryString compare:@""] != 0 ){
            if ( [categoryString compare:@"All"] != 0 ){
            
                NSString *predicateString = [NSString stringWithFormat:@"category='%@'", categoryString];
            
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
                [request setPredicate:predicate];

            }
        }
        
        
		// load 'em up
		NSError *error;
		NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
		
		if (mutableFetchResults == nil) {
			NSLog (@"mutable array fetch fail");
		}else {
			
			self.quotationsArray = [NSMutableArray arrayWithArray:mutableFetchResults];
            
            if ( [self.quotationsArray count] > 0 ){
            
                //erase old
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
                // load up new if user has quotes on
                srand((int)time(NULL));
                int count = (int)[self.quotationsArray count];
            
            
                // randomize some quotes
                NSMutableArray *m1 = [[NSMutableArray alloc] initWithArray:self.quotationsArray];
                NSMutableArray *m2 = [[NSMutableArray alloc] initWithCapacity:count];
                int r;
                int c = (int)([m1 count] - 1);
                int j = 0;
            
            
                for ( int i=c; i>0; i--){
                
                    r = rand()%i;
				
                    [m2 insertObject:[m1 objectAtIndex:r] atIndex:j];
                    [m1 removeObjectAtIndex:r];
                
                    j++;
                }
            
                [m2 insertObject:[m1 objectAtIndex:0] atIndex:j];	// fetch last object --- crashes loop if placed inside or skips last
            
                self.quotationsArray = m2;
            
                
                // init calendar and date parts
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
                NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
                
                
                [components setHour:notificationTime];
                [components setMinute:0];
                
                NSDate *startDate = [calendar dateFromComponents:components];
                
                
                for ( int i=0; i<[self.quotationsArray count]; i++){
                    
                    // set up new notification
                    UILocalNotification *newNotification = [[UILocalNotification alloc] init];
                    [newNotification setTimeZone:self.timeZone];
                    
                    startDate = [calendar dateFromComponents:components];
                    [newNotification setFireDate:startDate];
                    
                    components.day++;  // move to next day
                  
                    // set alert message
                    [newNotification setAlertBody:[NSString stringWithFormat:@"%@", [[m2 objectAtIndex:i] quote]]];
                    
                    
                    // set user info for locating quote later
                    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                              [[m2 objectAtIndex:i] quote], @"quote",
                                              [[m2 objectAtIndex:i] source], @"source",
                                                nil];
                    [newNotification setUserInfo:userInfo];
                    
                    
                    // set notification into the system queue
                    [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
                    NSLog(@"added notification %@", newNotification);
                }

            }
        }
    }
}












@end
