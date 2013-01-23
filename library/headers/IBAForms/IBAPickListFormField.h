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
#import "IBAPickListOptionsProvider.h"
#import "IBAFormSection.h"


@interface IBAPickListFormField : IBAInputRequestorFormField <IBAPickListOptionsProvider> {
    IBATextFormFieldCell *pickListCell_;
    IBAPickListSelectionMode selectionMode_;
    NSArray *pickListOptions_;
}

@property (nonatomic, strong) IBATextFormFieldCell *pickListCell;
@property (nonatomic, assign) IBAPickListSelectionMode selectionMode;
@property (nonatomic, copy) NSArray *pickListOptions;

+ (id)formFieldWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer
             selectionMode:(IBAPickListSelectionMode)selectionMode options:(NSArray *)pickListOptions;

- (id)initWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer
        selectionMode:(IBAPickListSelectionMode)selectionMode options:(NSArray *)pickListOptions;

@end

@interface IBAPickListFormOption : NSObject <IBAPickListOption> {
	UIFont *font_;
	NSString *name_;
	UIImage *iconImage_;
}

+ (NSArray *)pickListOptionsForStrings:(NSArray *)optionNames;
+ (NSArray *)pickListOptionsForStrings:(NSArray *)optionNames font:(UIFont *)font;
- (id)initWithName:(NSString *)name iconImage:(UIImage *)iconImage font:(UIFont *)font;

@end

@interface IBAAbstractPickListFormOptionsTransformer : NSValueTransformer
- (id)initWithPickListOptions:(NSArray *)pickListOptions;
@property (nonatomic, copy) NSArray *pickListOptions;
+ (id)pickListFormOptionsTransformerWithOptions:(NSArray *)options;
@end

@interface IBAPickListFormOptionsStringTransformer : IBAAbstractPickListFormOptionsTransformer
@end

@interface IBASingleIndexTransformer : IBAAbstractPickListFormOptionsTransformer
@end

@interface IBAFormSection (IBAPickListFormField)

- (id)pickListFormFieldWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer
                     selectionMode:(IBAPickListSelectionMode)selectionMode options:(NSArray *)pickListOptions;
@end
