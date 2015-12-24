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
#import "IBAFormConstants.h"


@implementation IBAInputRequestorFormField
@synthesize displayStyle = displayStyle_;

- (id)initWithKeyPath:(NSString*)keyPath title:(NSString*)title valueTransformer:(NSValueTransformer *)valueTransformer {
    if ((self = [super initWithKeyPath:keyPath title:title valueTransformer:valueTransformer]))
    {
        self.displayStyle = IBAInputRequestorDisplayStyleKeyboard;
    }
    return self;
}

#pragma mark - IBAInputRequestor

- (NSString *)dataType {
    NSAssert(NO, @"Subclasses of IBAInputRequestorFormField should override dataType");
    return nil;
}

- (BOOL)isAtLeastiOS92 {
    NSOperatingSystemVersion ios9_2 = (NSOperatingSystemVersion){9, 2, 0};
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios9_2];
}

- (void)activate {
    if ([self isAtLeastiOS92]) {
        // FIXME: this is a walk-around to fix a crash for iOS 9.2 when change the selection of Cell.
        // We tried different combination of settings (disable keyboard animation, delay) and found out this one didn't crash the app.
        // We need to enable the animation back somewhere for iOS 9.2
        [UIView setAnimationsEnabled:NO];
        [self.responder performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.05];
    }
    else {
        [self.responder becomeFirstResponder];
    }

    NSDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self,IBAFormFieldKey,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:IBAInputRequestorFormFieldActivated object:self userInfo:userInfo];

    if ([self hasDetailViewController]) {
        // If the form field has a detailViewController, then it should be displayed, and the form field should
        // be unselected when the detailViewController is popped back of the navigation stack
        [self deactivate];
    } else {
        // Give the cell a chance to change it's visual state to show that it has been activated
        [self.cell activate];
    }
}

- (BOOL)deactivate {
    return [self deactivateForced:NO];
}

- (BOOL)deactivateForced:(BOOL)forced {
    NSDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self,IBAFormFieldKey,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:IBAInputRequestorFormFieldDeactivated object:self userInfo:userInfo];

    [self.cell deactivate];

    return YES;
}

- (id)inputRequestorValue {
    return [self formFieldValue];
}

- (void)setInputRequestorValue:(id)aValue {
    [self setFormFieldValue:aValue];
}

- (id)defaultInputRequestorValue {
    return nil;
}

- (UIResponder *)responder {
    return self.cell;
}

- (BOOL)shouldAutoScrollFormWhenActive
{
    return !(self.displayStyle == IBAInputRequestorDisplayStylePopover);
}

- (void)setDisplayStyle:(IBAInputRequestorDisplayStyle)displayStyle
{
    if (displayStyle == IBAInputRequestorDisplayStylePopover && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"IBAInputRequestorDisplayStylePopover can only be used on iPad" userInfo:nil];
    }
    displayStyle_ = displayStyle;
}

@end
