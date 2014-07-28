//
//  Photographer+Create.h
//  Photomania
//
//  Created by Yuez on 14-7-28.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
