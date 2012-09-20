//
//  KSESolarSystemBody.mm
//  World
//
//  Created by Keith Staines on 04/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSESolarSystemBody.h"
#import "KSPMomentsOfInertia.h"
@implementation KSESolarSystemBody

@synthesize name = _name;
@synthesize type = _type;
@synthesize nameOfParent = _nameOfParent;
@synthesize texture0name = _texture0Name;
@synthesize mass = _mass;
@synthesize radius = _radius;



-(id)init
{
    NSAssert(NO,@"use the designated constructor");
    return nil;
}

-(id)initWithName:(NSString*)name 
             type:(NSString*)type 
     nameOfParent:(NSString*)nameOfParent 
             mass:(double)mass 
           radius:(double)radius
 relativePosition:(const KSMVector3&)relativePosition
 relativeVelocity:(const KSMVector3&)relativeVelocity
  angularVelocity:(const KSMVector3&)angularVelocity
{
    self = [super init];
    _name = name;
    _type = type;
    _nameOfParent = nameOfParent;
    _mass = mass;
    _radius = radius;
    _momentOfInertia = [KSPMomentsOfInertia sphereOfMass:mass radius:radius];
    _relativePosition = relativePosition;
    _relativeVelocity = relativeVelocity;
    _angularVelocity = angularVelocity;
    return self;
}


-(void)setMomentOfInertia:(const KSMMatrix3 &)momentOfInertia
{
    _momentOfInertia = momentOfInertia;
}

-(const KSMMatrix3 &)momentOfInertia
{
    return _momentOfInertia;
}

-(void)setRelativePosition:(const KSMVector3 &)relativePosition
{
    _relativePosition = relativePosition;
}

-(const KSMVector3 &)relativePosition
{
    return _relativePosition;
}

-(void)setRelativeVelocity:(const KSMVector3 &)relativeVelocity
{
    _relativeVelocity = relativeVelocity;
}

-(const KSMVector3 &)relativeVelocity
{
    return _relativeVelocity;
}

-(void)setAngularVelocity:(const KSMVector3 &)angularVelocity
{
    _angularVelocity = angularVelocity;
}

-(const KSMVector3 &)angularVelocity
{
    return _angularVelocity;
}

@end
