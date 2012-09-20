//
//  KSGResourcelManager.mm
//  World
//
//  Created by Keith Staines on 02/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGResourceManager.h"
#import "KSGManagedResourceBase.h"

NSString* makeName();
NSString* makeName()
{
    static int i;
    return [NSString stringWithFormat:@"KSGMaterial%06i",i++];
}

@implementation KSGResourceManager
@synthesize resources;
@synthesize defaultResource;

-(id)init
{
    self = [super init];
    if (self) 
    {
        defaultResource = nil;
        
        // Initialization code here.
        resources = [NSMutableDictionary dictionaryWithCapacity:1024];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// resourceManager
// returns a resource manager
+(id)resourceManager
{
    return [[self alloc] init];
}

////////////////////////////////////////////////////////////////////////////////
// resourceWithName
// returns the resource with the specified name if it exists, nil otherwise
-(id)resourceWithName:(NSString*)aName
{
    // make sure we have a valid name. If we don't, we use
    // the default
    if (!aName) 
    {
        // have to cast away constantness
        return defaultResource;
    }
    
    return [resources objectForKey:aName];
    
}

////////////////////////////////////////////////////////////////////////////////
// addResource
// Adds the specified resource to the collection (if a resource with the same 
// name doesn't already exist there). The returned object is the existing object
// if there is one, or the newly added resource if there wasn't.
-(KSGManagedResourceBase*)addResource:(KSGManagedResourceBase*)resource
{
    // We don't want to be adding a nil object. The collection must only contain
    // valid objects
    NSAssert(resource, @"Attempting to add a nil resource.");
    
    // make sure the key is ok too
    NSString* key = [resource name];
    NSAssert(key, @"Attempting to add a resource with a nil name.");
    
    // does an object with this name already exist in the collection? 
    KSGManagedResourceBase* existingResource = [resources objectForKey:key];
    if (!existingResource) 
    {
        // no, so add it
        if ([resources count] == 0) defaultResource = resource;
        [resources setObject:resource  forKey:[resource name]];
        existingResource = resource;
        
    }
    
    return existingResource;
}

@end
