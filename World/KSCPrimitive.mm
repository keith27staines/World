//
//  KSCPrimitive.mm
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCPrimitive.h"
#import "KSPPhysicsBody.h"

@implementation KSCPrimitive

@synthesize physicsBody = _physicsBody;
@synthesize linearSize;

// override designated constructor of super
-(id)init
{
    return [self initWithParentBody:nil positionPC:KSMVector4()];
}

// designated constructor
-(id)initWithParentBody:(KSPPhysicsBody*)body 
             positionPC:(const KSMVector4&)positionPC
{
    self = [super init];
    _physicsBody = body;
    _positionPC = positionPC;
    return self;
}

-(KSMVector4)positionWC
{
    // return the position of the origin of this primitive,
    // as defined in world coordinates
    return [self primitiveToWorld] * _positionPC;
}


// returns the matrix that transforms a vector from primitive space to
// world space. If this primitive is associated with a physics body, the 
// model to world transform of that body is returned, otherwise the unit matrix.
-(const KSMMatrix4)primitiveToWorld
{
    // get the transform from model to world coordinates
    KSMMatrix4 primitiveToWorld;
    if (_physicsBody) 
    {
        // this primitive is associated with a physics body. 
        primitiveToWorld = _physicsBody.modelWorld;
    }
    else
    {
        // as this primitive isn't associated with a gameobject then
        // it is defined in world coordinates already
        primitiveToWorld = KSMMatrix4();
    }    
    
    return primitiveToWorld;
}

@end
