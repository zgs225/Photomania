//
//  Photo+Flickr.m
//  Photomania
//
//  Created by Yuez on 14-7-28.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    
    NSArray *photos = [context executeFetchRequest:request error:&error];
    
    if (!photos || error || [photos count] > 1) {
        // error handler
    } else if ([photos count] == 1) {
        return [photos firstObject];
    } else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.unique = unique;
        photo.title = photoDictionary[FLICKR_PHOTO_TITLE];
        photo.subtitle = photoDictionary[FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary
                                              format:FlickrPhotoFormatOriginal] absoluteString];
        NSString *photographerName = photoDictionary[FLICKR_PHOTO_OWNER];
        Photographer *photographer = [Photographer photographerWithName:photographerName
                                                 inManagedObjectContext:context];
        photo.whoTook = photographer;
    }
    
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of photo dictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}

@end
