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

#import <Foundation/Foundation.h>
#import "IBAFormFieldCell.h"

typedef enum {
  IBAInputRequestorDisplayStyleKeyboard = 0,
  IBAInputRequestorDisplayStylePopover,
} IBAInputRequestorDisplayStyle;

@protocol IBAInputRequestor <NSObject>

@property (nonatomic, readonly) NSString *dataType;
@property (nonatomic, weak) id inputRequestorValue;
@property (nonatomic, readonly) id defaultInputRequestorValue;
@property (nonatomic, readonly) UIResponder *responder;
@property (nonatomic, assign) IBAInputRequestorDisplayStyle displayStyle;
@property (nonatomic, readonly) IBAFormFieldCell *cell;

- (void)activate;
- (BOOL)deactivate;
- (BOOL)deactivateForced:(BOOL)forced;

@end
