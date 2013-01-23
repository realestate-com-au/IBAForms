//
// Copyright 2010 Itty Bitty Apps Pty Ltd
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "IBAPoppedOverViewController.h"
#import "IBAFormConstants.h"

@interface IBAPoppedOverViewController ()
@property (nonatomic, strong) UIView *inputProviderView;
@property (nonatomic, strong) UIView *accessoryView;
@end

@implementation IBAPoppedOverViewController

- (id)initWithInputProviderView:(UIView *)inputProviderView accessoryView:(UIView *)accessoryView
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.inputProviderView = inputProviderView;
        self.accessoryView = accessoryView;
    }
    return self;
}

- (id)initWithInputProviderView:(UIView *)inputProviderView {
    return [self initWithInputProviderView:inputProviderView accessoryView:nil];
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 240.)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    if (self.accessoryView) {
        //self.accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        self.accessoryView.frame = CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(self.accessoryView.frame));
        [view addSubview:self.accessoryView];
    }

    [self.inputProviderView sizeToFit];
    self.inputProviderView.frame = CGRectMake(0, CGRectGetMaxY(self.accessoryView.frame), CGRectGetWidth(self.inputProviderView.frame), CGRectGetHeight(self.inputProviderView.frame));
    [view addSubview:self.inputProviderView];

    [view setFrame:CGRectMake(0, 0, 320, CGRectGetMaxY(self.inputProviderView.frame))];

    [self setView:view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
