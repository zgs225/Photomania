//
//  PhotosByPhotographerMapViewController.m
//  Photomania
//
//  Created by Yuez on 14-8-4.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "PhotosByPhotographerMapViewController.h"
#import <MapKit/MapKit.h>
#import "Photo.h"

@interface PhotosByPhotographerMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *photosByPhotographer; // of Photo
@end

@implementation PhotosByPhotographerMapViewController

#pragma mark - Properties

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapViewAnnotations];
}

- (void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    self.photosByPhotographer = nil;
    [self updateMapViewAnnotations];
}

- (NSArray *)photosByPhotographer
{
    if (!_photosByPhotographer) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
        _photosByPhotographer = [self.photographer.managedObjectContext
                                 executeFetchRequest:request error:NULL];
    }
    return _photosByPhotographer;
}

- (void)updateMapViewAnnotations
{
    
}

@end
