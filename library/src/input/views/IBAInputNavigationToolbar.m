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

#import "IBAInputNavigationToolbar.h"
#import "IBACommon.h"

#define IBAInputNavigationToolbarNextTitle NSLocalizedString(@"Next", @"IBAInputNavigationToolbarNextTitle")
#define IBAInputNavigationToolbarPreviousTitle NSLocalizedString(@"Previous", @"IBAInputNavigationToolbarPreviousTitle")

@interface IBAInputNavigationToolbar ()
@property (nonatomic, strong) UIBarButtonItem *nextPreviousBarButtonItem;
@end

@implementation IBAInputNavigationToolbar

@synthesize doneButton = doneButton_;
@synthesize nextPreviousButton = nextPreviousButton_;
@synthesize nextPreviousBarButtonItem = nextPreviousBarButtonItem_;
@synthesize displayDoneButton = displayDoneButton_;
@synthesize displayNextPreviousButton = displayNextPreviousButton_;
@synthesize doneButtonPosition = doneButtonPosition_;


- (id)initWithFrame:(CGRect)aRect {
    if ((self = [super initWithFrame:(CGRect)aRect])) {
        
        doneButton_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];

        nextPreviousButton_ = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:IBAInputNavigationToolbarPreviousTitle, IBAInputNavigationToolbarNextTitle, nil]];
        nextPreviousButton_.segmentedControlStyle = UISegmentedControlStyleBar;
        
        nextPreviousButton_.momentary = YES;
        UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
        [nextPreviousButton_ setTitleTextAttributes:attributes forState:UIControlStateNormal];

        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
        {
            self.barStyle = UIBarStyleDefault;
        }
        else
        {
            self.barStyle = UIBarStyleBlack;
            nextPreviousButton_.tintColor = [UIColor blackColor];
        }

        nextPreviousBarButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:self.nextPreviousButton];

        displayDoneButton_ = YES;
        displayNextPreviousButton_ = YES;
        doneButtonPosition_ = IBAInputNavigationToolbarDoneButtonPositionLeft;
        
        [self updateButtons];
    }

    return self;
}


- (void)setDisplayDoneButton:(BOOL)display {
    displayDoneButton_ = display;
    [self updateButtons];
}

- (void)setDisplayNextPreviousButton:(BOOL)display {
    displayNextPreviousButton_ = display;
    [self updateButtons];
}

- (void)updateButtons {
    NSMutableArray *barItems = [NSMutableArray array];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (doneButtonPosition_ == IBAInputNavigationToolbarDoneButtonPositionLeft) {
        if (self.displayDoneButton) {
            [barItems addObject:doneButton_];
        }
        [barItems addObject:spacer];
        if (self.displayNextPreviousButton) {
            [barItems addObject:nextPreviousBarButtonItem_];
        }
    } else {
        if (self.displayNextPreviousButton) {
            [barItems addObject:nextPreviousBarButtonItem_];
        }
        [barItems addObject:spacer];
        if (self.displayDoneButton) {
            [barItems addObject:doneButton_];
        }
    }
    
    [self setItems:barItems animated:YES];
}

@end
