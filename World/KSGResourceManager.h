//
//  KSGResourceManager.h
//  World
//
//  Created by Keith Staines on 04/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KSGManagedResourceBase;

@interface KSGResourceManager : NSObject
{
    KSGManagedResourceBase * defaultResource;
    NSMutableDictionary * resources;
}

@property (strong, readonly) NSMutableDictionary* resources;
@property (strong, readonly) KSGManagedResourceBase* defaultResource;

////////////////////////////////////////////////////////////////////////////////
// init
// The designated constructor
-(id)init;

////////////////////////////////////////////////////////////////////////////////
// resourceManager
// Returns an autoreleased resource manager
+(id)resourceManager;

////////////////////////////////////////////////////////////////////////////////
// resourceWithName
// Returns the resource with the specified name if it exists, nil otherwise
-(id)resourceWithName:(NSString*)name;

//////////////////////////////////////////////////////
// defaultResource
-(id)defaultResource;

////////////////////////////////////////////////////////////////////////////////
// addResource
// TODO: make PRIVATE. 
// Adds the specified resource to the collection (if a resource with the same 
// name doesn't already exist there). The returned object is the existing object
// ifthere is one, or the newly added resource if there wasn't.
-(KSGManagedResourceBase*)addResource:(KSGManagedResourceBase*)resource;

@end

