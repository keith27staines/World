//
//  KSVVehicle.mm
//  World
//
//  Created by Keith Staines on 13/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSVVehicle.h"
#import "KSPPhysics.h"
#import "KSGGameObject.h"
#import "KSCBoundingVolume.h"

@implementation KSVVehicle

+(void)equipAsBoat:(KSGGameObject*)gameObject 
           inWater:(KSPWater*)water 
     buoyancyRatio:(double)buoyancy
registerForceGeneratorsWith:(KSPForceGeneratorRegistry *)registry
{
    // define the dimensions that will separate the floats
    double halfLength = [[gameObject boundingVolume] radius];
    double halfWidth  = 0.5 * halfLength;
    double halfHeight = halfWidth;
    
    // get the weight that the floats must support
    KSPPhysicsBody * body = [gameObject physicsBody];
    double weight = [body mass] * kspc1G;
    
    // calculate upthrust required from each float
    double requiredUpthrust = weight * buoyancy / 4.0;
    double area = requiredUpthrust / ( water.density * halfHeight * kspc1G );
    
    // create the attachment points
    KSMVector4 frontAttach = KSMVector4(0.0,  0.0, halfHeight,  1.0);
    KSMVector4 backAttach  = KSMVector4(0.0,  0.0, -halfHeight, 1.0);
    KSMVector4 leftAttach  = KSMVector4(-halfWidth, 0.0,  0.0,  1.0);
    KSMVector4 rightAttach = KSMVector4( halfWidth, 0.0,  0.0,  1.0);
    
    // define the direction the floats will point in
    KSMVector4 downVector = KSMVector4( 0.0, -1.0, 0.0, 0.0 );
                                      
    // create the front float
    KSPFGFloat * front = [water floatWithDensity:0.0 
                                          length:halfHeight 
                              crossSectionalArea:area 
                                      attachedTo:body 
                                atBodyPositionMC:frontAttach 
                               inBodyDirectionMC:downVector];

    // create the back float
    KSPFGFloat * back  = [water floatWithDensity:0.0 
                                          length:halfHeight 
                              crossSectionalArea:area 
                                      attachedTo:body 
                                atBodyPositionMC:backAttach 
                               inBodyDirectionMC:downVector];
    
    // create the left float
    KSPFGFloat * left = [water floatWithDensity:0.0 
                                         length:halfHeight 
                             crossSectionalArea:area 
                                     attachedTo:body 
                               atBodyPositionMC:leftAttach 
                              inBodyDirectionMC:downVector];
    
    // create the right float
    KSPFGFloat * right = [water floatWithDensity:0.0 
                                          length:halfHeight 
                              crossSectionalArea:area 
                                      attachedTo:body 
                                atBodyPositionMC:rightAttach 
                               inBodyDirectionMC:downVector];
    
    // add the new float force generators to the force generator registry
    [registry registerGenerator:front];
    [registry registerGenerator:back];
    [registry registerGenerator:left];
    [registry registerGenerator:right];
}

@end
