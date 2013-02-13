//
//  GBFrameworksProvider.h
//  appledoc
//
//  Created by Brandon Titus on 13.2.13.
//

#import <Foundation/Foundation.h>

@class GBFrameworkData;

/** A helper class that unifies adopted protocols handling.
 
 Dividing implementation of adopted protocols to a separate class allows us to abstract the logic and reuse it within any object that needs to handle adopted protocols using composition. It also simplifies protocols parsing and handling. To use it, simply "plug" it to the class that needs to handle adopted protocols and provide access through a public interface.
 
 The downside is that querrying code becomes a bit more verbose as another method or property needs to be sent before getting access to actual adopted protocols data.
 */
@interface GBFrameworksProvider : NSObject {
@private
	NSMutableSet *_frameworks;
	NSMutableDictionary *_frameworksByName;
	id _parent;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Initializes ivars provider with the given parent object.
 
 The given parent object is set to each `GBIvarData` registered through `registerIvar:`. This is the designated initializer.
 
 @param parent The parent object to be used for all registered ivars.
 @return Returns initialized object.
 @exception NSException Thrown if the given parent is `nil`.
 */
- (id)initWithParentObject:(id)parent;

///---------------------------------------------------------------------------------------
/// @name Adopted protocols handling
///---------------------------------------------------------------------------------------

/** Registers the given framework to the providers data.
 
 If provider doesn't yet have the given protocol instance registered, the object is added to `frameworks` list. If the same object is already registered, nothing happens.
 
 @warning *Note:* If another instance of the framework with the same name is registered, an exception is thrown.
 
 @param framework The framework to register.
 @exception NSException Thrown if the given framework is already registered.
 */
- (void)registerFramework:(GBFrameworkData *)framework;

/** Merges data from the given framework provider.
 
 This copies all unknown framework from the given source to receiver and invokes merging of data for receivers framework also found in source. It leaves source data intact.
 
 @param source `GBFrameworksProvider` to merge from.
 */
- (void)mergeDataFromFrameworksProvider:(GBFrameworksProvider *)source;

/** Replaces the given original adopted framework with the new one.
 
 This is provided so that processor can replace known framework "placeholders" with real ones..
 
 @param original Original framework to replace.
 @param framework The framework to replace with.
 @exception NSException Thrown if original framework is not in the current frameworks list or new framework is `nil`.
 */
- (void)replaceFramework:(GBFrameworkData *)original withFramework:(GBFrameworkData *)framework;

/** Returns the array of all framework sorted by their name. */
- (NSArray *)frameworksSortedByName;

/** The list of all protocols as instances of `GBFrameworkData`. */
@property (readonly) NSSet *frameworks;

@end
