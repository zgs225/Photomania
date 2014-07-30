//
//  PhotomaniaAppDelegate.m
//  Photomania
//
//  Created by Yuez on 14-7-28.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "PhotomaniaAppDelegate.h"
#import "PhotomaniaAppDelegate+MOC.h"
#import "FlickrFetcher.h"
#import <CoreData/CoreData.h>
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailabilityNotication.h"

@interface PhotomaniaAppDelegate () <NSURLSessionDownloadDelegate>

@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletitionHandler)();
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegoundFetchTimer;
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;

@end

#define FLICKR_FETCH @"Flickr Just Uploaded Fetch"

#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)

#define BACKGROUND_FLICKR_FETCH_INTERVAL (10)

@implementation PhotomaniaAppDelegate

#pragma mark - Application delegation

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.photoDatabaseContext = [self createMainQueueManagedObjectContext];
    [self startFlickrFetch];
    return YES;
}

#pragma mark - Flickr fetching

- (void)startFlickrFetch
{
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task resume];
            }
        }
    }];
}

#pragma mark - Properties

- (NSURLSession *)flickrDownloadSession
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:configuration
                                                                   delegate:self
                                                              delegateQueue:nil];
        });
    }
    return _flickrDownloadSession;
}

- (void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext
{
    _photoDatabaseContext = photoDatabaseContext;
    NSDictionary *userInfo = self.photoDatabaseContext ? @{ PhotoDatabaseAvailabilityContext : self.photoDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotication
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - URLSessionDowloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    if ([downloadTask.description isEqualToString:FLICKR_FETCH]) {
        [self loadFlickrPhotosFromLocalURL:location
                               intoContext:self.photoDatabaseContext
                       andThenExecuteBlock:^{
                           [self flickrDownloadTasksMightBeComplete];
                       }];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // TODO
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // TODO
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error && (session = self.flickrDownloadSession)) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
        [self flickrDownloadTasksMightBeComplete];
    }
}

- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localURL
                         intoContext:(NSManagedObjectContext *)context
                 andThenExecuteBlock:(void(^)())whenDone
{
    if (context) {
        NSArray *photos = [self flickrPhotosAtURL:localURL];
        [context performBlock:^{
            [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            [context save:NULL];
            if (whenDone) {
                whenDone();
            }
        }];
    } else {
        if (whenDone) whenDone();
    }
}

- (void)flickrDownloadTasksMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletitionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void(^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletitionHandler;
                self.flickrDownloadBackgroundURLSessionCompletitionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}

- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

@end
