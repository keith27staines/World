//
//  KSPPhysicsBody.h
//  World
//
//  Created by Keith Staines on 05/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"
double const SLEEPEPSILON = 0.05;
double const RECENCYBIAS = 0.8; 

@interface KSPPhysicsBody : NSObject
{
    
    // Primitive assembly
    NSArray * _primitiveAssembly;
    
    // Position and orientation info held in a single 4x4 matrix
    KSMMatrix4 _modelWorld;
    
    // mass related quantities
    double     _mass;                          // mass (kg)
    double     _inverseMass;                   // (kg)-1;
    KSMMatrix3 _mI;                            // moment of inertia
    KSMMatrix3 _inverseMI;                     // inverse moment of inertia
    double     _effectiveAreaForDrag;          // effective area
    double     _characteristicLinearDimension; // effective radius
    
    // linear velocity and acceleration 
    KSMVector3 _linearVelocity;
    KSMVector3 _linearAcceleration;
    
    // angular velocity and acceleration
    KSMVector3 _angularVelocity;
    KSMVector3 _angularAcceleration;
    
    // force accumulators
    KSMVector3 _force;
    KSMVector3 _torque; // (about centre of mass)
    
    // sleep system
    double     _recentMotion;
    BOOL       _isAwake;
    BOOL       _canSleep;
}

@property (assign)         double       effectiveAreaForDrag;
@property (assign)         double       characteristicLinearDimension;
@property (assign)         double       mass;
@property (readonly)       double       inverseMass;
@property (assign)   const KSMMatrix3 & mI; 
@property (readonly) const KSMMatrix3 & inverseMI;
@property (assign)   const KSMMatrix4 & modelWorld;
@property (assign)   const KSMVector3 & linearVelocity;
@property (assign)   const KSMVector3 & linearAcceleration;
@property (assign)   const KSMVector3 & angularVelocity;
@property (assign)   const KSMVector3 & angularAcceleration;
@property (strong)         NSArray    * primitiveAssembly;
@property (assign)         double       recentMotion;
@property (assign)         BOOL         isAwake;
@property (assign)         BOOL         canSleep;

// designated constructor
-(id)initWithMass:(double)mass
  momentOfInertia:(const KSMMatrix3&)momentOfInertia
   linearVelocity:(const KSMVector3&)linearVelocity
  angularVelocity:(const KSMVector3&)angularVelocity
     modelToWorld:(const KSMMatrix4&)modelWorld
primitiveAssembly:(NSArray*)primitives
         canSleep:(BOOL)canSleep
          isAwake:(BOOL)isAwake
    effectiveArea:(double)effectiveArea
  effectiveRadius:(double)radius;

// getter and setter for position (outside of control of physics)
-(KSMVector3)position;
-(void)setPosition:(const KSMVector3 &)position;

// in preparation for the next frame, reset force and torque accumulators
-(void)resetForceAccumulators;

// integrate equations of motion 
-(void)integrateOverInterval:(double)dt;

// Tells the body that it is being acted on by the specified force (which is 
// assumed to be in WORLD coordinates) and that the force is being applied at
// the centre of mass. The body is woken when this method is called.
- (void)addForceThroughCM:(const KSMVector3&)aForce;

// Tells the body that it is being acted on by the specified force (which is 
// assumed to be in WORLD coordinates) and that the force is being applied at
// the centre of mass. The body is NOT woken when this method is called. This
// method should be called by force generators that generate constant forces.
- (void)addForceThroughCMWithoutWaking:(const KSMVector3 &)aForce;

// Tells the body that it is being acted on by the specified force (which is 
// assumed to be in WORLD coordinates) and that the force is being applied at
// the specified position in BODY coordinates. The body is woken when this 
// method is called.
- (void)addForce:(const KSMVector3&)aForce 
  atBodyPosition:(const KSMVector3&)aBodyPosition;

// Tells the body that it is being acted on by the specified force (which is 
// assumed to be in world coordinates) and that the force is being applied at
// the specified position. The body is woken when this method is called.
- (void)addForce:(const KSMVector3&)aForce 
 atWorldPosition:(const KSMVector3&)aWorldPosition;

// returns a vector in world coordinates representing the position specified
//in model coordinates.
-(KSMVector4)bodyPositionInWorldCoordinates:(const KSMVector4&)bodyPositionMC;

// returns the specified direction (provided in body coordinates) to world coords
-(KSMVector3)bodyDirectionInWorldCoordinates:(const KSMVector3&)bodyDirection;


// returns the velocity expressed in world coordinates of the point on the body
// defined by bodyPositionMC. This takes into account both the translational
// motion of the body and its speed of rotation.
-(KSMVector3)velocityWCOfBodyPositionMC:(const KSMVector4&)bodyPositionMC;

// returns the velocity expressed in world coordinates of the point on the body
// defined by bodyPositionWC (i.e, in world coordinates. The result takes into 
// account both the translational motion of the body and its speed of rotation.
-(KSMVector3)velocityWCOfBodyPositionWC:(const KSMVector4&)bodyPositionWC;

// returns the position vector of the specified position (specified in world
// coordinates) relative to the centre of mass. The result is in world coordinates.
-(KSMVector3)positionRelativeToCentreOfMass:(const KSMVector4&)positionWC;

@end
