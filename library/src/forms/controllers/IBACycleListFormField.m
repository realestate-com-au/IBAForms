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

#import "IBACycleListFormField.h"
#import "IBATextFormFieldCell.h"
#import "IBAInputCommon.h"

#pragma mark -
#pragma mark IBACycleListFormField

@interface IBACycleListFormField ()
- (id)nextFormFieldValue;
@end

@implementation IBACycleListFormField

@synthesize cycleListCell = cycleListCell_;
@synthesize cycleListOptions = cycleListOptions_;

+ (id)formFieldWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer options:(NSArray *)options
{
    return [[self alloc] initWithKeyPath:keyPath title:title valueTransformer:valueTransformer options:options];
}

- (id)initWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer options:(NSArray *)options {
	if ((self = [super initWithKeyPath:keyPath title:title valueTransformer:valueTransformer])) {
		self.cycleListOptions = options;
	}
    
	return self;
}


#pragma mark -
#pragma mark Cell management

- (IBAFormFieldCell *)cell {
	if (cycleListCell_ == nil) {
		cycleListCell_ = [[IBATextFormFieldCell alloc] initWithFormFieldStyle:self.formFieldStyle reuseIdentifier:@"Cell"];
        cycleListCell_.textField.enabled = NO;
		cycleListCell_.textField.userInteractionEnabled = NO;	// read only
	}
    
	return cycleListCell_;
}

- (void)updateCellContents {
	if (cycleListCell_ != nil) {
		cycleListCell_.label.text = self.title;
        cycleListCell_.textField.text = [self formFieldStringValue];
	}
}

- (void)select
{
    [super select];
    
    self.formFieldValue = [self nextFormFieldValue];
}

- (id)nextFormFieldValue
{
    if (self.formFieldValue == [self.cycleListOptions lastObject])
    {
        return [self.cycleListOptions objectAtIndex:0];
    }
    else
    {
        return [self.cycleListOptions objectAtIndex:[self.cycleListOptions indexOfObject:self.formFieldValue] + 1];
    }
}

@end

#pragma mark -
#pragma mark IBACycleListFormOption

@interface IBACycleListFormOption ()
@property (nonatomic, readwrite, copy) NSString *name;
@end

@implementation IBACycleListFormOption

@synthesize name = name_;

+ (NSArray *)cycleListOptionsForStrings:(NSArray *)optionNames {
    NSMutableArray *options = [NSMutableArray array];
	for (NSString *optionName in optionNames) {
		[options addObject:[IBACycleListFormOption cycleListFormOptionWithName:optionName]];
	}
	
	return options;

}

+ (id)cycleListFormOptionWithName:(NSString *)name
{
    return [[self alloc] initWithName:name];
}

- (id)initWithName:(NSString *)name {
	if ((self = [super init])) {
		self.name = name;
	}
    
	return self;
}


- (NSString *)description {
	return self.name;
}

@end

#pragma mark -
#pragma IBAAbstractCycleListFormOptionsTransformer

@implementation IBAAbstractCycleListFormOptionsTransformer

@synthesize cycleListOptions = cycleListOptions_;

+ (id)cycleListFormOptionsTransformerWithOptions:(NSArray *)options
{
    return [[self alloc] initWithCycleListOptions:options];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)initWithCycleListOptions:(NSArray *)options
{
    if ((self = [super init]))
    {
        self.cycleListOptions = options;
    }
    
    return self;
}


@end

#pragma mark -
#pragma mark IBAFormSection Support for IBACycleListFormField

@implementation IBAFormSection (IBACycleListFormField)

- (id)cycleListFormFieldWithKeyPath:(NSString *)keyPath title:(NSString *)title valueTransformer:(NSValueTransformer *)valueTransformer options:(NSArray *)options
{
    IBACycleListFormField *field = [IBACycleListFormField formFieldWithKeyPath:keyPath title:title valueTransformer:valueTransformer options:options];
    [self addFormField:field];
    return field;
}

@end
