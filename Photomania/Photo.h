//
//  Photo.h
//  Photomania
//
//  Created by Yuez on 14-7-28.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) Photographer *whoTook;

@end
