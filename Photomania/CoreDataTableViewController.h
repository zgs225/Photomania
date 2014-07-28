//
//  CoreDataTableViewController.h
//  Photomania
//
//  Created by Yuez on 14-7-28.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

// The controller (this class fetches nothing if this is not set)
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// This will also automatically be called if you changed the fetchedResultController @property
- (void) performFetch;

@property BOOL debug;

@end
