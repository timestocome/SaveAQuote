//
//  CategoryDetailViewController.h
//  SaveAQuote
//
//  Created by Linda Cobb on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EditQuotationViewController.h"


@interface CategoryDetailViewController : UITableViewController 



@property (nonatomic, strong) EditQuotationViewController *editQuotationViewController;
@property (nonatomic, strong) NSMutableArray *quotationsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *categoryType;

@property (nonatomic, weak) IBOutlet UIImageView *background;


- (void)reloadData;



@end
