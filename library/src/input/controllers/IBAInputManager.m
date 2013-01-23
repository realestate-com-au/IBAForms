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

#import <Foundation/Foundation.h>
#import "IBAInputManager.h"
#import "IBACommon.h"
#import "IBAInputCommon.h"
#import "IBADateInputProvider.h"
#import "IBATextInputProvider.h"
#import "IBAInputNavigationToolbar.h"
#import "IBAMultiplePickListInputProvider.h"
#import "IBASinglePickListInputProvider.h"
#import "IBAPoppedOverViewController.h"
#import "IBATextField.h"

@interface UIResponder (InputViews)
- (void)setInputView:(UIView *)inputView;
- (void)setInputAccessoryView:(UIView *)accessoryView;
@end


@interface IBAInputManager () <UIPopoverControllerDelegate>
- (void)nextPreviousButtonSelected;
- (void)displayInputProvider:(id<IBAInputProvider>)inputProvider forInputRequestor:(id<IBAInputRequestor>)requestor;
- (BOOL)activateInputRequestor:(id<IBAInputRequestor>)inputRequestor;
- (void)updateInputNavigationToolbarVisibility;
- (BOOL)setActiveInputRequestor:(id<IBAInputRequestor>)inputRequestor forced:(BOOL)forced;

- (void)applicationWillChangeStatusBarOrientation:(NSDictionary *)change;

@property (nonatomic, strong) UIPopoverController *popoverController;

@end


@implementation IBAInputManager

+ (IBAInputManager *)sharedIBAInputManager {

  static IBAInputManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] init];
  });

  return sharedManager;
}


@synthesize inputRequestorDataSource = inputRequestorDataSource_;
@synthesize inputNavigationToolbar = inputNavigationToolbar_;
@synthesize inputNavigationToolbarEnabled = inputNavigationToolbarEnabled_;
@synthesize inputProviderCoordinator = inputProviderCoordinator_;
@synthesize popoverController = popoverController_;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {


  [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (id)init {
	if ((self = [super init])) {
		inputProviders_ = [[NSMutableDictionary alloc] init];
		
		inputNavigationToolbar_ = [[IBAInputNavigationToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];   
		inputNavigationToolbar_.doneButton.target = self;
		inputNavigationToolbar_.doneButton.action = @selector(deactivateActiveInputRequestor);
		[inputNavigationToolbar_.nextPreviousButton addTarget:self action:@selector(nextPreviousButtonSelected) 
                                             forControlEvents:UIControlEventValueChanged];
        
        inputNavigationToolbarEnabled_ = YES;

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillChangeStatusBarOrientation:)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

		// Setup some default input providers

		// Text
		[self registerInputProvider:[[IBATextInputProvider alloc] init]
						forDataType:IBAInputDataTypeText];
        
        // Numbers
        [self registerInputProvider:[[IBATextInputProvider alloc] init]
                        forDataType:IBAInputDataTypeNumber];
        
		// Date
		[self registerInputProvider:[[IBADateInputProvider alloc] init]
						forDataType:IBAInputDataTypeDate];
		// Time
		[self registerInputProvider:[[IBADateInputProvider alloc] initWithDatePickerMode:UIDatePickerModeTime] 
						forDataType:IBAInputDataTypeTime];
		
		// Date & Time
		[self registerInputProvider:[[IBADateInputProvider alloc] initWithDatePickerMode:UIDatePickerModeDateAndTime]
						forDataType:IBAInputDataTypeDateTime];
		
		// Single Picklist
		[self registerInputProvider:[[IBASinglePickListInputProvider alloc] init]
						forDataType:IBAInputDataTypePickListSingle];
		
		// Multiple Picklist
		[self registerInputProvider:[[IBAMultiplePickListInputProvider alloc] init]
						forDataType:IBAInputDataTypePickListMultiple];
        
	}
	
	return self;
}


#pragma mark -
#pragma mark Accessors
- (BOOL)setActiveInputRequestor:(id<IBAInputRequestor>)inputRequestor {
    return [self setActiveInputRequestor:inputRequestor forced:NO];
}

- (BOOL)setActiveInputRequestor:(id<IBAInputRequestor>)inputRequestor forced:(BOOL)forced {
	id<IBAInputProvider>oldInputProvider = nil;
	if (activeInputRequestor_ != nil) {
		oldInputProvider = [self inputProviderForRequestor:activeInputRequestor_];

		if (![activeInputRequestor_ deactivateForced:forced]) {
			return NO;
		}

    if (activeInputRequestor_.displayStyle == IBAInputRequestorDisplayStylePopover) {
      [self.popoverController dismissPopoverAnimated:YES];
      self.popoverController = nil;
    } else {
      [[activeInputRequestor_ responder] resignFirstResponder];
    }

		oldInputProvider.inputRequestor = nil;
    activeInputRequestor_ = nil;
	}
	
	if (inputRequestor != nil)  {
		activeInputRequestor_ = inputRequestor;

		id<IBAInputProvider>newInputProvider = [self inputProviderForRequestor:activeInputRequestor_];
		[self displayInputProvider:newInputProvider forInputRequestor:inputRequestor];
		
		[activeInputRequestor_ activate];
		newInputProvider.inputRequestor = activeInputRequestor_;
	}
	
	return YES;
}

- (id<IBAInputRequestor>)activeInputRequestor {
	return activeInputRequestor_;
}


#pragma mark -
#pragma mark Input Provider Registration/Deregistration

- (void)registerInputProvider:(id<IBAInputProvider>)provider forDataType:(NSString *)dataType {
	[inputProviders_ setValue:provider forKey:dataType];
}

- (void)deregisterInputProviderForDataType:(NSString *)dataType {
	[inputProviders_ removeObjectForKey:dataType];
}

- (id<IBAInputProvider>)inputProviderForDataType:(NSString *)dataType {
	return [inputProviders_ objectForKey:dataType];
}


#pragma mark -
#pragma mark Input navigation toolbar actions

- (void)nextPreviousButtonSelected {
	switch (self.inputNavigationToolbar.nextPreviousButton.selectedSegmentIndex) {
		case IBAInputNavigationToolbarActionPrevious:
			[self activatePreviousInputRequestor];
			break;
		case IBAInputNavigationToolbarActionNext:
			[self activateNextInputRequestor];
			break;
		default:
			break;
	}
}

- (BOOL)forceDeactivateActiveInputRequestor {
    return [self setActiveInputRequestor:nil forced:YES];
}
    
- (BOOL)deactivateActiveInputRequestor {
	return [self setActiveInputRequestor:nil];
}


#pragma mark -
#pragma mark Input requestor activation

- (BOOL)activateNextInputRequestor {
	NSAssert(self.inputRequestorDataSource != nil, @"inputRequestorDataSource has not been set");
	return [self activateInputRequestor:[self.inputRequestorDataSource nextInputRequestor:self.activeInputRequestor]];
}

- (BOOL)activatePreviousInputRequestor {
	NSAssert(self.inputRequestorDataSource != nil, @"inputRequestorDataSource has not been set");
	return [self activateInputRequestor:[self.inputRequestorDataSource previousInputRequestor:self.activeInputRequestor]];
}

- (BOOL)activateInputRequestor:(id<IBAInputRequestor>)inputRequestor {
	return ((inputRequestor != nil && [self setActiveInputRequestor:inputRequestor]));
}


#pragma mark -
#pragma mark Retrieving input providers for input requestors

- (id<IBAInputProvider>)inputProviderForRequestor:(id<IBAInputRequestor>)inputRequestor {
	if (inputRequestor.dataType == nil) {
		NSString *message = [NSString stringWithFormat:@"Data type for input requestor %@ has not been set", inputRequestor];
		NSAssert(NO, message);
	}

	id<IBAInputProvider> provider = [self inputProviderForDataType:inputRequestor.dataType];
	
	if (provider == nil) {
		NSString *message = [NSString stringWithFormat:@"No input provider bound to data type %@", inputRequestor.dataType];
		NSAssert(NO, message);
	}
	
	return provider;
}

- (id<IBAInputProvider>)inputProviderForActiveInputRequestor {
	return [self inputProviderForRequestor:self.activeInputRequestor];
}


#pragma mark -
#pragma mark Presenting the input provider

- (void)displayInputProvider:(id<IBAInputProvider>)inputProvider forInputRequestor:(id<IBAInputRequestor>)requestor {

  if (nil != inputProviderCoordinator_)
  {
    return [inputProviderCoordinator_ setInputView:inputProvider.view];
  }

  if (requestor.displayStyle == IBAInputRequestorDisplayStylePopover && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

    //prevent the keyboard from appearing
    [[requestor responder] setInputView:[[UIView alloc] initWithFrame:CGRectZero]];

    NSAssert(inputProvider.view != nil,@"InputProvider view cannot be nil if InputRequestor displayStyle == IBAInputRequestorDisplayStylePopover");

    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:[[IBAPoppedOverViewController alloc] initWithInputProviderView:inputProvider.view]];
    self.popoverController.delegate = self;
    self.popoverController.popoverContentSize = inputProvider.view.frame.size;

    //if the responder is a text field, grab it's clear button and allow it to be pressed
    if ([requestor.responder isKindOfClass:[IBATextField class]])
    {
      IBATextField *textField = (IBATextField *)requestor.responder;
      self.popoverController.passthroughViews = [NSArray arrayWithObjects:textField.clearButton, nil];
      [self.popoverController presentPopoverFromRect:textField.bounds inView:requestor.cell permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
    else
    {
      [self.popoverController presentPopoverFromRect:requestor.cell.bounds inView:requestor.cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
  } else {
    if (inputProvider.view != nil) {
      [[requestor responder] setInputView:inputProvider.view];
    }

    [self updateInputNavigationToolbarVisibility];
  }

}

#pragma mark - 
#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  if (self.popoverController == popoverController) { //being extra safe
    self.popoverController = nil;
    [self deactivateActiveInputRequestor];
  }
}


#pragma mark -
#pragma mark Enablement of the input navigation toolbar

- (void)setInputNavigationToolbarEnabled:(BOOL)enabled {
	inputNavigationToolbarEnabled_ = enabled;
    
    [self updateInputNavigationToolbarVisibility];
}

- (void)updateInputNavigationToolbarVisibility
{
  UIResponder *responder = [[self activeInputRequestor] responder];
  responder.inputAccessoryView = ([self isInputNavigationToolbarEnabled] ? self.inputNavigationToolbar : nil);
  
  BOOL hasNextInputRequestor = [self.inputRequestorDataSource nextInputRequestor:self.activeInputRequestor] != nil;
  BOOL hasPrevInputRequestor = [self.inputRequestorDataSource previousInputRequestor:self.activeInputRequestor] != nil;

  [self.inputNavigationToolbar.nextPreviousButton setEnabled:hasPrevInputRequestor forSegmentAtIndex:0];
  [self.inputNavigationToolbar.nextPreviousButton setEnabled:hasNextInputRequestor forSegmentAtIndex:1];
}

#pragma mark -
#pragma mark StatusBarOrientationCallBacks

- (void)applicationWillChangeStatusBarOrientation:(NSDictionary *)change
{
  if (self.activeInputRequestor.displayStyle == IBAInputRequestorDisplayStylePopover) {
    [self deactivateActiveInputRequestor];
  }
}

@end
