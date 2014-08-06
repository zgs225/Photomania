//
//  UIImage+Tool.m
//  Photomania
//
//  Created by Yuez on 14/8/7.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "UIImage+Tool.h"

@implementation UIImage (Tool)

- (UIImage *)imageByScalingToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName
{
    UIImage *filterdImage = self;
    
    CIImage *inputImage = [CIImage imageWithCGImage:[self CGImage]];
    if (inputImage) {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        [filter setValue:inputImage forKey:kCIInputImageKey];
        CIImage *outputImage = [filter outputImage];
        if (outputImage) {
            filterdImage = [UIImage imageWithCIImage:outputImage];
            UIGraphicsBeginImageContextWithOptions(self.size, YES, 0.0);
            [filterdImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
            filterdImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    return filterdImage;
}

@end