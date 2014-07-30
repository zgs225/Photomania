//
//  PhotomaniaAppDelegate+MOC.m
//  Photomania
//
//  Created by Yuez on 14-7-29.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "PhotomaniaAppDelegate+MOC.h"
#import <CoreData/CoreData.h>

@implementation PhotomaniaAppDelegate (MOC)

#pragma mark - CoreData

- (void)saveContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // TODO dealing with an appropriately handle the problem
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)createMainQueueManagedObjectContext
{
    NSManagedObjectContext *managedObjectContext = nil;
    NSPersistentStoreCoordinator *coordinator = [self createPersistentStoreCoordinator];
    
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}

- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator
{
    NSPersistentStoreCoordinator *coordinator = nil;
    
    NSManagedObjectModel *managedObjectModel = [self createManagedObjectModel];
    NSURL *storeURL = [[self applicationDocumentDictionary] URLByAppendingPathComponent:@"MOC.sqlite"];
    NSError *error = nil;
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // TODO dealing with an appropriately handle the problem
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return coordinator;
}

- (NSManagedObjectModel *)createManagedObjectModel
{
    NSManagedObjectModel *managedObjectModel = nil;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Photomania" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

- (NSURL *)applicationDocumentDictionary
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
