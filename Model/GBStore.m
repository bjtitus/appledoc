//
//  GBStore.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBStore.h"

@implementation GBStore

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		_classes = [[NSMutableSet alloc] init];
		_classesByName = [[NSMutableDictionary alloc] init];
		_categories = [[NSMutableSet alloc] init];
		_categoriesByName = [[NSMutableDictionary alloc] init];
		_protocols = [[NSMutableSet alloc] init];
		_protocolsByName = [[NSMutableDictionary alloc] init];
        _frameworks = [[NSMutableSet alloc] init];
        _frameworksByName = [[NSMutableDictionary alloc] init];
		_documents = [[NSMutableSet alloc] init];
		_documentsByName = [[NSMutableDictionary alloc] init];
		_customDocuments = [[NSMutableSet alloc] init];
		_customDocumentsByKey = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"%@{ %lu classes, %lu categories, %lu protocols, %lu frameworks }", [self className], [self.classes count], [self.categories count], [self.protocols count], [self.frameworks count]];
}

#pragma mark Helper methods

- (NSArray *)documentsSortedByName{
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"prettyNameOfDocument" ascending:YES]];
	return [[self.documents allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)classesSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"nameOfClass" ascending:YES]];
	return [[self.classes allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)categoriesSortedByName {
	NSSortDescriptor *classNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"nameOfClass" ascending:YES];
	NSSortDescriptor *categoryNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"categoryName" ascending:YES];
	NSArray *descriptors = [NSArray arrayWithObjects:classNameDescription, categoryNameDescription, nil];
	return [[self.categories allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)protocolsSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"protocolName" ascending:YES]];
	return [[self.protocols allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)frameworksSortedByName {
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"frameworkName" ascending:YES]];
    return [[self.frameworks allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSDictionary *)classesGroupedByFramework {
    NSMutableDictionary *frameworks = [NSMutableDictionary dictionaryWithCapacity:[self.frameworks count]];
    NSArray *allClasses = [self classesSortedByName];
    for(GBFrameworkData *framework in self.frameworks)
    {
        NSMutableArray *matched = [NSMutableArray arrayWithCapacity:allClasses.count];
        for(GBClassData *class in allClasses)
        {
            if([[(GBFrameworkData *)[class.frameworks.frameworks anyObject] nameOfFramework] isEqualToString:framework.nameOfFramework])
            {
                [matched addObject:class];
            }
        }
        [frameworks setObject:matched forKey:framework.nameOfFramework];
    }
    return frameworks;
}

- (NSDictionary *)categoriesGroupedByFramework {
    NSMutableDictionary *frameworks = [NSMutableDictionary dictionaryWithCapacity:[self.frameworks count]];
    NSArray *allCategories = [self categoriesSortedByName];
    for(GBFrameworkData *framework in self.frameworks)
    {
        NSMutableArray *matched = [NSMutableArray arrayWithCapacity:allCategories.count];
        for(GBCategoryData *category in allCategories)
        {
            if([[(GBFrameworkData *)[category.frameworks.frameworks anyObject] nameOfFramework] isEqualToString:framework.nameOfFramework])
            {
                [matched addObject:category];
            }
        }
        [frameworks setObject:matched forKey:framework.nameOfFramework];
    }
    return frameworks;
}

- (NSDictionary *)protocolsGroupedByFramework {
    NSMutableDictionary *frameworks = [NSMutableDictionary dictionaryWithCapacity:[self.frameworks count]];
    NSArray *allProtocols = [self protocolsSortedByName];
    for(GBFrameworkData *framework in self.frameworks)
    {
        NSMutableArray *matched = [NSMutableArray arrayWithCapacity:allProtocols.count];
        for(GBProtocolData *protocol in allProtocols)
        {
            if([[(GBFrameworkData *)[protocol.frameworks.frameworks anyObject] nameOfFramework] isEqualToString:framework.nameOfFramework])
            {
                [matched addObject:protocol];
            }
        }
        [frameworks setObject:matched forKey:framework.nameOfFramework];
    }
    return frameworks;
}

#pragma mark Registration handling

- (void)registerClass:(GBClassData *)class {
	NSParameterAssert(class != nil);
	GBLogDebug(@"%Registering class %@...", class);
	if ([_classes containsObject:class]) return;
	GBClassData *existingClass = [_classesByName objectForKey:class.nameOfClass];
	if (existingClass) {
		[existingClass mergeDataFromObject:class];
		return;
	}
	[_classes addObject:class];
	[_classesByName setObject:class forKey:class.nameOfClass];
}

- (void)registerCategory:(GBCategoryData *)category {
	NSParameterAssert(category != nil);
	GBLogDebug(@"Registering category %@...", category);
	if ([_categories containsObject:category]) return;
	NSString *categoryID = [NSString stringWithFormat:@"%@(%@)", category.nameOfClass, category.nameOfCategory ? category.nameOfCategory : @""];
	GBCategoryData *existingCategory = [_categoriesByName objectForKey:categoryID];
	if (existingCategory) {
		[existingCategory mergeDataFromObject:category];
		return;
	}
	[_categories addObject:category];
	[_categoriesByName setObject:category forKey:categoryID];
}

- (void)registerProtocol:(GBProtocolData *)protocol {
	NSParameterAssert(protocol != nil);
	GBLogDebug(@"Registering class %@...", protocol);
	if ([_protocols containsObject:protocol]) return;
	GBProtocolData *existingProtocol = [_protocolsByName objectForKey:protocol.nameOfProtocol];
	if (existingProtocol) {
		[existingProtocol mergeDataFromObject:protocol];
		return;
	}
	[_protocols addObject:protocol];
	[_protocolsByName setObject:protocol forKey:protocol.nameOfProtocol];
}

- (void)registerFramework:(GBFrameworkData *)framework {
    NSParameterAssert(framework != nil);
	GBLogDebug(@"Registering framework %@...", framework);
	if ([_frameworks containsObject:framework]) return;
	GBFrameworkData *existingFramework = [_frameworksByName objectForKey:framework.nameOfFramework];
	if (existingFramework) {
		[existingFramework mergeDataFromObject:framework];
		return;
	}
	[_frameworks addObject:framework];
	[_frameworksByName setObject:framework forKey:framework.nameOfFramework];
}

- (void)registerDocument:(GBDocumentData *)document {
	NSParameterAssert(document != nil);
	GBLogDebug(@"Registering document %@...", document);
	if ([_documents containsObject:document]) return;
	NSString *name = [document.nameOfDocument stringByDeletingPathExtension];
	GBDocumentData *existingDocument = [_documentsByName objectForKey:name];
	if (existingDocument) {
		[NSException raise:@"Document with name %@ is already registered!", name];
		return;
	}
	[_documents addObject:document];
	[_documentsByName setObject:document forKey:name];
	[_documentsByName setObject:document forKey:[name stringByReplacingOccurrencesOfString:@"-template" withString:@""]];
}

- (void)registerCustomDocument:(GBDocumentData *)document withKey:(id)key {
	NSParameterAssert(document != nil);
	GBLogDebug(@"Registering custom document %@...", document);
	[_customDocuments addObject:document];
	[_customDocumentsByKey setObject:document forKey:key];
}

- (void)unregisterTopLevelObject:(id)object {
	if ([_classes containsObject:object]) {
		[_classes removeObject:object];
		[_classesByName removeObjectForKey:[object nameOfClass]];
		return;
	}
	if ([_categories containsObject:object]) {
		[_categories removeObject:object];
		[_categoriesByName removeObjectForKey:[object idOfCategory]];
		return;
	}
	if ([_protocols containsObject:object]) {
		[_protocols removeObject:object];
		[_protocolsByName removeObjectForKey:[object nameOfProtocol]];
		return;
	}
    if ([_frameworks containsObject:object]) {
        [_frameworks removeObject:object];
        [_frameworksByName removeObjectForKey:[object nameOfFramework]];
    }
}

#pragma mark Data providing

- (GBClassData *)classWithName:(NSString *)name {
	return [_classesByName objectForKey:name];
}

- (GBCategoryData *)categoryWithName:(NSString *)name {
	return [_categoriesByName objectForKey:name];
}

- (GBProtocolData *)protocolWithName:(NSString *)name {
	return [_protocolsByName objectForKey:name];
}

- (GBFrameworkData *)frameworkWithName:(NSString *)name {
    return [_frameworksByName objectForKey:name];
}

- (GBDocumentData *)documentWithName:(NSString *)path {
	return [_documentsByName objectForKey:path];
}

- (GBDocumentData *)customDocumentWithKey:(id)key {
	return [_customDocumentsByKey objectForKey:key];
}

@synthesize classes = _classes;
@synthesize categories = _categories;
@synthesize protocols = _protocols;
@synthesize frameworks = _frameworks;
@synthesize documents = _documents;
@synthesize customDocuments = _customDocuments;

@end
