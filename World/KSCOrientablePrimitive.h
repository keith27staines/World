//
//  KSCOrientablePrimitive.h
//  World
//
//  Created by Keith Staines on 20/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSCPrimitive.h"

@interface KSCOrientablePrimitive : KSCPrimitive
{
    // offset from the coordinate origin of the parent to the coordinate
    // origin of this primitive.
    KSMMatrix4 _primitiveToParent;
    
}

@property (assign) const KSMMatrix4 & primitiveToParent;

@end
