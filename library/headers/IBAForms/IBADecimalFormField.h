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

@property (nonatomic, retain) IBADecimalFormFieldCell *formFieldCell;
@property (nonatomic, readonly) NSNumberFormatter *numberFormatter;
@property (nonatomic, assign) NSUInteger maximumDigits;

+ (id)formFieldWithKeyPath:(NSString *)keyPath 
                         title:(NSString *)title
              valueTransformer:(NSValueTransformer *)valueTransformer 
            displayTransformer:(NSValueTransformer *)displayTransformer;

- (id)initWithKeyPath:(NSString *)keyPath 
                title:(NSString *)title
     valueTransformer:(NSValueTransformer *)valueTransformer 
   displayTransformer:(NSValueTransformer *)displayTransformer;

- (void)setNumberOfDecimals:(NSUInteger)numberOfDecimals;



@end

@interface IBAFormSection (IBADecimalFormField)

- (IBADecimalFormField *)decimalFormFieldWithKeyPath:(NSString *)keyPath 
                                               title:(NSString *)title
                                    valueTransformer:(NSValueTransformer *)valueTransformer 
                                  displayTransformer:(NSValueTransformer *)displayTransformer;

- (IBADecimalFormField*)decimalFormFieldWithKeyPath:(NSString *)keyPath 
                                              title:(NSString *)title
                                   valueTransformer:(NSValueTransformer *)valueTransformer;


@end
