//
//  KSPMomentsOfInertia.h
//  World
//
//  Created by Keith Staines on 28/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"

@interface KSPMomentsOfInertia : NSObject
{
    
}

// solid sphere of uniform density
+(KSMMatrix3)sphereOfMass:(double)mass radius:(double)radius;

// inifinitely thin spherical shell 
+(KSMMatrix3)shellOfMass:(double)mass radius:(double)radius;

// solid cuboid of uniform density
+(KSMMatrix3)cuboidOfMass:(double)mass 
                  xLength:(double)xlength 
                  yLength:(double)yLength 
                  zLength:(double)zLength;

// solid cylinder of uniform density and principal axis in z direction
+(KSMMatrix3)cylinderOfMass:(double)mass 
                     length:(double)length 
                     radius:(double)radius;

// solid uniform cone and principal axis in z direction
+(KSMMatrix3)coneOfMass:(double)mass 
                 length:(double)length 
                 radius:(double)radius;
@end
