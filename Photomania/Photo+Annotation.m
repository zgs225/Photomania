//
//  Photo+Annotation.m
//  Photomania
//
//  Created by Yuez on 14-8-4.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "Photo+Annotation.h"

@implementation Photo (Annotation)

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longtitude doubleValue];
    return coordinate;
}

@end
