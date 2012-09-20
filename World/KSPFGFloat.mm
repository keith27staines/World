//
//  KSPFGFloat.m
//  World
//
//  Created by Keith Staines on 07/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPFGFloat.h"
#import "KSPWater.h"
#import "KSPConstants.h"

@implementation KSPFGFloat

@synthesize water;
@synthesize physicsBody;
@synthesize density;
@synthesize length;
@synthesize crossSectionalArea;

-(double)mass
{
    return crossSectionalArea * length * density;
}

-(void)setBodyAttachPositionMC:(KSMVector4)positionMC
{
    bodyAttachPositionMC = positionMC;
}

-(KSMVector4)bodyAttachPositionMC
{
    return bodyAttachPositionMC;
}

-(void)setDirectionMC:(const KSMVector4 &)aDirectionMC
{
    directionMC = aDirectionMC;
}

-(const KSMVector4 &)directionMC
{
    return directionMC;
}

-(id)init
{

    return [self initWithDensity:0 
                          length:1 
              crossSectionalArea:1 
           attachedToPhysicsBody:nil 
          atBodyAttachPositionMC:KSMVector4() 
                   inDirectionMC:KSMVector4() 
               registerWithWater:nil];
}

-(id)     initWithDensity:(double)aDensity 
                   length:(double)aLength 
       crossSectionalArea:(double)area 
    attachedToPhysicsBody:(KSPPhysicsBody*)body 
   atBodyAttachPositionMC:(const KSMVector4&)attachmentPosition 
            inDirectionMC:(const KSMVector4&)direction 
        registerWithWater:(KSPWater*)bodyOfWater
{
    self = [super init];
   
    density = aDensity;
    length = aLength;
    crossSectionalArea = area;
    physicsBody = body;
    bodyAttachPositionMC = attachmentPosition;
    directionMC = direction;
    water = bodyOfWater;

    return self;
}

-(void)applyForce
{
    // we will work in world coordinates (WC) to calculate the buoyancy force. 
    // The water properties are already defined in world coordinates, but this 
    // float's internal data are held in body coordinates (MC) and must be
    // transformed.
    
    // get float position in world coordinates
    KSMVector4 floatPosWC4 = [physicsBody 
                           bodyPositionInWorldCoordinates:bodyAttachPositionMC];
    
    KSMVector3 floatPosWC = floatPosWC4.vector3();
    double xFloat = floatPosWC.x;
    double zFloat = floatPosWC.z;
    
    // get the float direction in world coordinates
    KSMVector3 directionMC3 = directionMC.vector3();
    KSMVector3 floatDirWC   = [physicsBody 
                                  bodyDirectionInWorldCoordinates:directionMC3];
    
    // the water is defined in world coordinates
    KSMVector3 waterNormal = [[self water] surfaceNormalAtXposition:xFloat 
                                                          zPosition:zFloat];
    
    // get the position vector of the water at the float's x,z position
    KSMVector3 waterPosition = [water surfaceHeightAtXposition:xFloat 
                                                     zPosition:zFloat] 
                                                                  * waterNormal;
    
    // In the vector equation of a plane, the offset is the distance of the plane
    // from the origin as measured along the normal
    double waterOffset = waterPosition * waterNormal;

    // Find the point of intersection of the float with the water surface. 
    // The intersection represents the distance along the direction of the float
    // to the water surface.
    double intersection = KSMIntersections::rayAndPlane(floatPosWC, 
                                                       floatDirWC, 
                                                       waterNormal, 
                                                       waterOffset);

    double submergedLength = 0;
    if ( (floatPosWC - waterPosition) * waterNormal > 0 ) 
    {
        // float attach point is above the water surface
        if (intersection > 0) 
        {
            // float above water and pointing down. intersection represents
            // distance to water along direction of float
            submergedLength = fmax(length - intersection, 0.0);            
        }
        else
        {
            // float above water and pointing up
            submergedLength = 0.0;
        }
    }
    else
    {   
        // float attach point is below the water surface
        if (intersection > 0) 
        {
            // float under water but pointing towards surface. intersection
            // represents distance to air along direction of float
            submergedLength = fmin(length, intersection);
        }
        else
        {
            // float under water and pointing down, so all of float is submerged
            submergedLength = length;
        }
    }
    
    if (submergedLength <= 0) 
    {
        // no part of the float is submerged, therefore it provides no buoyancy
        return;
    }
    
    // mass of displaced fluid
    double displacedMass = submergedLength * crossSectionalArea * [water density];
    
    // Archimedes' principle, upthrust = weight of water displaced, acting in 
    // opposite direciton to gravity
    KSMVector3 upthrust = - displacedMass * kspcEarthGravity;    
    
    // apply equivalent force to the point where the float attaches to the body
    [physicsBody addForce:upthrust atBodyPosition:bodyAttachPositionMC.vector3()];
    
}
@end
