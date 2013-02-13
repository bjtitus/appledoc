//
//  GBProtocolData.h
//  appledoc
//
//  Created by Brandon Titus on 13.2.13.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"
#import "GBObjectDataProviding.h"

@class GBFrameworksProvider;

/** Describes a framework. */
@interface GBFrameworkData : GBModelBase <GBObjectDataProviding> {
    @private
	NSString *_frameworkName;
    GBFrameworksProvider *_frameworks;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased instance of the framework data with the given name.
 
 @param name The name of the framework.
 @return Returns initialized object.
 @exception NSException Thrown if the given name is `nil` or empty.
 */
+ (id)frameworkDataWithName:(NSString *)name;

/** Initializes the framework with he given name.
 
 This is the designated initializer.
 
 @param name The name of the framework.
 @return Returns initialized object.
 @exception NSException Thrown if the given name is `nil` or empty.
 */
- (id)initWithName:(NSString *)name;

///---------------------------------------------------------------------------------------
/// @name Protocol data
///---------------------------------------------------------------------------------------

/** The name of the framework. */
@property (readonly) NSString *nameOfFramework;

/** Frameworks the class is included in, available via `GBFrameworksProvider`. */
@property (readonly) GBFrameworksProvider *frameworks;

/** Protocol's methods, available via `GBMethodsProvider`. */
//@property (readonly) GBMethodsProvider *methods;

@end
