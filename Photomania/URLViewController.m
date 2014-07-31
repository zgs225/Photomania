//
//  URLViewController.m
//  Photomania
//
//  Created by Yuez on 14-7-31.
//  Copyright (c) 2014年 XGTEAM. All rights reserved.
//

#import "URLViewController.h"

@interface URLViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation URLViewController

- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self updateUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
}

- (void)updateUI
{
    self.textView.text = [self.url absoluteString];
}

@end
