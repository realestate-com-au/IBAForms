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

#import "ShowcaseSplitViewController.h"
#import "ShowcaseFormDataSourceiPad.h"
#import "ShowcaseModel.h"
#import <IBAForms/IBAForms.h>
#import "ShowcaseMasterViewController.h"
#import "ShowcaseDetailViewController.h"

@implementation ShowcaseSplitViewController

- (id)init {
  if ((self = [super init])) {

    ShowcaseModel *showcaseModel = [[[ShowcaseModel alloc] init] autorelease];
    showcaseModel.shouldAutoRotate = YES;
    showcaseModel.tableViewStyleGrouped = YES;
    showcaseModel.displayNavigationToolbar = YES;
    
    IBAFormDataSource *showcaseDataSource_iPad = [[[ShowcaseFormDataSourceiPad alloc] initWithModel:showcaseModel] autorelease];
    
    ShowcaseMasterViewController *masterViewController = [[ShowcaseMasterViewController alloc] initWithNibName:nil bundle:nil formDataSource:showcaseDataSource_iPad];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    ShowcaseDetailViewController *detailViewController = [[ShowcaseDetailViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];

    masterViewController.detailViewController = detailViewController;
    
    self.delegate = detailViewController;
    self.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
  }
  return self;
}

@end
