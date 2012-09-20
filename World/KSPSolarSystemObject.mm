//
//  KSPSolarSystemObject.mm
//  World
//
//  Created by Keith Staines on 09/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPSolarSystemObject.h"

@implementation KSPSolarSystemObject

@synthesize name, description;
@synthesize parentObject;
@synthesize mass, radius, orbitalRadius;


-(double)gravityPotentialAtDistance:(double)distance
{
    double G = kspcGravitationalConstant;
    
    return G * mass / (distance * distance); 
}

-(double)volume
{
    return FOURPIBY3 * radius*radius*radius;
}

-(double)radiusInAU
{
    return radius / kspcAstronomy1AU;
}

-(double)radiusInRe
{
    return radius / kspcAstronomyRadiusOfEarth;
}

-(double)radiusInRs
{
    return radius / kspcAstronomyRadiusOfSun;
}

-(double)massInMe
{
    return mass / kspcAstronomyMassOfEarth;
}

-(double)massInMs
{
    return mass / kspcAstronomyMassOfSun;
}

-(double)radiusInParentRadii
{
    if (!parentObject) return 1.0;
    return radius/ parentObject.radius;
}

-(double)orbitalRadiusInAU
{
    return orbitalRadius / kspcAstronomy1AU;
}

-(double)orbitalRadiusInParentRadii
{
    if (!parentObject) return 1.0;
    return orbitalRadius / parentObject.radius;
}

-(double)massInParentMasses
{
    if (!parentObject) return 1.0;
    return mass / parentObject.mass;
}

-(double)surfaceGravity
{
    return kspcGravitationalConstant * mass / (radius*radius);
}

-(double)density
{
    return mass / [self volume];
}

-(double)gravityAtDistance:(double)distance
{
    if (distance > radius) 
    {
        return kspcGravitationalConstant * mass / (distance * distance);
    }
    else
    {
        // Beneath the surface. Approximate only (assumes uniform density)
        return kspcGravitationalConstant * 
               [self density] * FOURPIBY3 * radius*radius*radius / 
               (distance * distance);
    }
}
@end
