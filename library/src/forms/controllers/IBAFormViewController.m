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

#import "IBAFormViewController.h"
#import "IBAFormConstants.h"
#import "IBAInputManager.h"

@interface IBAFormViewController ()
@property (nonatomic, retain) UIView *hiddenCellCache;
@end

@interface UIViewController (KeyboardDismissal)
- (BOOL)canDismissKeyboard;
@end

@implementation UIViewController (KeyboardDismissal)

- (BOOL)canDismissKeyboard {
    return (self.modalPresentationStyle != UIModalPresentationFormSheet) ||
    (self.modalPresentationStyle == UIModalPresentationFormSheet && [self respondsToSelector:@selector(disablesAutomaticKeyboardDismissal)] &&(![self disablesAutomaticKeyboardDismissal]));
}

@end


@interface IBAFormViewController ()
@property (nonatomic, assign) CGRect keyboardFrame;
@end

@implementation IBAFormViewController

@synthesize tableView = tableView_;
@synthesize tableViewOriginalFrame = tableViewOriginalFrame_;
@synthesize formDataSource = formDataSource_;
@synthesize keyboardFrame = keyboardFrame_;
@synthesize hiddenCellCache = hiddenCellCache_;
@synthesize scrollEnabledOnFormFieldActivation = scrollEnabledOnFormFieldActivation_;

#pragma mark - Initialisation and memory management

- (void)dealloc {
    [self releaseViews];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)releaseViews {
    tableView_ = nil;
    hiddenCellCache_ = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil formDataSource:(IBAFormDataSource *)formDataSource {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.formDataSource = formDataSource;
        self.hidesBottomBarWhenPushed = YES;
        self.scrollEnabledOnFormFieldActivation = YES;

        [self registerForNotifications];
    }

    return self;
}

- (void)registerForNotifications {
    [self registerSelector:@selector(inputManagerWillShow:) withNotification:UIKeyboardWillShowNotification];
    [self registerSelector:@selector(inputManagerDidHide:) withNotification:UIKeyboardDidHideNotification];

    [self registerSelector:@selector(formFieldActivated:) withNotification:IBAInputRequestorFormFieldActivated];

    [self registerSelector:@selector(pushViewController:) withNotification:IBAPushViewController];
    [self registerSelector:@selector(presentModalViewController:) withNotification:IBAPresentModalViewController];
    [self registerSelector:@selector(dismissModalViewController:) withNotification:IBADismissModalViewController];
}

- (void)registerSelector:(SEL)selector withNotification:(NSString *)notificationKey {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:notificationKey object:nil];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil formDataSource:nil];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self.formDataSource;
    self.tableView.delegate = self;

    hiddenCellCache_ = [[UIView alloc] initWithFrame:CGRectZero];
    [hiddenCellCache_ setAutoresizingMask:UIViewAutoresizingNone];
    [hiddenCellCache_ setHidden:YES];
    [hiddenCellCache_ setClipsToBounds:YES];

    tableViewOriginalFrame_ = self.tableView.frame;
}

- (void)viewDidUnload {
    [self releaseViews];

    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    /* For compatibility with both iOS 6 and earlier
     */
    if ([self isViewLoaded] && self.view.window == nil)
    {
        self.view = nil;
        [self viewDidUnload];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[IBAInputManager sharedIBAInputManager] setInputRequestorDataSource:self];

    /* Note: JC - The Done button will only dismiss a a modal in UIPresentModalFormSheet mode if your UIViewController/UINavigationController implements disablesAutomaticKeyboardDismissal.
     Get learned here: http://stackoverflow.com/questions/3019709/modal-dialog-does-not-dismiss-keyboard
     and here: http://stackoverflow.com/questions/3372333/ipad-keyboard-will-not-dismiss-if-modal-view-controller-presentation-style-is-ui
     As noted in the above SO pages this behaviour is only supported in iOS 4.3.

     Additionally, this causes all sorts of issues with the DONE button, NEXT and PREVIOUS too. Best to just leave it how it was for now ;(
     */

    // SW. There is a bug with UIModalPresentationFormSheet where the keyboard won't dismiss even when there is
    // no first responder, so we remove the 'Done' button when UIModalPresentationFormSheet is used. Prior to iOS 4.3 there
    // was no way aroud this. After 4.3 you can override '-(BOOL)disablesAutomaticKeyboardDismissal' on UIViewController
    // to make the keyboard dismiss properly.

    //[[[IBAInputManager sharedIBAInputManager] inputNavigationToolbar] setDisplayDoneButton:YES];
    [[[IBAInputManager sharedIBAInputManager] inputNavigationToolbar] setDisplayDoneButton:([self canDismissKeyboard] && [self.navigationController canDismissKeyboard])];

  
	// Make sure the hidden cell cache is attached to the view hierarchy
	if ([self.hiddenCellCache window] == nil) {
		if ([self.view isKindOfClass:[UITableView class]]) {
			NSLog(@"Hidden cell cache will be added to a UITableView. This will generate log messages when cells that are in the cache are made the first reponder. To avoid these messages, ensure that the IBAFormViewController's view is not a UITableView.");
		}
		
		[self.view addSubview:self.hiddenCellCache];
	}
	
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if ([[IBAInputManager sharedIBAInputManager] inputRequestorDataSource] == self) {
        [[IBAInputManager sharedIBAInputManager] forceDeactivateActiveInputRequestor];
        [[[IBAInputManager sharedIBAInputManager] inputNavigationToolbar] setDisplayDoneButton:YES];
        [[IBAInputManager sharedIBAInputManager] setInputRequestorDataSource:nil];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[IBAInputManager sharedIBAInputManager] activeInputRequestor] != nil) {
        [self makeActiveFormFieldVisibleWithAnimation:YES];
    }
}

#pragma mark - Property management

- (void)tagHiddenCellCacheForRemoval {
    for (UIView *view in hiddenCellCache_.subviews) {
        view.tag = IBAHiddenCellCacheRemovalTag;
    }
}

- (void)clearHiddenCellCache {
    [self tagHiddenCellCacheForRemoval];
    
    for (UIView *view in hiddenCellCache_.subviews) {
        [view removeFromSuperview];
    }
}

// this setter also sets the datasource of the tableView and reloads the table
- (void)setFormDataSource:(IBAFormDataSource *)dataSource {
    if (dataSource != formDataSource_) {
        formDataSource_ = dataSource;
        
        [self clearHiddenCellCache];
        
        self.tableView.dataSource = formDataSource_;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IBAFormField *formField = [self.formDataSource formFieldAtIndexPath:indexPath];
    if ([formField hasDetailViewController]) {
        // The row has a detail view controller that we should push on to the navigation stack
        [[self navigationController] pushViewController:[formField detailViewController] animated:YES];
    } else if ([formField conformsToProtocol:@protocol(IBAInputRequestor)]){
        // Start editing the form field
        [[IBAInputManager sharedIBAInputManager] setActiveInputRequestor:(id<IBAInputRequestor>)formField];
    } else {
        [formField select];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self.formDataSource viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return MAX(CGRectGetHeight([[self.formDataSource viewForHeaderInSection:section] frame]), 0.);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(IBAFormFieldCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// SW. So, what's all this business about setting the cell's hidden cell cache? Well, let me tell you a little story
	// about UIResponders. If you call becomeFirstResponder on a UIResponder that is not in the view hierarchy, it doesn't
	// become the first responder. 'So what', you might ask. Well, when cells in a UITableView scroll out of view, they
	// are removed from the view hierarchy. If you select a cell, then scroll it up out of view, when you press the 'Previous'
	// button in the toolbar, the forms framework tries to activate the previous cell and make it the first responder.
	// The previous cell won't be in the view hierarchy, and the becomeFirstResponder call will fail. We tried all sorts
	// of workarounds, but the one that seems to work is to put the cells into a hidden view when they are removed from the
	// UITableView, so that they are still in the view hierarchy. We ended up making this hidden view a subview of the 
	// UIViewController's view. 
	[cell setHiddenCellCache:self.hiddenCellCache];

    [cell updateActiveStyle];

    if ([self respondsToSelector:@selector(willDisplayCell:forFormField:atIndexPath:)]) {
        IBAFormField *formField = [formDataSource_ formFieldAtIndexPath:indexPath];
        [self willDisplayCell:cell forFormField:formField atIndexPath:indexPath];
    }
}


#pragma mark - IBAInputRequestorDataSource

- (id<IBAInputRequestor>)nextInputRequestor:(id<IBAInputRequestor>)currentInputRequestor {
    // Return the next form field that supports inline editing
    IBAFormField *nextField = [self.formDataSource formFieldAfter:(IBAFormField *)currentInputRequestor];
    while ((nextField != nil) && (![nextField conformsToProtocol:@protocol(IBAInputRequestor)])) {
        nextField = [self.formDataSource formFieldAfter:nextField];
    }

    return (id<IBAInputRequestor>)nextField;
}


- (id<IBAInputRequestor>)previousInputRequestor:(id<IBAInputRequestor>)currentInputRequestor {
    // Return the previous form field that supports inline editing
    IBAFormField *previousField = [self.formDataSource formFieldBefore:(IBAFormField *)currentInputRequestor];
    while ((previousField != nil) && (![previousField conformsToProtocol:@protocol(IBAInputRequestor)])) {
        previousField = [self.formDataSource formFieldBefore:previousField];
    }

    return (id<IBAInputRequestor>)previousField;
}


#pragma mark - Responses to IBAInputManager notifications

- (void)inputManagerWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];

    CGRect keyboardBeginFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    // TODO: fix frames as described in Apple docs using convertRect:fromView?

    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];


    [self willShowInputRequestorWithBeginFrame:keyboardBeginFrame endFrame:keyboardEndFrame animationDuration:animationDuration animationCurve:animationCurve];

    [self adjustTableViewHeightForCoveringFrame:[self rectForOrientationFrame:keyboardBeginFrame]];

    [[self tableView] setScrollEnabled:[self scrollEnabledOnFormFieldActivation]];
}

- (void)inputManagerDidHide:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];

    CGRect keyboardBeginFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    // TODO: fix frames as described in Apple docs using convertRect:fromView?

    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];

    [self didHideInputRequestorWithBeginFrame:keyboardBeginFrame endFrame:keyboardEndFrame animationDuration:animationDuration animationCurve:animationCurve];
    if (![[IBAInputManager sharedIBAInputManager] activeInputRequestor]) {
        [self adjustTableViewHeightForCoveringFrame:CGRectZero];
        [[self tableView] setScrollEnabled:YES];
    }
}

- (void)formFieldActivated:(NSNotification *)notification {
    IBAFormField *formField = [[notification userInfo] objectForKey:IBAFormFieldKey];
    if (formField != nil) {
        [self makeFormFieldVisible:formField animated:YES];
        if ([formField hasDetailViewController]) {
            // The form field has a detail view controller that we should push on to the navigation stack
            [[self navigationController] pushViewController:[formField detailViewController] animated:YES];
        }
    }
}

#pragma mark - Size and visibility accommodations for the input manager view

- (void)makeActiveFormFieldVisibleWithAnimation:(BOOL)animate {
    if ([[IBAInputManager sharedIBAInputManager] activeInputRequestor] != nil) {
        [self makeFormFieldVisible:(IBAFormField *)[[IBAInputManager sharedIBAInputManager] activeInputRequestor] animated:animate];
    }
}

- (void)makeFormFieldVisible:(IBAFormField *)formField animated:(BOOL)animate {
    if ([self shouldAutoScrollTableToActiveField] && [formField shouldAutoScrollFormWhenActive]) {
        NSIndexPath *formFieldIndexPath = [self.formDataSource indexPathForFormField:formField];
        [self.tableView scrollToRowAtIndexPath:formFieldIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animate];
    }
}

- (void)adjustTableViewHeightForCoveringFrame:(CGRect)coveringFrame {
    if (!CGRectEqualToRect(coveringFrame, self.keyboardFrame)) {
        self.keyboardFrame = coveringFrame;
        CGRect normalisedWindowBounds = [self rectForOrientationFrame:[[[UIApplication sharedApplication] keyWindow] bounds]];
        CGRect normalisedTableViewFrame = [self rectForOrientationFrame:[self.tableView.superview convertRect:self.tableView.frame
                                                                                                       toView:[[UIApplication sharedApplication] keyWindow]]];

        CGFloat height = (CGRectEqualToRect(coveringFrame, CGRectZero)) ? 0 :
        coveringFrame.size.height - (normalisedWindowBounds.size.height - CGRectGetMaxY(normalisedTableViewFrame));
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, height, 0);
        //NSLog(@"UIEdgeInsets contentInsets bottom %f", contentInsets.bottom);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }

}


#pragma mark - Push view controller requests

- (void)pushViewController:(NSNotification *)notification {
    UIViewController *viewController = [[notification userInfo] objectForKey:IBAViewControllerKey];
    if (viewController != nil) {
        [[self navigationController] pushViewController:viewController animated:YES];
    }
}


#pragma mark - Present modal view controller requests

- (void)presentModalViewController:(NSNotification *)notification {
    UIViewController *viewController = [[notification userInfo] objectForKey:IBAViewControllerKey];
    if (viewController != nil) {
        [self presentModalViewController:viewController animated:YES];
    }
}

- (void)dismissModalViewController:(NSNotification *)notification; {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Misc

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.formDataSource tableView:aTableView cellForRowAtIndexPath:indexPath];
    [cell sizeToFit];
    return cell.bounds.size.height;
}

- (CGRect)rectForOrientationFrame:(CGRect)frame {
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return frame;
    }
    else
    {
        return CGRectMake(frame.origin.y, frame.origin.x, frame.size.height, frame.size.width);
    }
}

#pragma mark - Methods for subclasses to customise behaviour

- (void)willDisplayCell:(IBAFormFieldCell *)cell forFormField:(IBAFormField *)formField atIndexPath:(NSIndexPath *)indexPath {
    // NO-OP; subclasses to override
}

- (BOOL)shouldAutoScrollTableToActiveField {
    // Return YES if the table view should be automatically scrolled to the active field
    // Defaults to YES

    return YES;
}

- (void)didHideInputRequestorWithBeginFrame:(CGRect)beginFrame endFrame:(CGRect)endFrame animationDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve {
    // NO-OP; subclasses to override
}

- (void)willShowInputRequestorWithBeginFrame:(CGRect)beginFrame endFrame:(CGRect)endFrame animationDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve {
    // NO-OP; subclasses to override
}

@end
