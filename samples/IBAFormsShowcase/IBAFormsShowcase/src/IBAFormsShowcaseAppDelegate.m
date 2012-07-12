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

#import "IBAFormsShowcaseAppDelegate.h"
#import "ShowcaseModel.h"
#import "ShowcaseFormDataSourceiPhone.h"
#import "ShowcaseController.h"
#import "ShowcaseSplitViewController.h"

@interface IBAFormsShowcaseAppDelegate ()
@end


@implementation IBAFormsShowcaseAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

  UIViewController *rootViewController = nil;

  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
  {
    rootViewController = [[[ShowcaseSplitViewController alloc] init] autorelease];
  }
  else
  {
    ShowcaseModel *showcaseModel = [[[ShowcaseModel alloc] init] autorelease];
    showcaseModel.shouldAutoRotate = YES;
    showcaseModel.tableViewStyleGrouped = YES;
    showcaseModel.displayNavigationToolbar = YES;

    IBAFormDataSource *showcaseDataSource_iPhone = [[[ShowcaseFormDataSourceiPhone alloc] initWithModel:showcaseModel] autorelease];
    IBAFormViewController *showcaseController_iPhone = [[[ShowcaseController alloc] initWithNibName:nil bundle:nil formDataSource:showcaseDataSource_iPhone] autorelease];
    [showcaseController_iPhone setTitle:@"IBAForms iPhone Showcase"];
    rootViewController = [[[UINavigationController alloc] initWithRootViewController:showcaseController_iPhone] autorelease];
  }

  [self setWindow:[[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease]];
	[[self window] setRootViewController:rootViewController];
	[[self window] makeKeyAndVisible];

  return YES;
}

- (void)dealloc {
    [self setWindow:nil];
	
    [super dealloc];
}

@end
