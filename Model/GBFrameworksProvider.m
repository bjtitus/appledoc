//
//  GBAdoptedProtocolsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBFrameworkData.h"
#import "GBFrameworksProvider.h"

@implementation GBFrameworksProvider

#pragma mark Initialization & disposal

- (id)initWithParentObject:(id)parent {
	NSParameterAssert(parent != nil);
	GBLogDebug(@"Initializing adopted protocols provider for %@...", parent);
	self = [super init];
	if (self) {
		_parent = [parent retain];
		_frameworks = [[NSMutableSet alloc] init];
		_frameworksByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)init {
	[NSException raise:@"Initializer 'init' is not valid, use 'initWithParentObject:' instead!"];
	return nil;
}

#pragma mark Helper methods

- (void)registerFramework:(GBFrameworkData *)framework {
	NSParameterAssert(framework != nil);
	GBLogDebug(@"%@: Registering framework %@...", _parent, framework);
	if ([_frameworks containsObject:framework]) return;
	GBFrameworkData *existingFrameworks = [_frameworksByName objectForKey:framework.nameOfFramework];
	if (existingFrameworks) {
		[existingFrameworks mergeDataFromObject:framework];
		return;
	}
	if ([_frameworksByName objectForKey:framework.nameOfFramework])
		[NSException raise:@"Framework with name %@ is already registered!", framework.nameOfFramework];
	[_frameworks addObject:framework];
	[_frameworksByName setObject:framework forKey:framework.nameOfFramework];
}

- (void)mergeDataFromFrameworksProvider:(GBFrameworksProvider *)source {
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging adopted protocols from %@...", _parent, source->_parent);
	for (GBFrameworkData *sourceFramework in source.frameworks) {
		GBFrameworkData *existingFramework = [_frameworksByName objectForKey:sourceFramework.nameOfFramework];
		if (existingFramework) {
			[existingFramework mergeDataFromObject:sourceFramework];
			continue;
		}
		[self registerFramework:sourceFramework];
	}
}

- (void)replaceFramework:(GBFrameworkData *)original withFramework:(GBFrameworkData *)framework {
	NSParameterAssert(framework != nil);
	NSParameterAssert([self.frameworks containsObject:original]);
	[_frameworks removeObject:original];
	[_frameworks addObject:framework];
}

- (NSArray *)frameworksSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"frameworkName" ascending:YES]];
	return [[self.frameworks allObjects] sortedArrayUsingDescriptors:descriptors];
}

#pragma mark Overriden methods

- (NSString *)description {
	return [_parent description];
}

- (NSString *)debugDescription {
	NSMutableString *result = [NSMutableString string];
	if ([self.frameworks count] > 0) {
		[result appendString:@"<"];
		[[self frameworksSortedByName] enumerateObjectsUsingBlock:^(GBFrameworkData *framework, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendString:@", "];
			[result appendString:framework.nameOfFramework];
		}];
		[result appendString:@">"];
	}
	return result;
}

#pragma mark Properties

@synthesize frameworks = _frameworks;

@end
