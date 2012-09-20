//
//  KSPFGFloat.h
//  World
//
//  Created by Keith Staines on 07/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"
#import "KSPForceGeneratorBase.h"

@class KSPWater;

@interface KSPFGFloat : KSPForceGeneratorBase
{
    KSMVector4 bodyAttachPositionMC;
    KSMVector4 directionMC;
}

// the physics body to which this float is contributing buoyancy
@property (readwrite, weak) KSPPhysicsBody * physicsBody;

// the water in which the float and its associated physics body are floating
@property (readwrite, weak) KSPWater * water;

// density of the float in kg / m3
@property (assign) double density;

// length of the float in m
@property (assign) double length;

// cross sectional area of the float
@property (assign) double crossSectionalArea;

// point at which the float attaches to the physics body in body coords
@property (assign) KSMVector4 bodyAttachPositionMC;

// direction in which the float points in body coords (starting FROM the attach
// point)
@property (assign) const KSMVector4 & directionMC;

// actual physical mass of the float (but note that the mass that must appear
// in f = ma is the sum of this mass and the mass of displaced fluid)
@property (readonly) double mass;

-(id)     initWithDensity:(double)aDensity 
                   length:(double)aLength 
       crossSectionalArea:(double)area 
    attachedToPhysicsBody:(KSPPhysicsBody*)body 
   atBodyAttachPositionMC:(const KSMVector4&)attachmentPosition 
            inDirectionMC:(const KSMVector4&)direction 
        registerWithWater:(KSPWater*)bodyOfWater;

@end
