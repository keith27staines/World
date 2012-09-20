//
//  KSCOrientablePrimitive.mm
//  World
//
//  Created by Keith Staines on 20/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCOrientablePrimitive.h"
#import "KSPPhysicsBody.h"

@implementation KSCOrientablePrimitive


-(KSMVector4)positionWC
{
    // return the position of this primitive as defined in world coordinates
    return [self primitiveToWorld].extractPositionVector4();
}

-(void)setPrimitiveToParent:(const KSMMatrix4 &)matrix4
{
    _primitiveToParent = matrix4;
}

// returns the matrix that transforms a vector from primitive space to
// the space of its parent body.
-(const KSMMatrix4 &)primitiveToParent
{
    return _primitiveToParent;
}

// returns the matrix that transforms a vector from primitive space to
// world space. If this primitive is associated with a physics body, the 
// model to world transform of that body is used to pre-multiply the
// primitive to parent matrix, resulting in a primitive to world matrix.
-(const KSMMatrix4)primitiveToWorld
{
    // get the transform from model to world coordinates
    KSMMatrix4 primitiveToWorld;
    if (_physicsBody) 
    {
        // this primitive is associated with a game object and is offset relative
        // to it. 
        primitiveToWorld = _physicsBody.modelWorld * _primitiveToParent;
    }
    else
    {
        // as this primitive isn't associated with a gameobject then
        // it is defined in world coordinates already
        primitiveToWorld = _primitiveToParent;
    }    
    
    return primitiveToWorld;
}
@end
