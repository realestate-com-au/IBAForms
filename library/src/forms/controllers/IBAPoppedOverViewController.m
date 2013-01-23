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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
