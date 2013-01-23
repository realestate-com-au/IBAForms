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

#import "IBADecimalFormFieldCell.h"
#import "IBAFormConstants.h"
#import "IBATextField.h"


@implementation IBADecimalFormFieldCell

@synthesize valueTextField = valueTextField_;
@synthesize valueLabel = valueLabel_;


- (id)initWithFormFieldStyle:(IBAFormFieldStyle *)style customClearButtonImage:(UIImage *)image reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithFormFieldStyle:style reuseIdentifier:reuseIdentifier])) {
    
		// Create the text field for data entry (hidden by default)
		valueTextField_ = [[IBATextField alloc] initWithFrame:style.valueFrame customClearButtonImage:image];
		valueTextField_.autoresizingMask = style.valueAutoresizingMask;
		valueTextField_.returnKeyType = UIReturnKeyNext;
    valueTextField_.hidden = YES;
    valueTextField_.keyboardType = UIKeyboardTypeDecimalPad;
    valueTextField_.clipsToBounds = NO;
    
    // Create the lable for data display (shown by default)
    valueLabel_ = [[UILabel alloc] initWithFrame:style.valueFrame];
    valueLabel_.autoresizingMask = style.valueAutoresizingMask;
    valueLabel_.hidden = NO;
    
		[self.cellView addSubview:valueTextField_];
    [self.cellView addSubview:valueLabel_];
    [self applyFormFieldStyle];
	}
	
  return self;
}

- (void)activate {
	[super activate];
	 
  valueTextField_.hidden = NO;
  valueLabel_.hidden = YES;
}

- (void)deactivate
{
  [super deactivate];
  
  valueTextField_.hidden = YES;
  valueLabel_.hidden = NO;
}


- (void)applyFormFieldStyle {
	[super applyFormFieldStyle];
	
	valueTextField_.font = self.formFieldStyle.valueFont;
  valueTextField_.textColor = self.formFieldStyle.valueTextColor;
  valueTextField_.backgroundColor = self.formFieldStyle.valueBackgroundColor;
  valueTextField_.textAlignment = self.formFieldStyle.valueTextAlignment;
  valueTextField_.contentVerticalAlignment = self.formFieldStyle.valueVerticalAlignment;
  valueTextField_.contentMode = self.formFieldStyle.valueContentMode;
  valueTextField_.opaque = self.formFieldStyle.valueOpaque;
  
  valueLabel_.font = self.formFieldStyle.valueFont;
  valueLabel_.textColor = self.formFieldStyle.valueTextColor;
  valueLabel_.backgroundColor = self.formFieldStyle.valueBackgroundColor;
  valueLabel_.textAlignment = self.formFieldStyle.valueTextAlignment;
  valueLabel_.contentMode = self.formFieldStyle.valueContentMode;
  valueLabel_.opaque = self.formFieldStyle.valueOpaque;
}

@end