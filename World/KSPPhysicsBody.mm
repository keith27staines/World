//
//  KSPPhysicsBody.mm
//  World
//
//  Created by Keith Staines on 05/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPPhysicsBody.h"
#import "KSCPrimitive.h"

@implementation KSPPhysicsBody
@synthesize primitiveAssembly;
@synthesize recentMotion = _recentMotion;
@synthesize canSleep     = _canSleep;

-(id)init
{
    return [self initWithMass:1.0
              momentOfInertia:KSMMatrix3()
               linearVelocity:KSMVector3()
              angularVelocity:KSMVector3()
                 modelToWorld:KSMMatrix4()
            primitiveAssembly:nil
                     canSleep:YES
                      isAwake:NO
                effectiveArea:1.0
              effectiveRadius:1.0];
}

-(id)initWithMass:(double)mass
  momentOfInertia:(const KSMMatrix3&)momentOfInertia
   linearVelocity:(const KSMVector3&)linearVelocity
  angularVelocity:(const KSMVector3&)angularVelocity
     modelToWorld:(const KSMMatrix4&)modelWorld
primitiveAssembly:(NSArray*)primitives
         canSleep:(BOOL)canSleep
          isAwake:(BOOL)isAwake
    effectiveArea:(double)effectiveArea
  effectiveRadius:(double)radius
{
    self = [super init];
    [self setMass:mass];
    [self setMI:momentOfInertia];
    [self setLinearVelocity:linearVelocity];
    [self setAngularVelocity:angularVelocity];
    [self setModelWorld:modelWorld];
    [self setPrimitiveAssembly:primitives];
    [self setCanSleep:canSleep];
    [self setIsAwake:isAwake];
    [self setEffectiveAreaForDrag:effectiveArea];
    [self setCharacteristicLinearDimension:radius];
    _force               = KSMVector3();
    _torque              = KSMVector3();
    _linearAcceleration  = KSMVector3();
    _angularAcceleration = KSMVector3();
    _recentMotion        = 0;
    return self;
}

-(double)effectiveAreaForDrag
{
    return _effectiveAreaForDrag;
}

-(void)setEffectiveAreaForDrag:(double)effectiveAreaForDrag
{
    if (_effectiveAreaForDrag == 0) 
    {
        KSCPrimitive * primitive = [primitiveAssembly objectAtIndex:0];
        if (primitive) 
        {
            double size = [primitive linearSize];
            effectiveAreaForDrag = PI * size * size;
        }
    }
    _effectiveAreaForDrag = effectiveAreaForDrag;
}

-(void)setCharacteristicLinearDimension:(double)characteristicLinearDimension
{
    if (characteristicLinearDimension == 0) 
    {
        KSCPrimitive * primitive = [primitiveAssembly objectAtIndex:0];
        if (primitive) 
        {
            double size = [primitive linearSize];
            characteristicLinearDimension = size;
        }
    }
    _characteristicLinearDimension = characteristicLinearDimension;
}

-(double)characteristicLinearDimension
{
    return _characteristicLinearDimension;
}

-(void)setModelWorld:(const KSMMatrix4 &)modelWorld
{
    _modelWorld = modelWorld;
}

-(const KSMMatrix4&)modelWorld
{
    return _modelWorld;
}

-(void)setLinearVelocity:(const KSMVector3 &)linearVelocity
{
    _linearVelocity = linearVelocity;
}

-(const KSMVector3 &)linearVelocity
{
    return _linearVelocity;
}

-(void)setAngularVelocity:(const KSMVector3 &)angularVelocity
{
    _angularVelocity = angularVelocity;
}

-(const KSMVector3 &)angularVelocity
{
    return _angularVelocity;
}

-(void)setLinearAcceleration:(const KSMVector3 &)linearAcceleration
{
    _linearAcceleration = linearAcceleration;
}

-(const KSMVector3 &)linearAcceleration
{
    return _linearAcceleration;
}

-(void)setAngularAcceleration:(const KSMVector3 &)angularAcceleration
{
    _angularAcceleration = angularAcceleration;
}

-(const KSMVector3 &)angularAcceleration
{
    return _angularAcceleration;
}

-(double)mass
{
    return _mass;
}

-(double)inverseMass
{
    return _inverseMass;
}

-(void)setMass:(double)mass
{
    _mass = mass;
    _inverseMass = 1.0 / mass;
}

-(const KSMMatrix3&)mI
{
    return _mI;
}

-(const KSMMatrix3&)inverseMI
{
    return _inverseMI;
}

-(void)setMI:(const KSMMatrix3 &)momentOfInertia
{
    _mI = momentOfInertia;
    _inverseMI = momentOfInertia.inverse();
}

-(void)setIsAwake:(BOOL)isAwake
{
    if (isAwake) 
    {
        _isAwake = YES;
        _recentMotion = 10.0 * SLEEPEPSILON;
        return;
    }
    
    if ( _canSleep ) 
    {
        _isAwake = NO;
        _linearVelocity.zero();
        _linearAcceleration.zero();
        _angularVelocity.zero();
        _angularAcceleration.zero();
        [self resetForceAccumulators];
    }
}
-(BOOL)isAwake
{
    return _isAwake;
}

-(void)resetForceAccumulators
{
    _force.zero();
    _torque.zero();
}

-(double)currentMotion
{
    return _linearVelocity.length2() + _angularVelocity.length2()
               * _characteristicLinearDimension / ROOT2;
}

-(double)updateMotionOverInterval:(double)dt
{
    double currentMotion = [self currentMotion];

    // don't use very high values for the recency weighted average because they 
    // take too long to slow down.
    if (currentMotion < 5.0 * SLEEPEPSILON) 
    {
        _recentMotion = (1.0 - RECENCYBIAS) * currentMotion + 
                                RECENCYBIAS * _recentMotion;
    }    
        
    return _recentMotion;
}

-(void)sleepIfAllowed:(double)dt
{
    // if the body isn't moving more than a certain threshold, put it in the
    // sleep state so that further needless integrations are not performed
    if (_canSleep) 
    {
        [self updateMotionOverInterval:dt];
        if ([self recentMotion] < SLEEPEPSILON) 
        {
            // Enter the sleep state. This will zero all velocity and acceleration 
            // vectors (linear and rotational).
            [self setIsAwake:NO];
        }
    }    
}

-(void)integrateOverInterval:(NSTimeInterval)dt
{

    // if this body is asleep it won't respond to forces
    if (!_isAwake) return;
    
    // Test to see if we have infinite mass. If so, we are unresponsive to
    // both forces and torques, and so we can return immediately
    if ( _mass == DBL_MAX ) return; 

    // Verlet velocity integration scheme
    
    // calculate the linear motion
    KSMVector3 newAcceleration = _inverseMass * _force;
    _linearVelocity += 0.5 * dt * (_linearAcceleration + newAcceleration);
    KSMVector3 translation = dt * _linearVelocity + (0.5 * dt * dt) * newAcceleration;
    _modelWorld.translate(translation);  
    _linearAcceleration = newAcceleration;
    
    // similar procedure for angular motion
    KSMVector3 newAngularAcceleration = _inverseMI * _torque;
    _angularVelocity += 0.5 * dt * (_angularAcceleration +  
                                                        newAngularAcceleration);
    KSMVector3 tw = dt * _angularVelocity + (0.5 * dt * dt) * newAngularAcceleration;
    double angle = tw.length();
    _modelWorld.rotateAboutAxis(angle, tw);
    _angularAcceleration = newAngularAcceleration;
    
    // Put this body to sleep if it hasn't moved a significant amount
    [self sleepIfAllowed:dt];    
}

- (void)addForceThroughCM:(const KSMVector3 &)force
{
    // the force is applied directly to the centre of mass and therefore
    // induces no rotation.
    _force += force;
    [self addForceThroughCMWithoutWaking:force];
    [self setIsAwake:YES];
}

- (void)addForceThroughCMWithoutWaking:(const KSMVector3 &)force
{
    // the force is applied directly to the centre of mass and therefore
    // induces no rotation.
    _force += force;
}

- (void)addForce:(const KSMVector3&)force 
  atBodyPosition:(const KSMVector3&)bodyPosition
{    
    // calculate the position of application of the force in world coordinates
    KSMVector4 worldPosition4 = _modelWorld * bodyPosition.vector4Position();
    
    // delegate the real work to another method
    [self addForce:force atWorldPosition:worldPosition4.vector3()];
}

- (void)addForce:(const KSMVector3&)force 
 atWorldPosition:(const KSMVector3&)worldPosition
{
    // translational aspect of force is straightforward
    [self addForceThroughCM:force];
    
    // For rotational, we first find the position of the body's centre of mass
    // in world coordinates
    KSMVector3 worldPositionCM = _modelWorld.extractPositionVector();
    
    // now calculate the relative position of the point of application of the 
    // force with respect to the centre of mass
    KSMVector3 relativePosition = worldPosition - worldPositionCM;
    
    // now we can get the torque
    _torque += relativePosition % force;
}

-(KSMVector4)bodyPositionInWorldCoordinates:(const KSMVector4&)bodyPositionMC;
{
    return _modelWorld * bodyPositionMC;
}

-(KSMVector3)bodyDirectionInWorldCoordinates:(const KSMVector3 &)bodyDirection
{
    KSMMatrix3 rotModelToWorld = _modelWorld.extract3x3();
    return rotModelToWorld * bodyDirection;
}

-(KSMVector3)velocityWCOfBodyPositionMC:(const KSMVector4&)bodyPositionMC
{
    // vector from CM to the specified point in world coordinates is
    KSMVector3 rWC = ( _modelWorld.extract3x3() ) * bodyPositionMC.vector3();
    
    // velocity due to body rotation in world coordinates is
    KSMVector3 vRotWC = _angularVelocity % rWC;
    
    // add on the translational velocity to get the full velocity
    return (vRotWC + _linearVelocity);
    
}

-(KSMVector3)velocityWCOfBodyPositionWC:(const KSMVector4&)bodyPositionWC
{
    // vector from CM to point in world coordinates is
    KSMVector3 rWC = [self positionRelativeToCentreOfMass:bodyPositionWC];
    
    // velocity due to body rotation in world coordinates is
    KSMVector3 vRotWC = _angularVelocity % rWC;
    
    // add on the translational velocity to get the full velocity
    return (vRotWC + _linearVelocity);
    
}

-(KSMVector3)positionRelativeToCentreOfMass:(const KSMVector4&)positionWC
{
    // position vector of body CM in world space is    
    KSMVector4 centreOfMassWC = _modelWorld.extractPositionVector4();
    
    // vector from CM to point in world coordinates is
    KSMVector3 relativePosition = (positionWC - centreOfMassWC).vector3();
    
    return relativePosition;
}

-(void)setPosition:(const KSMVector3 &)position
{
    _modelWorld.setPosition(position);
}

-(KSMVector3)position
{
    return _modelWorld.extractPositionVector();
}


@end
