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

#import "IBAInputRequestorFormField.h"
#import "IBATextFormFieldCell.h"
#import "IBACycleListOptionsProvider.h"
#import "IBAFormSection.h"

@interface IBACycleListFormField : IBAFormField <IBACycleListOptionsProvider>

@property (nonatomic, readonly) IBATextFormFieldCell *cycleListCell;
@property (nonatomic, copy) NSArray *cycleListOptions;

+ (id)formFieldWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer options:(NSArray *)options;
- (id)initWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer options:(NSArray *)options;

@end

@interface IBACycleListFormOption : NSObject <IBACycleListOption> 

+ (NSArray *)cycleListOptionsForStrings:(NSArray *)optionNames;

+ (id)cycleListFormOptionWithName:(NSString *)name;
- (id)initWithName:(NSString *)name;

@end

@interface IBAAbstractCycleListFormOptionsTransformer : NSValueTransformer

@property (nonatomic, copy) NSArray *cycleListOptions;
- (id)initWithCycleListOptions:(NSArray *)options;
+ (id)cycleListFormOptionsTransformerWithOptions:(NSArray *)options;

@end

@interface IBAFormSection (IBACycleListFormField)
- (id)cycleListFormFieldWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer options:(NSArray *)options;
@end