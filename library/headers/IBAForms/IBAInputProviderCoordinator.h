//
//  IBAInputProviderCoordinator.h
//  IBAForms
//
//  Created by Luke Cunningham on 1/06/11.
//  Copyright 2011 icaruswings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol IBAInputProviderCoordinator <NSObject>

- (void)showInputView:(BOOL)animated;
- (void)dismissInputView:(BOOL)animated;
- (void)setInputView:(UIView *)inputView;

@end
