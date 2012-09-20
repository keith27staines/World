//
//  KSGMaterialManager.mm
//  World
//
//  Created by Keith Staines on 02/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGMaterialManager.h"
#import "KSGMaterial.h"

@implementation KSGMaterialManager

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
        resource = [KSGMaterial resourceWithName:aName];
        
        // add it to the collection (if a resource already exists, that will
        // be substituted)
        resource = [self addResource:resource];
    }
    return resource;
}

@end
