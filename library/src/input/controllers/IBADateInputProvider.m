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

#import "IBADateInputProvider.h"
#import "IBACommon.h"

@interface IBADateInputProvider ()
@property (nonatomic, strong, readonly) UIView *datePickerView;
@property (nonatomic, strong, readonly) UIDatePicker *datePicker;
@end


@implementation IBADateInputProvider

@synthesize inputRequestor = inputRequestor_;
@synthesize datePickerMode = datePickerMode_;
@synthesize datePicker = datePicker_;


- (id)init {
    return [self initWithDatePickerMode:UIDatePickerModeDate];
}

- (id)initWithDatePickerMode:(UIDatePickerMode)datePickerMode {
    if ((self = [super init])) {
        self.datePickerMode = datePickerMode;
    }

    return self;
}


#pragma mark - Accessors

- (UIView *)datePickerView {
    if (datePickerView_ == nil) {

        datePicker_ = [[UIDatePicker alloc] init];
        datePicker_.datePickerMode = self.datePickerMode;
        datePicker_.minuteInterval = 5;
        [datePicker_ addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];

        datePickerView_ = [[UIView alloc] initWithFrame:[datePicker_ frame]];
        datePickerView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        datePickerView_.backgroundColor = [UIColor viewFlipsideBackgroundColor];
        [datePickerView_ addSubview:datePicker_];
    }

    return datePickerView_;
}


#pragma mark - IBAInputProvider

- (UIView *)view {
    return self.datePickerView;
}


#pragma mark -  Date value change management

- (void)datePickerValueChanged {
    inputRequestor_.inputRequestorValue = self.datePicker.date;
}


- (void)setInputRequestor:(id<IBAInputRequestor>)inputRequestor {
    inputRequestor_ = inputRequestor;

    if (inputRequestor != nil) {
        // update the date picker's value with that of the new inputRequestors current value
        NSDate *date = inputRequestor.inputRequestorValue;
        if (date == nil) {
            date = inputRequestor.defaultInputRequestorValue;
            inputRequestor.inputRequestorValue = date;
        }

        [self.datePicker setDate:date animated:YES];
    }
}

@end
