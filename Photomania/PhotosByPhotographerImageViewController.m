//
//  PhotosByPhotographerImageViewController.m
//  Photomania
//
//  Created by Yuez on 14/8/5.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "PhotosByPhotographerImageViewController.h"
#import "PhotosByPhotographerMapViewController.h"

@interface PhotosByPhotographerImageViewController ()
@property (strong, nonatomic)PhotosByPhotographerMapViewController *mapvc;
@end

@implementation PhotosByPhotographerImageViewController

- (void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = self.photographer.name;
    self.mapvc.photographer = self.photographer;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[PhotosByPhotographerMapViewController class]]) {
        PhotosByPhotographerMapViewController *pbpmvc = (PhotosByPhotographerMapViewController *)segue.destinationViewController;
        pbpmvc.photographer = self.photographer;
        self.mapvc = pbpmvc;
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

@end
