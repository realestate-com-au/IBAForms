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

#import "IBADecimalFormField.h"
#import "IBADecimalFormFieldCell.h"
#import "IBAInputManager.h"
#import "IBAFormConstants.h"
#import "IBAInputCommon.h"

@implementation IBADecimalFormField
{
  NSValueTransformer *displayTransformer_;
}

@synthesize formFieldCell = formFieldCell_, 
            numberFormatter = numberFormatter_,
            maximumDigits = maximumDigits_;

+ (id)formFieldWithKeyPath:(NSString *)keyPath 
                     title:(NSString *)title
          valueTransformer:(NSValueTransformer *)valueTransformer 
        displayTransformer:(NSValueTransformer *)displayTransformer
{
  return [[[self alloc] initWithKeyPath:keyPath title:title valueTransformer:valueTransformer displayTransformer:displayTransformer] autorelease];
}

- (id)initWithKeyPath:(NSString *)keyPath 
                title:(NSString *)title
     valueTransformer:(NSValueTransformer *)valueTransformer 
   displayTransformer:(NSValueTransformer *)displayTransformer
{
  if ((self = [super initWithKeyPath:keyPath title:title valueTransformer:valueTransformer]))
  {
    displayTransformer_ = [displayTransformer retain];
    maximumDigits_ = NSUIntegerMax;
  }
  
  return self;
}

- (void)dealloc {
	IBA_RELEASE_SAFELY(formFieldCell_);
	IBA_RELEASE_SAFELY(numberFormatter_);
  IBA_RELEASE_SAFELY(displayTransformer_);
  
	[super dealloc];
}

#pragma mark -
#pragma mark Cell management

- (IBAFormFieldCell *)cell {
	return [self formFieldCell];
}

- (IBADecimalFormFieldCell *)formFieldCell {
	if (formFieldCell_ == nil) {
		formFieldCell_ = [[IBADecimalFormFieldCell alloc] initWithFormFieldStyle:self.formFieldStyle reuseIdentifier:@"Cell"];
		formFieldCell_.valueTextField.delegate = self;
		formFieldCell_.valueTextField.enabled = NO;
	}
	
	return formFieldCell_;
}

- (NSNumberFormatter *)numberFormatter
{
  if (numberFormatter_ == nil) {
    numberFormatter_ = [[NSNumberFormatter alloc] init];
    [numberFormatter_ setLocale:[NSLocale currentLocale]];
    [numberFormatter_ setNumberStyle:NSNumberFormatterDecimalStyle];
  }
  
  return numberFormatter_;
}

- (void)updateCellContents {
  NSNumber *labelValue = (displayTransformer_ ? [displayTransformer_ transformedValue:[self formFieldValue]] : [self formFieldValue]);
  
	formFieldCell_.label.text = self.title;
	formFieldCell_.valueTextField.text = [self formFieldStringValue];
  formFieldCell_.valueLabel.text = [[self numberFormatter] stringFromNumber:labelValue];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return [[IBAInputManager sharedIBAInputManager] activateNextInputRequestor];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  if ([textField.text isEqualToString:@"0"])
  {
    textField.text = @"";
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  if (textField == formFieldCell_.valueTextField) {
    BOOL ok = ([formFieldCell_.valueTextField.text length] + [string length] - range.length) <= self.maximumDigits;
    if (ok == NO)
    {
      return NO;
    }
  }
  
  return YES;
}


#pragma mark -
#pragma mark IBAInputRequestor

- (NSString *)dataType {
	return IBAInputDataTypeNumber;
}

- (void)activate {
	formFieldCell_.valueTextField.enabled = YES;
	[super activate];
}

- (BOOL)deactivateForced:(BOOL)forced {
	BOOL deactivated = [self setFormFieldValue:formFieldCell_.valueTextField.text];
	if (deactivated || forced) {
		formFieldCell_.valueTextField.enabled = NO;
		deactivated = [super deactivateForced:forced];
	}
	
	return deactivated;
}

- (UIResponder *)responder {
	return formFieldCell_.valueTextField;
}

- (void)setNumberOfDecimals:(NSUInteger)numberOfDecimals {
  [[self numberFormatter] setMaximumFractionDigits:numberOfDecimals];
  [[self.formFieldCell valueTextField] setKeyboardType:(numberOfDecimals > 0 ? UIKeyboardTypeDecimalPad : UIKeyboardTypeNumberPad)];
}

@end

@implementation IBAFormSection (IBADecimalFormField)

- (IBADecimalFormField *)decimalFormFieldWithKeyPath:(NSString *)keyPath 
                                               title:(NSString *)title
                                    valueTransformer:(NSValueTransformer *)valueTransformer 
                                  displayTransformer:(NSValueTransformer *)displayTransformer
{
  IBADecimalFormField *field = [IBADecimalFormField formFieldWithKeyPath:keyPath title:title valueTransformer:valueTransformer displayTransformer:displayTransformer];
  [self addFormField:field];
  return field;
}

- (IBADecimalFormField *)decimalFormFieldWithKeyPath:(NSString *)keyPath 
                                               title:(NSString *)title
                                    valueTransformer:(NSValueTransformer *)valueTransformer
{
  IBADecimalFormField *field = [IBADecimalFormField formFieldWithKeyPath:keyPath title:title valueTransformer:valueTransformer];
  [self addFormField:field];
  return field;
}

@end
