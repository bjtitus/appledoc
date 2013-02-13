//
//  GBFrameworkData
//  appledoc
//
//  Created by Brandon Titus on 13.2.12.
//

#import "GBDataObjects.h"
#import "GBFrameworkData.h"

@implementation GBFrameworkData

#pragma mark Initialization & disposal

+ (id)frameworkDataWithName:(NSString *)name {
	return [[[self alloc] initWithName:name] autorelease];
}

- (id)initWithName:(NSString *)name {
	NSParameterAssert(name != nil && [name length] > 0);
	GBLogDebug(@"Initializing protocol with name %@...", name);
	self = [super init];
	if (self) {
		_frameworkName = [name copy];
	}
	return self;
}

#pragma mark Overriden methods

- (void)mergeDataFromObject:(id)source {
	if (!source || source == self) return;
	GBLogDebug(@"%@: Merging data from %@...", self, source);
	NSParameterAssert([[source nameOfFramework] isEqualToString:self.nameOfFramework]);
	[super mergeDataFromObject:source];
	GBFrameworkData *sourceFramework = (GBFrameworkData *)source;
	[self.frameworks mergeDataFromFrameworksProvider:sourceFramework.frameworks];
//	[self.methods mergeDataFromMethodsProvider:sourceProtocol.methods];
}

- (NSString *)description {
	return self.nameOfFramework;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"framework %@", self.nameOfFramework];
}

- (BOOL)isTopLevelObject {
	return YES;
}

#pragma mark Properties

@synthesize nameOfFramework = _frameworkName;

@end
