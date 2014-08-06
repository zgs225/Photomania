//
//  AddPhotoViewController.m
//  Photomania
//
//  Created by Yuez on 14/8/6.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "AddPhotoViewController.h"

@interface AddPhotoViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@end

@implementation AddPhotoViewController

#pragma mark - Properties

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (UIImage *)image
{
    return self.imageView.image;
}

#pragma mark - Button actions

- (IBAction)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePhoto
{
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
