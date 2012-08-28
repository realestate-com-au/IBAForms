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

#import <UIKit/UIKit.h>

@interface IBAFormFieldStyle : NSObject <NSCopying> {
	UIColor *labelTextColor_;
	UIColor *labelBackgroundColor_;
	UIFont *labelFont_;
	CGRect labelFrame_;
	UITextAlignment labelTextAlignment_;
	UIViewAutoresizing labelAutoresizingMask_;
  UIViewContentMode labelContentMode_;
  BOOL labelOpaque_;
	
	UIColor *valueTextColor_;
	UIColor *valueBackgroundColor_;
	UIFont *valueFont_;
	CGRect valueFrame_;
  BOOL valueOpaque_;

	UITextAlignment valueTextAlignment_;
	UIViewAutoresizing valueAutoresizingMask_;
  UIControlContentVerticalAlignment valueVerticalAlignment_;
  UIViewContentMode valueContentMode_;
	UIColor *activeBackgroundColor_;
  UIColor *backgroundColor_;
  UIView *activeBackgroundView_;
  UIView *backgroundView_;
}

@property (nonatomic, retain) UIColor *labelTextColor;
@property (nonatomic, retain) UIColor *labelBackgroundColor;
@property (nonatomic, retain) UIFont *labelFont;
@property (nonatomic, assign) CGRect labelFrame;
@property (nonatomic, assign) UITextAlignment labelTextAlignment;
@property (nonatomic, assign) UIViewAutoresizing labelAutoresizingMask;
@property (nonatomic, assign) UIViewContentMode labelContentMode;
@property (nonatomic, assign) BOOL labelOpaque;

@property (nonatomic, retain) UIColor *valueTextColor;
@property (nonatomic, retain) UIColor *valueBackgroundColor;
@property (nonatomic, retain) UIFont *valueFont;
@property (nonatomic, assign) CGRect valueFrame;
@property (nonatomic, assign) UITextAlignment valueTextAlignment;
@property (nonatomic, assign) UIViewAutoresizing valueAutoresizingMask;
@property (nonatomic, assign) UIControlContentVerticalAlignment valueVerticalAlignment;
@property (nonatomic, assign) UIViewContentMode valueContentMode;
@property (nonatomic, assign) BOOL valueOpaque;

@property (nonatomic, retain) UIColor *activeBackgroundColor;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIView *activeBackgroundView;
@property (nonatomic, retain) UIView *backgroundView;

- (void)setLabelX:(CGFloat)x;
- (void)setLabelY:(CGFloat)y;
- (void)setLabelWidth:(CGFloat)width;
- (void)setLabelHeight:(CGFloat)height;

- (void)setValueX:(CGFloat)x;
- (void)setValueY:(CGFloat)y;
- (void)setValueWidth:(CGFloat)width;
- (void)setValueHeight:(CGFloat)height;

@end
