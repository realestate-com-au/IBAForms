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

#import "IBAInputRequestorFormField.h"
#import "IBADecimalFormFieldCell.h"
#import "IBAFormSection.h"

@interface IBADecimalFormField : IBAInputRequestorFormField <UITextFieldDelegate>

@property (nonatomic, strong) IBADecimalFormFieldCell *formFieldCell;
@property (unsafe_unretained, nonatomic, readonly) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) UIImage *customClearButonImage;

/*!
 @abstract    A regular expression that if set validates the text entered into the form field.
 @discussion  When entering text into the field the value that would be the result after the text is inserted is
              evaluated against this expression.  If the value does not match against the expression the newly input
              text is rejected and the original value of the field is kept.
 */
@property (nonatomic, strong) NSRegularExpression *inputValidationRegularExpression_;

+ (id)formFieldWithKeyPath:(NSString *)keyPath 
                     title:(NSString *)title
          valueTransformer:(NSValueTransformer *)valueTransformer 
        displayTransformer:(NSValueTransformer *)displayTransformer
    customClearButtonImage:(UIImage *)image;

- (id)initWithKeyPath:(NSString *)keyPath 
                title:(NSString *)title
     valueTransformer:(NSValueTransformer *)valueTransformer 
   displayTransformer:(NSValueTransformer *)displayTransformer
customClearButtonImage:(UIImage *)image;

/*!
 @abstract    Sets the number of decimals to use when displaying/formatting the decimal value.
 */
- (void)setNumberOfDecimals:(NSUInteger)numberOfDecimals;

@end

@interface IBAFormSection (IBADecimalFormField)

- (IBADecimalFormField *)decimalFormFieldWithKeyPath:(NSString *)keyPath 
                                               title:(NSString *)title
                                    valueTransformer:(NSValueTransformer *)valueTransformer 
                                  displayTransformer:(NSValueTransformer *)displayTransformer
                              customClearButtonImage:(UIImage *)image;

- (IBADecimalFormField*)decimalFormFieldWithKeyPath:(NSString *)keyPath 
                                              title:(NSString *)title
                                   valueTransformer:(NSValueTransformer *)valueTransformer;


@end
