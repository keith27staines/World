//
//  KSCPrimitivePlane.h
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCPrimitive.h"
#import "KSMMaths.h"

@interface KSCPrimitivePlane : KSCPrimitive
{
    // points to the "allowed" side of the plane (strictly, a half-space)
    KSMVector3 _normalPC;
    KSMVector4 _pointInPlanePC;
}

// designated constructor. The point is a point is the position vector of
// a point in the plane relative to the parent (either _physicsBody, or if
// nil, then assumed to be the world. The plane's normal must also be
// specified as a vector expressed in the coordinate system of the parent.
-(id)initWithParentBody:(KSPPhysicsBody *)body 
         pointinPlanePC:(const KSMVector4 &)pointPC 
               normalPC:(const KSMVector3 &)normalPC;

// The plane's normal, pointing to the front (or allowed) side of the plane.
// If the plane has no associated physics body, then the normal is in world
// coordinates, otherwise on the model coordinates of the physics object
@property (assign) const KSMVector3 & normalPC;

// distance of the plane from the origin of its parent. Read only as this is
// derived from the position (which represents a point in the plane) and the
// plane's normal vector.
@property (readonly) double distanceFromParentOrigin;

// plane's normal in world coordinates
@property (readonly) KSMVector3 normalWC;


@end
