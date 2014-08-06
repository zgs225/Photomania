//
//  Photographer+Create.m
//  Photomania
//
//  Created by Yuez on 14-7-28.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Photographer"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSError *error;
    
    NSArray *photographers = [context executeFetchRequest:request
                                                    error:&error];
    if (!photographers || error || [photographers count] > 1) {
        // error handler
    } else if ([photographers count] == 1) {
        return [photographers firstObject];
    } else {
        photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer"
                                                     inManagedObjectContext:context];
        photographer.name = name;
    }
    
    return photographer;
}

+ (Photographer *)userInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self photographerWithName:@"My Photos" inManagedObjectContext:context];
}

- (BOOL)isUser
{
    return self == [[self class] userInManagedObjectContext:self.managedObjectContext];
}

@end
