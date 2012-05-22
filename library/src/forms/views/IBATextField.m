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


#import "IBATextField.h"

@interface IBATextField ()
- (void)clearContent;
@end


@implementation IBATextField

- (id)initWithFrame:(CGRect)frame customClearButtonImage:(UIImage *)image
{
  if (self = [super initWithFrame:frame]) 
  {
    if (image != nil)
    {
      UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [clearButton setImage:image forState:UIControlStateNormal];
      [clearButton setAdjustsImageWhenHighlighted:YES];
      
      [clearButton addTarget:self action:@selector(clearContent) forControlEvents:UIControlEventTouchUpInside];

      [self setRightView:clearButton];
      [self setRightViewMode:UITextFieldViewModeAlways];
    }
  }
  
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  return [self initWithFrame:frame customClearButtonImage:nil];
}

- (void)clearContent
{
  [self setText:nil];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
  UIImage *image = [(UIButton *)[self rightView] imageForState:UIControlStateNormal];
  return CGRectMake(bounds.size.width - 22 - floorf(image.size.width / 2), 0, bounds.size.height, bounds.size.height);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{  
  BOOL inside = [super pointInside:point withEvent:event];
  
  if (![[self rightView] isHidden])
  {
    return (CGRectContainsPoint([[self rightView] frame], point) || inside);
  }
  
  return inside;
}

@end
