//
//  UIImage+Tool.h
//  Photomania
//
//  Created by Yuez on 14/8/7.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tool)

- (UIImage *)imageByScalingToSize:(CGSize)size;

- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName;

@end
