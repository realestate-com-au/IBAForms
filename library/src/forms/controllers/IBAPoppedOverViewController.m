//
//  IBAPoppedOverViewController.m
//  IBAForms
//
//  Created by Jesse Collis on 12/07/12.
//  Copyright (c) 2012 JC Multimedia Design. All rights reserved.
//

#import "IBAPoppedOverViewController.h"
#import "IBAFormConstants.h"

@interface IBAPoppedOverViewController ()
@property (nonatomic, retain) UIView *inputProviderView;
@end

@implementation IBAPoppedOverViewController
@synthesize inputProviderView = inputProviderView_;

- (id)initWithInputProviderView:(UIView *)inputProviderView {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    [self setInputProviderView:inputProviderView];
  }
  return self;
}

- (void)loadView
{
  [self setView:self.inputProviderView];
}

- (void)dealloc
{
  IBA_RELEASE_SAFELY(inputProviderView_);

  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
