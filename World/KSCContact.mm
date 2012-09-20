//
//  KSCContact.mm
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCContact.h"
#import "KSGGraphics.h"
#import "KSPPhysics.h"


KSMVector3 invRotInertia(KSMMatrix3 invMI, 
                         KSMVector3& relativePosition, 
                         KSMVector3& direction) 
{
    return  (invMI * (relativePosition % direction) )  % relativePosition;
}


KSMMatrix3 rCrossProduct(KSMVector3 & pointOfAction)
{
    KSMMatrix3 skew = KSMMatrix3();
    skew.d[0] = 0;
    skew.d[1] =  pointOfAction.z;
    skew.d[2] = -pointOfAction.y;
    skew.d[3] = -pointOfAction.z;
    skew.d[4] = 0;
    skew.d[5] =  pointOfAction.x;
    skew.d[6] =  pointOfAction.y;
    skew.d[7] = -pointOfAction.x;
    skew.d[8] = 0;
    return skew;
}

@implementation KSCContact

@synthesize depth = _depth;
@synthesize restitution  = _restitution;
@synthesize friction     = _friction;
@synthesize closingSpeed = _closingSpeed;

-(id)initWithBodyA:(KSPPhysicsBody*)bodyA 
             bodyB:(KSPPhysicsBody*)bodyB 
 contactPositionWC:(const KSMVector4&)position 
   contactNormalWC:(const KSMVector3&)normal 
  penetrationDepth:(double)depth 
       restitution:(double)restitution
          friction:(double)friction
{
    self = [super init];
    
    [self setBodyA:bodyA];
    [self setBodyB:bodyB];;
    [self setContactPointWC:position];
    [self setContactNormalWC:normal];
    [self setRestitution:restitution];
    [self setFriction:friction];
    _depth          = depth;
    _worldToContact = KSMMatrix3();
    _contactToWorld = KSMMatrix3();
    return self;   
}

// override designated constructor of super
-(id)init
{
    return [self initWithBodyA:nil 
                         bodyB:nil
             contactPositionWC:KSMVector4() 
               contactNormalWC:KSMVector3()
              penetrationDepth:0 
                   restitution:0.6
                      friction:0.1];
}

-(void)setBodyA:(KSPPhysicsBody *)bodyA
{
    _bodyA = bodyA;
    if ( bodyA == nil ) 
    {
        _massA    = DBL_MAX;  // signals that this "body" is not to be moved
        _invMassA = 0.0;
        _invMIA   = 0 * KSMMatrix3();
    }
    else
    {
        _massA    = bodyA.mass;
        _invMassA = bodyA.inverseMass;
        _invMIA   = bodyA.inverseMI;
    }    
}

-(KSPPhysicsBody*)bodyA
{
    return _bodyA;
}

-(KSPPhysicsBody*)bodyB
{
    return _bodyB;
}

-(void)setBodyB:(KSPPhysicsBody *)bodyB
{
    _bodyB = bodyB;
    if ( bodyB == nil ) 
    {
        _massB    = DBL_MAX; // signals that this "body" is not to be moved
        _invMassB = 0.0;
        _invMIB   = 0 * KSMMatrix3();
    }
    else
    {
        _massB    = bodyB.mass;
        _invMassB = bodyB.inverseMass;
        _invMIB   = bodyB.inverseMI;
    }
}

-(void)setContactNormalWC:(const KSMVector3 &)normal
{
    _contactNormalWC = normal;
}

-(const KSMVector3 &)contactNormalWC
{
    return _contactNormalWC;
}

-(void)setContactPointWC:(const KSMVector4 &)position
{
    _contactPointWC = position;
}

-(const KSMVector4 &)contactPointWC
{
    return _contactPointWC;
}

-(const KSMMatrix3&)contactToWorld
{
    return _contactToWorld;
}

-(const KSMMatrix3&)worldToContact
{
    return _worldToContact;
}

-(KSMVector3)translationA
{
    return _dxLinearA * _contactNormalWC;
}

-(KSMVector3)translationB
{
    return - _dxLinearB * _contactNormalWC;
}

-(KSMVector3)rotationA
{
    return _angleA * _axisA.unitVector();
}

-(KSMVector3)rotationB
{
    return _angleB * _axisB.unitVector();
}

-(KSMVector3)bodyAToContactWC
{
    return _aTocWC;
}

-(KSMVector3)bodyBToContactWC
{
    return _bTocWC;
}

-(void)matchAwakeState
{
    // if either of the two bodies are awake, then make sure the other is too.
    
    // collisions with a non moving body will not wake the body up
    if (_massB < DBL_MAX) 
    {
        BOOL bodyAIsAwake = [_bodyA isAwake];
        BOOL bodyBIsAwake = [_bodyB isAwake];
        if (bodyAIsAwake) 
        {
            if ( !bodyBIsAwake ) 
            {
                // body A is awake but B isn't, so we wake it up
                [_bodyB setIsAwake:YES];
                return;
            }
            return;
        }

        if (bodyBIsAwake) 
        {
            // body B is awake but A isn't, so we wake it up.
            if ( !bodyAIsAwake ) 
            {
                [_bodyA setIsAwake:YES];
                return;
            }
            return;
        }
    }
}

-(void)calculateContactToWorld
{
    /*
     We will regard the contactNormal to be the image of a unit vector in the
     world X direction, tangent1 to be the image of the Y axis, and tangent2
     to be the image of the world Z axis.
     */

    
    // Begin constructing tangent1. We need a first approximation that at least 
    // has a non-zero component perpendicular to the contact normal. We will 
    // refine the approximation later.
    if ( fabs(_contactNormalWC.x) > fabs(_contactNormalWC.y) ) 
    {
        // the world y direction is not the major component of contactNormal
        // and so must have a significant component perpendicular to 
        // contactNormal, so we use the world y axis as our first approximation 
        // for tangent1
        _tangent1 = KSMVector3(0, 1, 0);
    }
    else // contactNormal.x <= contactNormal.y
    {
        // the world x direction is not the major component of contactNormal
        // and so must have a significant component perpendicular to 
        // contactNormal, so we use the world x axis as our first approximation 
        // for tangent1
        _tangent1 = KSMVector3(1, 0, 0);
    }

    // tangent1 has a significant component perpendicular to contactNormal.
    // We make it exactly perpendicular by subtracting off its parallel
    // component, the magntidue of which is given by the dot product
    _tangent1 -= (_contactNormalWC * _tangent1) * _contactNormalWC;
    
    // tangent 1 is now perpendicular to the contact normal but is unlikely to
    // be of unit length, so we normalise it
    _tangent1.normalise();

    // we can construct tangent2 from the cross product, so forming a right-hand
    // set comprised of contactNormal, tangent1 and tangent2
    _tangent2 = _contactNormalWC % _tangent1;
    
    // Taking contactNormal to be "x", tangent1 to be "y", and tangent2 to be
    // "z", we now have a right hand set of orthonormal axis vectors.
    
    // We construct the rotation matrix from these vectors. Note that the columns
    // of a rotation matrix are the images of x,y, and z vectors under the 
    // transformation, i.e., the contactNormal and two tangents we have just
    // calculated.
    _contactToWorld.setColumnsFromVectors(_contactNormalWC, 
                                          _tangent1, 
                                          _tangent2);
    
    // Thus contactToWorld rotates the vector (1,0,0)T to contact normal, the 
    // vector (0,1,0)T to tangent1, and (0,0,1)T to tangent2.
    
    // and the transform from world coordinates to contact coordinates is just
    // the inverse (as we are dealing with rotations, the inverse is just the
    // transpose.
    _worldToContact = _contactToWorld;
    _worldToContact.transpose();
}

// reduce the effective restitution for very low speed impacts
-(double)effectiveRestition:(double)approachSpeed
{
    double rEffective = _restitution * approachSpeed / LOWSPEEDLIMIT;
    rEffective = (rEffective < _restitution) ? rEffective : _restitution;
    return rEffective;
}

-(double)calculateDeltaNormalSpeedDueToBounce:(double)dt
{
    // calculate the change in speed along the contact normal. This is 
    // effectively the change in speed of A relative to B along the contact
    // normal.
    KSPPhysicsBody * body[] = {_bodyA, _bodyB};
    KSMVector3 contactNormalWC[] = {_contactNormalWC, -1 * _contactNormalWC};
    
    // speed to contactNormal aligned acceleration over the frame
    double adt = 0;
    
    // acceleration along the body's individual contact normal
    double a;
    
    for (int i = 0; i < 2; i++) 
    {
        if (body[i]) 
        {
            a = body[i].linearAcceleration * contactNormalWC[i];
            if ( a < 0 ) 
            {
                // This body is accelerating towards the contact point but
                // the part of the body's velocity caused by acceleration
                // over the last frame would in reality be cancelled by reaction
                // forces from the contact and so we will subtract it.
                
                // speed towards contact point to acceleration over last time 
                // frame is adt = acc * dt
                adt += dt * a;
            }
        } // if (body[i]) 
    } // for (int i; i < 2; i++) 
    
    // The speed of approach ignoring speed built up from normal-aligned 
    // acceleration over the last frame (which will be negative) is therefore...
    double approachSpeed = _closingSpeed + adt;
    
    // the separation speed is obtained using Newton's law of restitution, but 
    // the coefficient of restitution we use is modified (increased) at low 
    // approach speeds to prevent microscopic bounces
    double e = [self effectiveRestition:approachSpeed];
    double separationSpeed = e * approachSpeed;
    
    // the total change in speed (which must halt the speed built up from
    // acceleration over the last frame is therefore...
    return _closingSpeed + separationSpeed;
}

/*
 The approach velocity is defined as the velocity of A relative to B
 expressed in contact coordinates. As the x component of contact space
 is the direction of the contact normal (which points from B to A), the
 x component of the approach velocity can be used to test whether the bodies
 are approaching each other (as would be the case if the x component of the 
 velocity was -ve) or receding (+ve).
 */
-(void)calculateApproachVelocity
{
    // begin the calculation of the velocity of A relative to B
    // working in world coordinates for now (we'll change to contact
    // coordinates later).
    _approachVelocityCC = [_bodyA velocityWCOfBodyPositionWC:_contactPointWC];

    if (_massB < DBL_MAX) 
    {
        _approachVelocityCC -= [_bodyB velocityWCOfBodyPositionWC:_contactPointWC];
    }
    
    // change to contact coordinates
    _approachVelocityCC = _worldToContact * _approachVelocityCC;
    
    // keep a record of the closing speed. Note that the approach velocity
    // is the velocity of A relative to B, and therefore if the bodies are
    // approaching each other, the x component (i.e, the contactNormal) component
    // of the approach velocity will be negative. We track this separately with
    // _closingSpeed, which is defined to be the positive if the bodies are 
    // approaching, and so we reverse the sign.
    _closingSpeed = - _approachVelocityCC.x;
}

-(void)calculateContactPositionVectors
{
    // calculate vector from the centre of mass of A to the contact point.
    _aTocWC = [_bodyA positionRelativeToCentreOfMass:_contactPointWC];
    
    if (_massB < DBL_MAX) 
    {
        _bTocWC = [_bodyB positionRelativeToCentreOfMass:_contactPointWC];
    }
}


-(void)calculateInternals:(double)dt
{
    // calculate the contact to world transform and the basis vectors
    // for the contact coordinate system
    [self calculateContactToWorld];
    
    // calculate position vectors of contact point relative to A and B
    [self calculateContactPositionVectors];
    
    // calculate the combined velocity of approach to the contact point
    [self calculateApproachVelocity];
}

-(void)adjustBodyPositions:(double)dt
{ 
    // define the contact normals for A and B in world coordinates
    KSMVector3 normalAWC = _contactNormalWC;
    KSMVector3 normalBWC = -1 * normalAWC;
    
    // calculate the "rotational inertia" of both bodies for an impulse at
    // the contact point acting along the contact normal
    double invRotInertiaA = normalAWC * invRotInertia(_invMIA, _aTocWC, normalAWC);
    double invRotInertiaB = normalBWC * invRotInertia(_invMIB, _bTocWC, normalBWC);

    double totalInvInertiaA = _invMassA + invRotInertiaA;
    double totalInvInertiaB = _invMassB + invRotInertiaB;
    double totalInvInertia  = totalInvInertiaA + totalInvInertiaB;
    
    // calculate and apply the linear movement to bodyA
    _dxLinearA   = + _depth * _invMassA / totalInvInertia;
    _dxLinearB   = 0;
    KSMVector3 newPositionA = KSMVector3(_dxLinearA, 0, 0); 
    newPositionA = [_bodyA position] + _contactToWorld * newPositionA;
    [_bodyA setPosition:newPositionA];
    
    // calculate and apply rotational movement to A
    double dxRotationA = _depth * invRotInertiaA / totalInvInertia;
    double dxRotationB = 0;
    _angleA = dxRotationA * _aTocWC.length() / 
                            ( ( (_aTocWC % normalAWC) % _aTocWC ) * normalAWC );
    _axisA = _aTocWC % normalAWC;
    KSMMatrix4 modelWorldA = [_bodyA modelWorld];
    modelWorldA.rotateAboutAxis(_angleA, _axisA);
    [_bodyA setModelWorld:modelWorldA];
    
    // follow similar procedure for body B if it is movable
    if ( _massB < DBL_MAX ) 
    {
        // Repeat for B (the sign of depth reverses because it implicitly
        // depends on the contact normal, which is reversed for B
        _dxLinearB = - _depth * _invMassB / totalInvInertia;
        KSMVector3 newPositionB = KSMVector3(_dxLinearB, 0, 0); 
        newPositionB = [_bodyB position] + _contactToWorld * newPositionB;    
        [_bodyB setPosition:newPositionB];
        
        // Rotation using same procedure as for body A
        dxRotationB = _depth * invRotInertiaB / totalInvInertia;
        _angleB = dxRotationB * _bTocWC.length() / 
                            ( ( (_bTocWC % normalBWC) % _bTocWC ) * normalBWC );
        _axisB = _bTocWC % normalBWC;
        KSMMatrix4 modelWorldB = [_bodyB modelWorld];
        modelWorldB.rotateAboutAxis(_angleB, _axisB);
        [_bodyB setModelWorld:modelWorldB];
    }    
    
    // and making these movements will have modified the depth of this contact
    _depth -= _dxLinearA + dxRotationA - _dxLinearB - dxRotationB; // == 0 ???
}

-(void)adjustBodyVelocities:(double)dt
{
    // test to see if the bodies are currently moving towards each other
    if ( _closingSpeed < LOWSPEEDLIMIT ) 
    {
        // bodies are either moving apart or are moving towards each other so 
        // slowly that there is no need to change their velocities
        return;
    }
    
    [self calculateInternals:dt];
    
    // keep track of the total moveable mass involved in the collision
    double invMass = _invMassA;
    
    // The function "rCrossProduct(vector)" returns the matrix that has the same
    // effect as using its vector argument as the first vector in a vector cross
    // product calculation (i.e, rCross(u) * v = u ^ v for any vectors u and v. 
    KSMMatrix3 rCross = rCrossProduct(_aTocWC);
    
    // Now consider the action of some unknown force, F (in world coordinates)
    // applied at the contact point. As Torque = r ^ F, we can write the matrix 
    // that converts the force into a torque simply as...
    KSMMatrix3 torqueWCFromForceWC = rCross;
    
    // Now consider Newton's law for rotation... 
    // I * angular acceleration = torque
    // Multiply both sides by the time, dt, that the force acts for, giving...
    // I * delta angular velocity = dt * torque. 
    // (NB From now on, the torque and force referred to in the variable names 
    // in the code are actually the impulsive torque and force, but the 
    // impulsive bit is omitted because the variable names become inconveniently 
    // long.)
    // Then, multiply both sides from the left by invI gives...
    KSMMatrix3 deltaAngVelWCFromForceWC = _invMIA * torqueWCFromForceWC;
    
    // Now we can calculate the change in linear velocity at the contact point 
    // that this change in angular velocity will cause. The equation is
    // delta linear velocity = delta angular velocity ^ r. We will use rCross to
    // do the vector product, but rCross represents r ^, so we have to reverse 
    // the sign.
    KSMMatrix3 deltaVelocityWCFromForceWC = -1 * rCross * deltaAngVelWCFromForceWC;
    
    // So far we have just considered body A but B might move too
    if ( _massB < DBL_MAX ) 
    {
        // Body B can move, so we take account of that too. The procedure is
        // similar but by Newton's law of equal and opposite reaction, the
        // sign of the impulsive force is reversed. We accomodate this by 
        // switching the sign in the last step (legitimate as u ^ v = - v ^ u)
        invMass += _invMassB;
        rCross = rCrossProduct(_bTocWC);
        torqueWCFromForceWC = rCross;
        deltaAngVelWCFromForceWC = _invMIB * torqueWCFromForceWC;
        
        // convert to linear velocity and add to the sum already containing
        // the change in linear velocity of A at the contact point. Note the
        // plus sign.
        deltaVelocityWCFromForceWC = deltaVelocityWCFromForceWC + 
                                     rCross * deltaAngVelWCFromForceWC;
    }
    
    // The change in  velocity matrix now includes both bodies but it operates 
    // on an impulse (force * dt) in world coordinates and outputs a vector in 
    // world coordinates. What we really need is the matrix that does the same 
    // job but which operates on an impulse in contact coordinates, with its 
    // output also in contact coordinates. We therefore change the basis of the
    // matrix in the standard way...
    KSMMatrix3 deltaVelocityCCFromForceCC;
    deltaVelocityCCFromForceCC = _worldToContact * deltaVelocityWCFromForceWC * 
                                                                _contactToWorld;
    
    // So far we have considered the change in linear velocity at the contact 
    // point caused by a change in the angular velocity about the centre of mass.
    // We must now add the effect of the force on the linear velocity of the
    // centre of mass. We can do this very simply by adding the matrix 
    // invMass * UnitMatrix (note that invMass takes into account the masses
    // of both bodies).
    deltaVelocityCCFromForceCC = deltaVelocityCCFromForceCC + 
                                                         invMass * KSMMatrix3();
    
    // But what we really need is the matrix that will output the impulse 
    // (in contact coordinates) that is required to produce an input delta 
    // velocity at the contact point (also in contact coordinates). This matrix 
    // is just the inverse of the matrix calculated above.
    KSMMatrix3 impulseCCFromDeltaVelCC = deltaVelocityCCFromForceCC.inverse();

    // We now need to work out what velocity change to feed into this matrix. 
    // The velocity change in the contact normal direction is...
    double deltaSpeedNormal = [self calculateDeltaNormalSpeedDueToBounce:dt];
    
    // If friction is strong enough, it will kill the tangential component of the
    // approach velocity completely. In this case, the deltaVelocity is
    KSMVector3 deltaVelCC = KSMVector3(deltaSpeedNormal,
                                       - _approachVelocityCC.y, 
                                       - _approachVelocityCC.z);
    
    // and so the impulse required to bring this about is
    KSMVector3 impulseCC = impulseCCFromDeltaVelCC * deltaVelCC;
    
    // But is it possible that friction cannot provide the impulse required to 
    // kill the tangential approach velocity. To test if this is the case, we
    // calculate the magnitude of the tangential component of the impulse and 
    // compare it to the maximum frictional impulsive force (which we will 
    // obtain from the normal component of the impulse and the coefficient of
    // friction).
    double magnitudeTangentialImpulse; 
    magnitudeTangentialImpulse = sqrt( impulseCC.y * impulseCC.y + 
                                       impulseCC.z * impulseCC.z );
    
    // Is the tangential impulse larger than friction can provide?
    if ( magnitudeTangentialImpulse > impulseCC.x * _friction ) 
    {
        // Friction cannot kill all the tangential velocity.
        // We are in the realm of dynamic friction where the tangential
        // velocity will only be partly killed by friction. We must scale back 
        // the impulse to reduce the amount of tangential speed that is killed, 
        // but this isn't a straightforward scaling of the tangential components 
        // of the impulse because the tangential components of the impulse affect
        // the normal component of the delta V (because they are related via a
        // 3x3 matrix), and the normal component of delta V is constrained by
        // the coefficient of restitution, not friction.

        // we are going to change the values of all three components of the
        // impulse in such a way that the total impulse continues to provide the
        // required deltaVx (which comes from the bounce), and the x and y 
        // components of the impulse will be constrained to be in the same 
        // proportion as the previously calculated impulse.
        
        // If we define the angle theta to be the angle between the y component
        // of the impulse and the tangential component (vector sum of y and z
        // components) then we can find cos(theta) and sin(theta) as follows...
        double cosTheta = impulseCC.y / magnitudeTangentialImpulse;
        double sinTheta = impulseCC.z / magnitudeTangentialImpulse;
        
        // The other thing that we know is the the deltaV in the normal 
        // direction, which is |deltaSpeedNormal|. Suppose that the actual 
        // impulse (yet to be found), has components...
        double actualImpulseXCC;
        double actualImpulseYCC;
        double actualImpulseZCC;
        
        // and that the actual change in velocity has components
        double actualDeltaVelXCC = deltaSpeedNormal; // from the bounce
        // double actualDeltaVelYCC; // never needs to be determined explicitly
        // double actualDeltaVelZCC; // never needs to be determined explicitly
        
        // Consider the equation...
        //
        //      actualImpulseCC = impulseCCFromDeltaVelCC * actualDeltaVelCC
        //
        // invert to write...
        //
        //      actualDeltaVelCC = deltaVelCCFromImpulseCC * actualImpulseCC
        //
        // Now consider just the x component of actualDeltaVelCC, which comes
        // from...
        //
        // actualDeltaVelCC =  deltaVelCCFromImpulseCC_11 * actualImpulseXCC
        //                   + deltaVelCCFromImpulseCC_12 * actualImpulseYCC
        //                   + deltaVelCCFromImpulseCC_13 * actualImpulseZCC
        //
        // where, for example, _12 indicates the matrix element at row one, 
        // column two.
        // Also, note that from the way the matrix stores its
        // internal data, we have... 
        // deltaVelCCFromImpulseCC.d[0] = deltaVelCCFromImpulseCC_11
        // deltaVelCCFromImpulseCC.d[3] = deltaVelCCFromImpulseCC_12
        // deltaVelCCFromImpulseCC.d[6] = deltaVelCCFromImpulseCC_13
        //
        // But from the law of friction we can relate the tangential impulse
        // to the normal impulse via the coefficient of friction...
        // actualImpulseYCC = _friction * actualImpulseXCC * cos(theta)
        // actualImpulseZCC = _friction * actualImpulseXCC * sin(theta)
        //
        // Combining these equations, factoring out the actualImpulseXCC, and 
        // rearranging to solve for |actualImpulseXCC|, we get...
        actualImpulseXCC = actualDeltaVelXCC / 
            ( deltaVelocityCCFromForceCC.d[0] + 
                    _friction * ( cosTheta * deltaVelocityCCFromForceCC.d[3] + 
                                  sinTheta * deltaVelocityCCFromForceCC.d[6] ) );
        
        // and now we can find the tangential components
        actualImpulseYCC = _friction * cosTheta * actualImpulseXCC;
        actualImpulseZCC = _friction * sinTheta * actualImpulseXCC;
        
        // copy these impulse components back into the impulse vector and
        // proceed as we would have done had we not needed to modify the impulse.
        impulseCC.x = actualImpulseXCC;
        impulseCC.y = actualImpulseYCC;
        impulseCC.z = actualImpulseZCC;
    }
    
    // We now have the impulse in contact coordinates that will produce the
    // delta velocity required to bounce in the normal direction and reduce the
    // tangential velocity due to friction. We must now apply the impulse to the
    // two bodies, but this is best done in world coordinates...
    KSMVector3 impulseWC = _contactToWorld * impulseCC;
    
    // Now we calculate and apply the linear effect of the impulse on body A
    KSMVector3 deltaVelocityA  = _invMassA * impulseWC;
    KSMVector3 currentVelocityA = [_bodyA linearVelocity];
    KSMVector3 newVelocityA    = currentVelocityA + deltaVelocityA;
    [_bodyA setLinearVelocity:newVelocityA];
    
    // and do the same for the angular effect
    KSMVector3 impulsiveTorqueOnA      = _aTocWC % impulseWC;
    KSMVector3 deltaAngularVelocityA   = _invMIA * impulsiveTorqueOnA;
    KSMVector3 currentAngularVelocityA = [_bodyA angularVelocity];
    [_bodyA setAngularVelocity:currentAngularVelocityA + deltaAngularVelocityA];
    
    // If B is moveable we need to calculate the effect of the imulse on B too.
    if (_massB < DBL_MAX) 
    {
        // The impulse on B is equal and opposite to the impulse on A...
        impulseWC.reverse();
        
        // and now we can proceed as we did with body A. First, we apply linear 
        // effect of the impulse
        KSMVector3 deltaVelocityB  = _invMassB * impulseWC;
        KSMVector3 currentVelocityB = [_bodyB linearVelocity];
        [_bodyB setLinearVelocity:currentVelocityB + deltaVelocityB];

        // apply angular effect of impulse
        KSMVector3 impulsiveTorqueOnB      = _bTocWC % impulseWC;
        KSMVector3 deltaAngularVelocityB   = _invMIB * impulsiveTorqueOnB;
        KSMVector3 currentAngularVelocityB = [_bodyB angularVelocity];
        [_bodyB setAngularVelocity:currentAngularVelocityB + 
                                                         deltaAngularVelocityB];

    }
    _closingSpeed = 0;
}

@end
