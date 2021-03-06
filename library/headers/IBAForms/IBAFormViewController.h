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

#import <UIKit/UIKit.h>
#import "IBAFormDataSource.h"
#import "IBAInputNavigationToolbar.h"
#import "IBAInputRequestorDataSource.h"

@interface IBAFormViewController : UIViewController  <UITableViewDelegate, IBAInputRequestorDataSource> {
    UITableView *tableView_;
    CGRect tableViewOriginalFrame_;
    IBAFormDataSource *formDataSource_;
    CGRect keyboardFrame_;
    BOOL scrollEnabledOnFormFieldActivation_;

    @private
    UIView *hiddenCellCache_;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) CGRect tableViewOriginalFrame;
@property (nonatomic, strong) IBAFormDataSource *formDataSource;
@property (nonatomic, assign) BOOL scrollEnabledOnFormFieldActivation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
	   formDataSource:(IBAFormDataSource *)formDataSource;

/* Methods for subclasses to customise behaviour */

/*
 * Called before a cell is about to be displayed by the table view.
 * Does not need to call the super method.
 */
- (void)willDisplayCell:(IBAFormFieldCell *)cell forFormField:(IBAFormField *)formField atIndexPath:(NSIndexPath *)indexPath;

/*
 * Called before the input provider (eg, keyboard) is shown.
 */
- (void)willShowInputRequestorWithBeginFrame:(CGRect)beginFrame endFrame:(CGRect)endFrame animationDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve;

/*
 * Called before the input provider (eg, keyboard) is hidden.
 */
- (void)willHideInputRequestorWithBeginFrame:(CGRect)beginFrame endFrame:(CGRect)endFrame animationDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve;

/*
 * Called after the input provider (eg, keyboard) is hidden.
 */
- (void)didHideInputRequestorWithBeginFrame:(CGRect)beginFrame endFrame:(CGRect)endFrame animationDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve;

/*
 * Return YES if the table view should be automatically scrolled to the active field.
 * Defaults to YES.
 */
- (BOOL)shouldAutoScrollTableToActiveField;

@end
