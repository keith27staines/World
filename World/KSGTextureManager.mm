//
//  KSGTextureManager.mm
//  World
//
//  Created by Keith Staines on 03/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGTextureManager.h"
#import "KSGTexture.h"

@implementation KSGTextureManager

////////////////////////////////////////////////////////////////////////////////
// resourceWithName
// Override
-(id)resourceWithName:(NSString*)aName
{
    // get the resource from the collection (if it exists)
    KSGManagedResourceBase* resource = [super resourceWithName:aName];
    
    if ( !resource ) 
    {
        // it doesn't exist so we must create it and add it to the collection
        
        // NOTE: that we explicitly construct the correctly typed subclass
        // of resource here...
        resource = [KSGTexture resourceWithName:aName];
        
        // add it to the collection (if a resource already exists, that will
        // be substituted)
        resource = [self addResource:resource];
    }
    return resource;
}

////////////////////////////////////////////////////////////////////////////////
// bindToGL
// binds all current textures to texture objects
-(void)sendToGL
{
    for ( NSString* key in resources) 
    {
        KSGTexture* texture = [resources objectForKey:key];
        [texture sendToGL];
    }
}

@end
