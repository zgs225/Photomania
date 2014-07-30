//
//  PhotomaniaAppDelegate+MOC.h
//  Photomania
//
//  Created by Yuez on 14-7-29.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "PhotomaniaAppDelegate.h"

@interface PhotomaniaAppDelegate (MOC)
- (NSManagedObjectContext *)createMainQueueManagedObjectContext;
@end
