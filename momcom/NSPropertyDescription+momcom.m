//
//  NSPropertyDescription+momc.m
//  momc
//
//  Created by Tom Harrington on 4/18/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSPropertyDescription+momcom.h"

@implementation NSPropertyDescription (momcom)

+ (id)baseEntityForXML:(NSXMLElement *)xmlNode
{
    if ([self isMemberOfClass:[NSPropertyDescription class]]) {
        NSException *exception = [NSException exceptionWithName:NSGenericException reason:@"Can't create an NSPropertyDescription from an XML element, use an NSPropertyDescription subclass." userInfo:nil];
        [exception raise];
        return nil;
    }

    NSPropertyDescription *propertyDescription = [[self alloc] init];
	//If a property is marked as non-optional in the MOM, the XML will have no "optional"
	//attribute at all. NSPropertyDescription's default value is YES, but we want our default
	//value to be NO.
	propertyDescription.optional = NO;
    BOOL syncable = NO;

    for (NSXMLNode *xmlAttribute in [xmlNode attributes]) {
        NSString *attributeName = [xmlAttribute name];
        NSString *attributeString = [xmlAttribute stringValue];
        if ([attributeName isEqualToString:@"name"]) {
            [propertyDescription setName:attributeString];
        } else if ([attributeName isEqualToString:@"optional"]) {
            [propertyDescription setOptional:[attributeString isEqualToString:@"YES"]];
        } else if ([attributeName isEqualToString:@"transient"]) {
            [propertyDescription setTransient:[attributeString isEqualToString:@"YES"]];
        } else if ([attributeName isEqualToString:@"indexed"]) {
            [propertyDescription setIndexed:[attributeString isEqualToString:@"YES"]];
        } else if ([attributeName isEqualToString:@"syncable"]) {
            syncable = [attributeString isEqualToString:@"YES"];
        } else if ([attributeName isEqualToString:@"versionHashModifier"]) {
            [propertyDescription setVersionHashModifier:attributeString];
        } else if ([attributeName isEqualToString:@"renamingIdentifier"]) {
            [propertyDescription setRenamingIdentifier:attributeString];
        }
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

    // Need to add com.apple.syncservices.Syncable = NO to self's userInfo unless syncable=YES appears in XML attributes.
    if (!syncable) {
        [userInfo setObject:@"NO" forKey:@"com.apple.syncservices.Syncable"];
    }

    for (NSXMLElement *childNode in [xmlNode children]) {
        if ([[childNode name] isEqualToString:@"userInfo"]) {
            for (NSXMLElement *entryElement in [childNode children]) {
                NSXMLNode *keyAttribute = [entryElement attributeForName:@"key"];
                NSXMLNode *valueAttribute = [entryElement attributeForName:@"value"];
                [userInfo setObject:[valueAttribute stringValue] forKey:[keyAttribute stringValue]];
            }
        }
    }
    
    [propertyDescription setUserInfo:userInfo];
    
    return propertyDescription;
}

@end
