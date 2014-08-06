//
//  PhotosByPhotographerMapViewController.m
//  Photomania
//
//  Created by Yuez on 14-8-4.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "PhotosByPhotographerMapViewController.h"
#import <MapKit/MapKit.h>
#import "Photo+Annotation.h"
#import "ImageViewController.h"
#import "Photographer+Create.h"

@interface PhotosByPhotographerMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *photosByPhotographer; // of Photo
@property (strong, nonatomic) ImageViewController *imageViewController; // can be nil
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoBarButtonItem;
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
    [self updateAddPhotoBarButtonItem];
}

- (void)updateAddPhotoBarButtonItem
{
    if (self.addPhotoBarButtonItem) {
        BOOL canAddPhoto = [self.photographer isUser];
        NSMutableArray *rightBarButtonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (!rightBarButtonItems) {
            rightBarButtonItems = [[NSMutableArray alloc] init];
        }
        NSUInteger addPhotoBarButtonItemIndex = [rightBarButtonItems indexOfObject:self.addPhotoBarButtonItem];
        if (addPhotoBarButtonItemIndex == NSNotFound) {
            if (canAddPhoto) {
                [rightBarButtonItems addObject:self.addPhotoBarButtonItem];
            }
        } else {
            if (!canAddPhoto) {
                [rightBarButtonItems removeObject:self.addPhotoBarButtonItem];
            }
        }
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }
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
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.photosByPhotographer];
    [self.mapView showAnnotations:self.photosByPhotographer animated:YES];
    if (self.imageViewController) {
        Photo *autoSelectedPhoto = [self.photosByPhotographer firstObject];
        [self.mapView selectAnnotation:autoSelectedPhoto animated:YES];
        [self prepareViewController:self.imageViewController forSegue:nil toShowAnnotation:autoSelectedPhoto];
        
    }
}

- (ImageViewController *)imageViewController
{
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
    }
    return [detailvc isKindOfClass:[ImageViewController class]] ? detailvc : nil;
}

#pragma mark - Map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"PhotosByPhotographerMapViewController";
    MKAnnotationView *view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        view.leftCalloutAccessoryView = imageView;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    view.annotation = annotation;
    
    return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (self.imageViewController) {
        [self prepareViewController:self.imageViewController
                           forSegue:nil
                   toShowAnnotation:view.annotation];
    } else {
        [self updateLeftCalloutAccessoryViewInAnnotationView:view];
    }
}

- (void)updateLeftCalloutAccessoryViewInAnnotationView:(MKAnnotationView *)annotationView
{
    UIImageView *imageView = nil;
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        imageView = (UIImageView *)annotationView.leftCalloutAccessoryView;
    }
    if (imageView) {
        Photo *photo = nil;
        if ([annotationView.annotation isKindOfClass:[Photo class]]) {
            photo = (Photo *)annotationView.annotation;
        }
        if (photo) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.thumbnailURL]];
            
            // another configuration option is backgroundSessionConfiguration (multitasking API required though)
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            
            // create the session without specifying a queue to run completion handler on (thus, not main queue)
            // we also don't specify a delegate (since completion handler is all we need)
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                                                                // this handler is not executing on the main queue, so we can't do UI directly here
                                                                if (!error) {
                                                                    if ([request.URL isEqual:[NSURL URLWithString:photo.thumbnailURL]]) {
                                                                        // UIImage is an exception to the "can't do UI here"
                                                                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                                                                        // but calling "self.image =" is definitely not an exception to that!
                                                                        // so we must dispatch this back to the main queue
                                                                        dispatch_async(dispatch_get_main_queue(), ^{ imageView.image = image; });
                                                                    }
                                                                }
                                                            }];
            [task resume]; // don't forget that all NSURLSession tasks start out suspended!
        }
    }
}

#pragma mark - Navigation

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (!self.imageViewController)
        [self performSegueWithIdentifier:@"Show Photo" sender:view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[MKAnnotationView class]]) {
        [self prepareViewController:segue.destinationViewController
                           forSegue:segue.identifier
                   toShowAnnotation:((MKAnnotationView *)sender).annotation];
    }
}

- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifier
             toShowAnnotation:(id<MKAnnotation>)annotation
{
    Photo *photo = nil;
    if ([annotation isKindOfClass:[Photo class]]) {
        photo = (Photo *)annotation;
    }
    if (photo) {
        if (![segueIdentifier length] || [segueIdentifier isEqualToString:@"Show Photo"]) {
            if ([vc isKindOfClass:[ImageViewController class]]) {
                ImageViewController *ivc = (ImageViewController *)vc;
                ivc.imageURL = [NSURL URLWithString:photo.imageURL];
                ivc.title = photo.title;
            }
        }
    }
}



@end
