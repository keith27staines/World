//
//  KSPSolarSystemObject.h
//  World
//
//  Created by Keith Staines on 09/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"
#import "KSPPhysics.h"

@interface KSPSolarSystemObject : NSObject
{
    NSUInteger index;
}

// returns the name of the parent object (the object about which this object
// orbits)
@property (readonly, strong) KSPSolarSystemObject * parentObject;

// returns the name of the object
@property (readonly, strong) NSString * name;

// returns a description of the object including its parent body
@property (readonly, strong) NSString * description;

// returns the radius of the object in meters
@property (readonly) double radius;

// returns the volume of the object
@property (readonly) double volume;

// returns the radius of the object relative to the sun's radius
@property (readonly) double radiusInRs;

// returns the radius of the object relative to the earth
@property (readonly) double radiusInRe;

// returns the radius of the object relative to its parent
@property (readonly) double radiusInParentRadii;

// returns the mass of the object in kg
@property (readonly) double mass;

// returns the mass of the oject relative to the mass of the sun
@property (readonly) double massInMs;

// returns the mass of the object relative to the mass of the earth
@property (readonly) double massInMe;

// returns the mass of the object relative to its parent
@property (readonly) double massInParentMasses;

// returns the orbital radius of the object about its parent in meters
@property (readonly) double orbitalRadius;

// returns the orbital radius of the object in units of the parent's radius
@property (readonly) double orbitalRadiusInParentRadii;

// returns the orbital radius of the object in AU
@property (readonly) double orbitalRadiusInAU;

// returns the density of the object in kg m3
@property (readonly) double density;

// returns the acceleration due to gravity on the surface of the object
@property (readonly) double surfaceGravity;

// returns the acceleration due to gravity at the specified distance. If the 
// distance is less than the radius (ie, we are considering a point beneath
// the surface), the result returned is based on the assumption of uniform
// density
-(double)gravityAtDistance:(double)distance;




@end

