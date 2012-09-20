//
//  KSCContact.h
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"
@class KSPPhysicsBody;

// speed below which the coefficient of restitution reduces linearly to zero
const double LOWSPEEDLIMIT = 0.1;

/*
 Returns the vector representing the inverse rotational inertia of a body with
 inverse moment of inertia |invMI} due to a force acting on the body at position
 |r| and in direction |direction|.
 */
KSMVector3 invRotInertia(KSMMatrix3 invMI, 
                         KSMVector3& relativePosition, 
                         KSMVector3& direction);

KSMMatrix3 rCrossProduct(KSMVector3 & pointOfAction);


@interface KSCContact : NSObject
{
    KSPPhysicsBody * __weak _bodyA;
    KSPPhysicsBody * __weak _bodyB;
    
    // position of the contact in world coordinates
    KSMVector4 _contactPointWC;
    
    // direction of the contact normal in world coordinates
    // (points from B to A)
    KSMVector3 _contactNormalWC;
    
    // depth of penetration (-ve values signify no penetration)
    double _depth;
    
    // coefficient of restitution
    double _restitution;
    
    // coefficient of friction
    double _friction;
        
    // caches for the immutable body properties
    KSMMatrix3 _invMIA;  // inverse moment of inertia about CM
    KSMMatrix3 _invMIB;  // ditto B
    double _massA;       // inertial mass of A
    double _massB;       // ditto B
    double _invMassA;    // inverse inertial mass of B
    double _invMassB;    // ditto B
    
    /*
     All the data below is cached and updated by the "calulateInterals" method
     */
    
    // contact coordinate system and the transforms to and from it
    KSMMatrix3 _contactToWorld;
    KSMMatrix3 _worldToContact;
    KSMVector3 _tangent1;
    KSMVector3 _tangent2;
    
    // properties defining the collision
    KSMVector3 _approachVelocityCC; // as seen by B
    KSMVector3 _aTocWC; // position of contact relative to A
    KSMVector3 _bTocWC; // ditto B
    
    // closing speed (measure of severity of the contact). 
    // NB -ve values signify the bodies are moving apart.
    double _closingSpeed;
    
    /*
     The quantities below are byproducts of the adjustBodyPositions method
     but are useful in determining the change in contact position of other
     contacts due to the position adjustments made resolving this contact.
     */
    
    // linear movement (displacement of centre of mass) of the respective bodies
    // along the contact normal
    double _dxLinearA;
    double _dxLinearB;
    
    // angle through which the respective bodies have been rotated 
    double _angleA;
    double _angleB;
    
    // axis (through their centres of mass) about which the respective bodies
    // have been rotated
    KSMVector3 _axisA;
    KSMVector3 _axisB;

}

@property (assign)   const KSMVector4     & contactPointWC;
@property (assign)   const KSMVector3     & contactNormalWC;
@property (readonly) const KSMMatrix3     & contactToWorld;
@property (readonly) const KSMMatrix3     & worldToContact;
@property (weak)           KSPPhysicsBody * bodyA;
@property (weak)           KSPPhysicsBody * bodyB;
@property (assign)         double           depth;
@property (assign)         double           restitution;
@property (assign)         double           friction;
@property (readonly)       double           closingSpeed;
@property (readonly)       KSMVector3       bodyAToContactWC;
@property (readonly)       KSMVector3       bodyBToContactWC;

// Position and orientation adjustments made as a result of resolving 
// interpenetrations of the bodies. The bodies are translated and rotated, so we
// expose readonly vectors representing both quantities for both bodies.
// Vectors representing the axis of rotation (by their direction) and
// the angle rotated through by their magnitude.
@property (readonly)       KSMVector3       rotationA;
@property (readonly)       KSMVector3       rotationB;
@property (readonly)       KSMVector3       translationA;
@property (readonly)       KSMVector3       translationB;

// designated constructor
-(id)initWithBodyA:(KSPPhysicsBody*)bodyA 
             bodyB:(KSPPhysicsBody*)bodyB 
 contactPositionWC:(const KSMVector4&)position 
   contactNormalWC:(const KSMVector3&)normal 
  penetrationDepth:(double)depth 
       restitution:(double)restitution
          friction:(double)friction;

// calculate the internal data of the contact. The specified dt is 
//
-(void)calculateInternals:(double)dt;

// move the bodies to remove penetration
-(void)adjustBodyPositions:(double)dt;

// change the bodies velocities in response to the collision
-(void)adjustBodyVelocities:(double)dt;

// ensure that if one body is awake, then the other body is too
-(void)matchAwakeState;

// PRIVATE
-(void)calculateContactToWorld;

@end
