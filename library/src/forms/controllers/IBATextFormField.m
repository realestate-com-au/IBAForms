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

#import "IBATextFormField.h"
#import "IBAFormConstants.h"
#import "IBAInputCommon.h"
#import "IBAInputManager.h"
#import "IBAInputManager.h"

@implementation IBATextFormField

@synthesize textFormFieldCell = textFormFieldCell_;
@synthesize maxCharacterLength = maxCharacterLength_;

- (id)initWithKeyPath:(NSString*)keyPath title:(NSString*)title valueTransformer:(NSValueTransformer *)valueTransformer {
	if ((self = [super initWithKeyPath:keyPath title:title valueTransformer:valueTransformer])) {
		self.maxCharacterLength = -1;
	}
  
	return self;
}



#pragma mark -
#pragma mark Cell management

- (IBAFormFieldCell *)cell {
	return [self textFormFieldCell];
}


- (IBATextFormFieldCell *)textFormFieldCell {
	if (textFormFieldCell_ == nil) {
		textFormFieldCell_ = [[IBATextFormFieldCell alloc] initWithFormFieldStyle:self.formFieldStyle reuseIdentifier:@"Cell"];
		textFormFieldCell_.textField.delegate = self;
		textFormFieldCell_.textField.enabled = NO;
	}
	
	return textFormFieldCell_;
}

- (void)updateCellContents {
	self.textFormFieldCell.label.text = self.title;
	self.textFormFieldCell.textField.text = [self formFieldStringValue];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return [[IBAInputManager sharedIBAInputManager] activateNextInputRequestor];;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
  // Enforce the maximum character length if it has been set
  NSInteger newLength = [textField.text length] + [string length] - range.length;
  return (self.maxCharacterLength < 0) || (self.maxCharacterLength >= newLength);
}

#pragma mark -
#pragma mark IBAInputRequestor

- (NSString *)dataType {
	return IBAInputDataTypeText;
}

- (void)activate {
	self.textFormFieldCell.textField.enabled = YES;
	[super activate];
}

- (BOOL)deactivateForced:(BOOL)forced {
	BOOL deactivated = [self pushChanges];
	if (deactivated || forced) {
		self.textFormFieldCell.textField.enabled = NO;
		deactivated = [super deactivateForced:forced];
	}
	
	return deactivated;
}

- (UIResponder *)responder {
	return self.textFormFieldCell.textField;
}


#pragma mark -
#pragma mark IBAFormField

- (BOOL)pushChanges {
	return [self setFormFieldValue:self.textFormFieldCell.textField.text];
}

@end

@implementation IBAFormSection (IBATextFormField)

- (IBATextFormField *)textFormFieldWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer
{
    IBATextFormField *field = [IBATextFormField formFieldWithKeyPath:keyPath title:title valueTransformer:valueTransformer];
    [self addFormField:field];
    return field;
}
                               
- (IBATextFormField *)textFormFieldWithKeyPath:(NSString *)keyPath title:(NSString *)title
{
    IBATextFormField *field = [IBATextFormField formFieldWithKeyPath:keyPath title:title];
    [self addFormField:field];
    return field;
}

- (IBATextFormField *)textFormFieldWithKeyPath:(NSString *)keyPath
{
    IBATextFormField *field = [IBATextFormField formFieldWithKeyPath:keyPath];
    [self addFormField:field];
    return field;
}

@end
