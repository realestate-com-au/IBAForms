//
//  IBACycleListOptionsProvider.h
//  IBAForms
//
//  Created by Oliver Jones on 13/02/12.
//  Copyright (c) 2012 Deeper Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IBACycleListOptionsProvider <NSObject>
- (NSArray *)cycleListOptions;
@end

@protocol IBACycleListOption <NSObject>
@property (nonatomic, readonly, copy) NSString *name;
@end
