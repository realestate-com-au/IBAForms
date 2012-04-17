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

#import "IBAFormFieldStyle.h"
#import "IBAFormConstants.h"

@implementation IBAFormFieldStyle

@synthesize labelTextColor = labelTextColor_;
@synthesize labelTextAlignment = labelTextAlignment_;
@synthesize labelBackgroundColor = labelBackgroundColor_;
@synthesize labelFont = labelFont_;
@synthesize labelFrame = labelFrame_;
@synthesize labelAutoresizingMask = labelAutoresizingMask_;
@synthesize valueTextColor = valueTextColor_;
@synthesize valueBackgroundColor = valueBackgroundColor_;
@synthesize valueFont = valueFont_;
@synthesize valueFrame = valueFrame_;
@synthesize valueTextAlignment = valueTextAlignment_;
@synthesize valueAutoresizingMask = valueAutoresizingMask_;
@synthesize activeColor = activeColor_;

- (void)dealloc {
	IBA_RELEASE_SAFELY(labelTextColor_);
	IBA_RELEASE_SAFELY(labelBackgroundColor_);
	IBA_RELEASE_SAFELY(labelFont_);
	
	IBA_RELEASE_SAFELY(valueTextColor_);
	IBA_RELEASE_SAFELY(valueBackgroundColor_);
	IBA_RELEASE_SAFELY(valueFont_);
	
	IBA_RELEASE_SAFELY(activeColor_);

	[super dealloc];
}


- (id)init {
	if ((self = [super init])) {
		self.labelTextColor = IBAFormFieldLabelTextColor;
		self.labelBackgroundColor = IBAFormFieldLabelBackgroundColor;
		self.labelFont = IBAFormFieldLabelFont;
		self.labelFrame = CGRectMake(IBAFormFieldLabelX, IBAFormFieldLabelY, IBAFormFieldLabelWidth, IBAFormFieldLabelHeight);
		self.labelTextAlignment = IBAFormFieldLabelTextAlignment;
		self.labelAutoresizingMask = UIViewAutoresizingFlexibleRightMargin;

		self.valueTextColor = IBAFormFieldValueTextColor;
		self.valueBackgroundColor = IBAFormFieldValueBackgroundColor;
		self.valueFont = IBAFormFieldValueFont;
		self.valueFrame = CGRectMake(IBAFormFieldValueX, IBAFormFieldValueY, IBAFormFieldValueWidth, IBAFormFieldValueHeight);
		self.valueTextAlignment = IBAFormFieldValueTextAlignment;
		self.valueAutoresizingMask = UIViewAutoresizingFlexibleWidth;

		self.activeColor = IBAFormFieldActiveColor;
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
  IBAFormFieldStyle *copy = [[IBAFormFieldStyle alloc] init];
  copy.labelTextColor = self.labelTextColor;
  copy.labelBackgroundColor = self.labelBackgroundColor;
  copy.labelFont = self.labelFont;
  copy.labelFrame = self.labelFrame;
  copy.labelTextAlignment = self.labelTextAlignment;
  copy.labelAutoresizingMask = self.labelAutoresizingMask;
  copy.labelContentMode = self.labelContentMode;
  copy.labelOpaque = self.labelOpaque;
  
  copy.valueTextColor = self.valueTextColor;
  copy.backgroundColor = self.backgroundColor;
  copy.valueFont = self.valueFont;
  copy.valueFrame = self.valueFrame;
  copy.valueTextAlignment = self.valueTextAlignment;
  copy.valueAutoresizingMask = self.valueAutoresizingMask;
  copy.valueVerticalAlignment = self.valueAutoresizingMask;
  copy.valueContentMode = self.valueContentMode;
  copy.valueOpaque = self.valueOpaque;
  
  copy.activeBackgroundColor = self.activeBackgroundColor;
  copy.backgroundColor = self.backgroundColor;
  
  return copy;
}

- (void)setLabelX:(CGFloat)x {
  CGRect frame = self.labelFrame;
  frame.origin.x = x;
  self.labelFrame = frame;
}

- (void)setLabelY:(CGFloat)y {
  CGRect frame = self.labelFrame;
  frame.origin.y = y;
  self.labelFrame = frame;
}

- (void)setLabelWidth:(CGFloat)width {
  CGRect frame = self.labelFrame;
  frame.size.width = width;
  self.labelFrame = frame;
}

- (void)setLabelHeight:(CGFloat)height {
  CGRect frame = self.labelFrame;
  frame.size.height = height;
  self.labelFrame = frame;
}

- (void)setValueX:(CGFloat)x {
  CGRect frame = self.valueFrame;
  frame.origin.x = x;
  self.valueFrame = frame;
}

- (void)setValueY:(CGFloat)y {
  CGRect frame = self.valueFrame;
  frame.origin.y = y;
  self.valueFrame = frame;
}

- (void)setValueWidth:(CGFloat)width {
  CGRect frame = self.valueFrame;
  frame.size.width = width;
  self.valueFrame = frame;
}

- (void)setValueHeight:(CGFloat)height {
  CGRect frame = self.valueFrame;
  frame.size.height = height;
  self.valueFrame = frame;
}


@end
