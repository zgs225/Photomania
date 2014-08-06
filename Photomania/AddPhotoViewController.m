//
//  AddPhotoViewController.m
//  Photomania
//
//  Created by Yuez on 14/8/6.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "AddPhotoViewController.h"
#import "Photo.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Tool.h"

@interface AddPhotoViewController () <UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, readwrite, nonatomic)Photo *addedPhoto;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation AddPhotoViewController

#pragma mark - Capabilities

+ (BOOL)canAddPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Add photo controller delegate

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[self class] canAddPhoto]) {
        [self fatalAlert:@"Sorry, this device can not take a photo"];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.image = [UIImage imageNamed:@"IMG_0066.jpg"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self cancel];
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject]; // the last object is best accuracy
}

#pragma mark - Properties

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:_thumbnailURL error:NULL];
    self.imageURL = nil;
    self.thumbnailURL = nil;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (NSURL *)imageURL
{
    if (!_imageURL && self.image) {
        NSURL *url = [self uniqueDocumentURL];
        if (url) {
            NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
            if ([imageData writeToURL:url atomically:YES]) {
                _imageURL = url;
            }
        }
    }
    return _imageURL;
}

- (NSURL *)thumbnailURL
{
    NSURL *url = [self.imageURL URLByAppendingPathExtension:@"thumbnail"];
    if (![_thumbnailURL isEqual:url]) {
        _thumbnailURL = nil;
        if (url) {
            UIImage *thumbnail = [self.image imageByScalingToSize:CGSizeMake(75, 75)];
            NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
            if ([imageData writeToURL:url atomically:YES]) {
                _thumbnailURL = url;
            }
        }
    }
    return _thumbnailURL;
}

- (NSURL *)uniqueDocumentURL
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f", floor([NSDate timeIntervalSinceReferenceDate])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

#pragma mark - Button actions

- (IBAction)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePhoto
{
}

#pragma mark - Navigation

#define UNWIND_SEGUE_IDENTIFIER @"Do Add Photo"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSManagedObjectContext *context = self.photographerTakingPhoto.managedObjectContext;
        if (context) {
            Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                         inManagedObjectContext:context];
            photo.title = self.titleTextField.text;
            photo.subtitle = self.subtitleTextField.text;
            photo.whoTook = self.photographerTakingPhoto;
            photo.latitude = @(self.location.coordinate.latitude);
            photo.longtitude = @(self.location.coordinate.longitude);
            photo.imageURL = [self.imageURL absoluteString];
            photo.thumbnailURL = [self.thumbnailURL absoluteString];
            
            self.addedPhoto = photo;
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        if (!self.image) {
            [self alert:@"No photo token"];
            return NO;
        } else if (![self.titleTextField.text length]) {
            [self alert:@"Title required"];
            return NO;
        }
        return YES;
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

#pragma mark - Alerts

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Add photo"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Add photo"
                                message:msg
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

@end
