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

#import "IBASinglePickListInputProvider.h"
#import "IBACommon.h"
#import "IBAPickListOptionsProvider.h"

@interface IBASinglePickListInputProvider ()
@property (nonatomic, readonly) UIPickerView *pickerView;
@property (nonatomic, readonly) UIView *providerView;
@end


@implementation IBASinglePickListInputProvider

@synthesize providerView = providerView_;
@synthesize pickerView = pickerView_;
@synthesize inputRequestor = inputRequestor_;

#pragma mark - Memory management


- (id)init {
    if ((self = [super init])) {
        providerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
        providerView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        providerView_.backgroundColor = [UIColor whiteColor];

        pickerView_ = [[UIPickerView alloc] initWithFrame:[providerView_ bounds]];
        pickerView_.showsSelectionIndicator = YES;
        pickerView_.dataSource = self;
        pickerView_.delegate = self;
        pickerView_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [providerView_ sizeToFit];

        [providerView_ addSubview:pickerView_];
    }

    return self;
}


- (void)setInputRequestor:(id<IBAInputRequestor>)inputRequestor {
    inputRequestor_ = inputRequestor;

    if (inputRequestor != nil) {
        [self.pickerView reloadAllComponents];
        [self updateSelectedOption];
    }
}


- (id<IBAPickListOptionsProvider>)pickListOptionsProvider {
    return ((id<IBAPickListOptionsProvider>)self.inputRequestor);
}


- (NSArray *)pickListOptions {
    return [self.pickListOptionsProvider pickListOptions];
}


#pragma mark - IBAInputProvider

- (UIView *)view {
    return self.providerView;
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickListOptions.count;
}


#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = nil;

    if ((view != nil) && ([view isKindOfClass:[UILabel class]])){
        label = (UILabel *)view;
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.bounds.size.width - 40, 44)];
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
    }

    id<IBAPickListOption> pickListOption = [self.pickListOptions objectAtIndex:row];

    label.text = pickListOption.name;
    label.font = pickListOption.font;

    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self setSelectedOptionWithIndex:row];
}


#pragma mark - Selection helpers

- (void)setSelectedOptionWithIndex:(NSInteger)optionIndex {
    id<IBAPickListOption> selectedOption = [self.pickListOptions objectAtIndex:optionIndex];
    [self setSelectedOption:selectedOption];
}


- (void)setSelectedOption:(id<IBAPickListOption>)selectedOption {
    if (nil == selectedOption) return;

    self.inputRequestor.inputRequestorValue = [NSSet setWithObject:selectedOption];
}

- (void)updateSelectedOption {
    // Updates the UI to display the selected option, or defaults to the first option if none are already selected
    id<IBAPickListOption> selectedPickListOption = [self.inputRequestor.inputRequestorValue anyObject];
    if (nil != selectedPickListOption) {
        NSInteger selectedRow = [self.pickListOptions indexOfObject:selectedPickListOption];
        [self.pickerView selectRow:selectedRow inComponent:0 animated:YES];
    } else {
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
    } 
}

@end
