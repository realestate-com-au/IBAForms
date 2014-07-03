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
@property (nonatomic, strong, readwrite) UIPopoverController *popoverController;
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
@synthesize popoverBackgroundViewClass = popoverBackgroundViewClass_;

#pragma mark - Memory management

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
        
        self.popoverPermittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    return self;
}


#pragma mark - Accessors

- (BOOL)setActiveInputRequestor:(id<IBAInputRequestor>)inputRequestor {
    return [self setActiveInputRequestor:inputRequestor forced:NO];
}

- (BOOL)setActiveInputRequestor:(id<IBAInputRequestor>)newInputRequestor forced:(BOOL)forced {
    if (activeInputRequestor_ != nil && newInputRequestor != nil) {
        self.isSwitchingInputRequestor = YES;
    }
    
    id<IBAInputProvider>oldInputProvider = nil;
    if (activeInputRequestor_ != nil) {
        oldInputProvider = [self inputProviderForRequestor:activeInputRequestor_];
        
        if (![activeInputRequestor_ deactivateForced:forced]) {
            self.isSwitchingInputRequestor = NO;
            return NO;
        }
        
        [[activeInputRequestor_ responder] resignFirstResponder];
        
        if (activeInputRequestor_.displayStyle == IBAInputRequestorDisplayStyleKeyboard && newInputRequestor.displayStyle == IBAInputRequestorDisplayStylePopover)
        {
            newInputRequestor = nil;//If trying switch input from keyboard to popover, then dismiss the keyboard, without bringing up popover. Because dismissing the keyboard will possibly adjust the scroll content offset, making the new popover appear in the wrong position.
        }
        oldInputProvider.inputRequestor = nil;
        activeInputRequestor_ = nil;
    }
    
    if (newInputRequestor != nil)  {
        activeInputRequestor_ = newInputRequestor;
        id<IBAInputProvider>newInputProvider = [self inputProviderForRequestor:activeInputRequestor_];
        newInputProvider.inputRequestor = activeInputRequestor_;
        [self displayInputProvider:newInputProvider forInputRequestor:newInputRequestor];
        [activeInputRequestor_ activate];
    }
    
    self.isSwitchingInputRequestor = NO;
    
    return YES;
}

- (id<IBAInputRequestor>)activeInputRequestor {
    return activeInputRequestor_;
}


#pragma mark - Input Provider Registration/Deregistration

- (void)registerInputProvider:(id<IBAInputProvider>)provider forDataType:(NSString *)dataType {
    [inputProviders_ setValue:provider forKey:dataType];
}

- (void)deregisterInputProviderForDataType:(NSString *)dataType {
    [inputProviders_ removeObjectForKey:dataType];
}

- (id<IBAInputProvider>)inputProviderForDataType:(NSString *)dataType {
    return [inputProviders_ objectForKey:dataType];
}


#pragma mark - Input navigation toolbar actions

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


#pragma mark - Input requestor activation

- (BOOL)activateNextInputRequestor {
    AssertNotNilWithMessage(self.inputRequestorDataSource, @"inputRequestorDataSource has not been set");
    if (self.inputRequestorDataSource) {
        return [self activateInputRequestor:[self.inputRequestorDataSource nextInputRequestor:self.activeInputRequestor]];
    }
    return NO;
}

- (BOOL)activatePreviousInputRequestor {
    AssertNotNilWithMessage(self.inputRequestorDataSource, @"inputRequestorDataSource has not been set");
    if (self.inputRequestorDataSource) {
        return [self activateInputRequestor:[self.inputRequestorDataSource previousInputRequestor:self.activeInputRequestor]];
    }
    return NO;
}

- (BOOL)activateInputRequestor:(id<IBAInputRequestor>)inputRequestor {
    return ((inputRequestor != nil && [self setActiveInputRequestor:inputRequestor]));
}


#pragma mark - Retrieving input providers for input requestors

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


#pragma mark - Presenting the input provider

- (void)displayInputProvider:(id<IBAInputProvider>)inputProvider forInputRequestor:(id<IBAInputRequestor>)requestor {
    
    UIView *inputProviderView = inputProvider.view;
    
    if (nil != inputProviderCoordinator_ && requestor.displayStyle != IBAInputRequestorDisplayStylePopover) {
        return [inputProviderCoordinator_ setInputView:inputProviderView];
    }
    
    if (requestor.displayStyle == IBAInputRequestorDisplayStylePopover) {
        //prevent the keyboard from appearing
        [[requestor responder] setInputView:[[UIView alloc] initWithFrame:CGRectZero]];
        
        UIViewController *inputProviderController = [[IBAPoppedOverViewController alloc] initWithInputProviderView:inputProviderView];
        inputProviderController.edgesForExtendedLayout = UIRectEdgeNone;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:inputProviderController];
        inputProviderController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPopver)];
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        self.popoverController.delegate = self;
        self.popoverController.popoverContentSize = CGSizeMake(inputProviderView.frame.size.width, inputProviderView.frame.size.height + navController.navigationBar.frame.size.height);
        if (self.popoverBackgroundViewClass) {
            self.popoverController.popoverBackgroundViewClass = self.popoverBackgroundViewClass;
        }
        //if the responder is a text field, grab it's clear button and allow it to be pressed
        if ([requestor.responder isKindOfClass:[IBATextField class]]) {
            IBATextField *textField = (IBATextField *)requestor.responder;
            self.popoverController.passthroughViews = [NSArray arrayWithObjects:textField.clearButton, requestor.cell, nil];
        }
        
        [self.popoverController presentPopoverFromRect:requestor.cell.bounds inView:requestor.cell permittedArrowDirections:self.popoverPermittedArrowDirections animated:YES];
        
    } else {
        if (inputProviderView != nil) {
            [[requestor responder] setInputView:inputProviderView];
        }
        
        [self updateInputNavigationToolbarVisibility];
    }
}

- (void)dismissPopver
{
    if ([self popoverControllerShouldDismissPopover:self.popoverController]) {
        [self.popoverController dismissPopoverAnimated:YES];
        [self popoverControllerDidDismissPopover:self.popoverController];
    }
}

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return [self.activeInputRequestor deactivateForced:NO];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (self.popoverController == popoverController) {
        self.popoverController = nil;
        [self deactivateActiveInputRequestor];
    }
}


#pragma mark - Enablement of the input navigation toolbar

- (void)setInputNavigationToolbarEnabled:(BOOL)enabled {
    inputNavigationToolbarEnabled_ = enabled;
    
    [self updateInputNavigationToolbarVisibility];
}

- (void)updateInputNavigationToolbarVisibility {
    UIResponder *responder = [[self activeInputRequestor] responder];
    responder.inputAccessoryView = [self isInputNavigationToolbarEnabled] ? self.inputNavigationToolbar : nil;
    
    BOOL hasNextInputRequestor = [self.inputRequestorDataSource nextInputRequestor:self.activeInputRequestor] != nil;
    BOOL hasPrevInputRequestor = [self.inputRequestorDataSource previousInputRequestor:self.activeInputRequestor] != nil;
    
    [self.inputNavigationToolbar.nextPreviousButton setEnabled:hasPrevInputRequestor forSegmentAtIndex:0];
    [self.inputNavigationToolbar.nextPreviousButton setEnabled:hasNextInputRequestor forSegmentAtIndex:1];
}

#pragma mark - StatusBarOrientationCallBacks

- (void)applicationWillChangeStatusBarOrientation:(NSDictionary *)change
{
    if (self.activeInputRequestor.displayStyle == IBAInputRequestorDisplayStylePopover) {
        [self deactivateActiveInputRequestor];
    }
}

@end
