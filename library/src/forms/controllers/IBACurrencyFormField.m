//
// Copyright 2012 Itty Bitty Apps Pty Ltd
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

#import "IBACurrencyFormField.h"
#import "IBACurrencyFormFieldCell.h"
#import "IBAInputManager.h"
#import "IBAFormConstants.h"
#import "IBAInputCommon.h"

@implementation IBACurrencyFormField

@synthesize currencyFormFieldCell = currencyFormFieldCell_, 
            currencyNumberFormatter = currencyNumberFormatter_;

- (void)dealloc {
	IBA_RELEASE_SAFELY(currencyFormFieldCell_);
	IBA_RELEASE_SAFELY(currencyNumberFormatter_);
    
	[super dealloc];
}


#pragma mark -
#pragma mark Cell management

- (IBAFormFieldCell *)cell {
	return [self currencyFormFieldCell];
}

- (IBACurrencyFormFieldCell *)currencyFormFieldCell {
	if (currencyFormFieldCell_ == nil) {
		currencyFormFieldCell_ = [[IBACurrencyFormFieldCell alloc] initWithFormFieldStyle:self.formFieldStyle reuseIdentifier:@"Cell"];
		currencyFormFieldCell_.valueTextField.delegate = self;
		currencyFormFieldCell_.valueTextField.enabled = NO;
	}
	
	return currencyFormFieldCell_;
}

- (NSNumberFormatter *)currencyNumberFormatter
{
    if (currencyNumberFormatter_ == nil) {
        currencyNumberFormatter_ = [[NSNumberFormatter alloc] init];
        [currencyNumberFormatter_ setLocale:[NSLocale currentLocale]];
        [currencyNumberFormatter_ setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    
    return currencyNumberFormatter_;
}

- (void)updateCellContents {
	currencyFormFieldCell_.label.text = self.title;
	currencyFormFieldCell_.valueTextField.text = [[self formFieldValue] stringValue];
  currencyFormFieldCell_.valueLabel.text = [[self currencyNumberFormatter] stringFromNumber:[self formFieldValue]];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return [[IBAInputManager sharedIBAInputManager] activateNextInputRequestor];;
}


#pragma mark -
#pragma mark IBAInputRequestor

- (NSString *)dataType {
	return IBAInputDataTypeNumber;
}

- (void)activate {
	currencyFormFieldCell_.valueTextField.enabled = YES;
	[super activate];
}

- (BOOL)deactivate {
	BOOL deactivated = [self setFormFieldValue:currencyFormFieldCell_.valueTextField.text];
	if (deactivated) {
		currencyFormFieldCell_.valueTextField.enabled = NO;
		deactivated = [super deactivate];
	}
	
	return deactivated;
}

- (UIResponder *)responder {
	return currencyFormFieldCell_.valueTextField;
}

@end
