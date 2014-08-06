//
//  AddPhotoViewController.h
//  Photomania
//
//  Created by Yuez on 14/8/6.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photographer.h"

@interface AddPhotoViewController : UIViewController

// in
@property (strong, nonatomic)Photographer *photographerTakingPhoto;

// out
@property (strong, readonly)Photo *addedPhoto;

@end
