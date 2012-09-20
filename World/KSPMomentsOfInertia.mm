//
//  KSPMomentsOfInertia.mm
//  World
//
//  Created by Keith Staines on 28/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPMomentsOfInertia.h"

@implementation KSPMomentsOfInertia

// solid sphere of uniform density
+(KSMMatrix3)sphereOfMass:(double)mass radius:(double)radius
{
    KSMMatrix3 mI = (2.0 * mass * radius * radius/5.0) * KSMMatrix3();
    return mI;
}

// inifinitely thin spherical shell 
+(KSMMatrix3)shellOfMass:(double)mass radius:(double)radius
{
    KSMMatrix3 mI = (2.0 * mass * radius * radius/3.0) * KSMMatrix3();
    return mI;    
}

// solid cuboid of uniform density
+(KSMMatrix3)cuboidOfMass:(double)mass 
                  xLength:(double)xLength 
                  yLength:(double)yLength 
                  zLength:(double)zLength
{
    KSMMatrix3 mI = KSMMatrix3();
    mI.d[0] = (mass / 12.0) * (yLength*yLength + zLength * zLength);
    mI.d[4] = (mass / 12.0) * (xLength*xLength + zLength * zLength);
    mI.d[8] = (mass / 12.0) * (xLength*xLength + yLength * yLength);
    return mI;      
}

// solid cylinder of uniform density and principal axis in z direction
+(KSMMatrix3)cylinderOfMass:(double)mass 
                     length:(double)length 
                     radius:(double)radius
{
    KSMMatrix3 mI = KSMMatrix3();
    mI.d[0] = mass * (length*length/12.0 + radius * radius/4.0);
    mI.d[4] = mass * (length*length/12.0 + radius * radius/4.0);
    mI.d[8] = mass * (radius * radius/2.0);
    return mI;
}

// solid uniform cone and principal axis in z direction
+(KSMMatrix3)coneOfMass:(double)mass 
                 length:(double)length 
                 radius:(double)radius
{
    double I11 = mass * 3.0 / 80.0 * length * length +
                        3.0 / 20.0 * radius * radius;
    double I22 = I11;
    double I33 = 3.0 / 10.0 * mass * radius * radius;
    KSMMatrix3 mI = KSMMatrix3();
    mI.d[0] = I11;
    mI.d[4] = I22;
    mI.d[8] = I33;
    return mI;   
}

@end
