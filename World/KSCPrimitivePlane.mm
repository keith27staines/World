//
//  KSCPrimitivePlane.mm
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCPrimitivePlane.h"
#import "KSMMaths.h"

@implementation KSCPrimitivePlane

// override designated constructor
-(id)initWithParentBody:(KSPPhysicsBody *)body 
             positionPC:(const KSMVector4 &)positionPC
{
    // assume that the plane passes through the origin of the parent body
    return [self initWithParentBody:body 
                     pointinPlanePC:positionPC 
                           normalPC:KSMVector3()];
}

// new designated constructor
-(id)initWithParentBody:(KSPPhysicsBody *)body 
         pointinPlanePC:(const KSMVector4 &)pointPC 
               normalPC:(const KSMVector3 &)normalPC
{
    self = [super initWithParentBody:body positionPC:pointPC];
    
    // The default normal is vertically up, so that the plane represents
    // a horizontal plane with normal vector pointing up
    _normalPC = normalPC;
    
    // as we have no other information, assume that this plane passes through
    // the origin of the parent coordinate system
    _pointInPlanePC = pointPC;
    self.linearSize = DBL_MAX;
    return self;    
}

-(void)setNormalPC:(const KSMVector3 &)normal
{
    _normalPC = normal;
}

-(const KSMVector3&)normalPC
{
    return _normalPC;
}

-(KSMVector3)normalWC
{
    KSMMatrix3 rotation = [self primitiveToWorld].extract3x3();
    return rotation * _normalPC;
}

-(double)distanceFromParentOrigin
{    
    return _pointInPlanePC.vector3() * _normalPC;
}

@end
