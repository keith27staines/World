//
//  KSPWater.mm
//  World
//
//  Created by Keith Staines on 08/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPWater.h"
#import "KSPPhysicsBody.h"
#import "KSPFGFloat.h"

@implementation KSPWater
@synthesize density;

-(id)init
{
    self = [super init];
    density = 1000; // default to water
    return self;
}

-(KSMVector3)surfaceNormalAtXposition:(double)x zPosition:(double)z
{
    // default implementation is still water, so surface normal is always
    // vertically up (i.e, parallel to the positive y axis)
    return KSMVector3(0, 1, 0);
}

-(double)surfaceHeightAtXposition:(double)x zPosition:(double)z
{
    // default implementation is that the surface is at Y = 0;
    return -0.25;
}

-(KSPFGFloat*)floatWithDensity:(double)aDensity 
                        length:(double)aLength
            crossSectionalArea:(double)anArea 
                    attachedTo:(KSPPhysicsBody*)aBody 
              atBodyPositionMC:(const KSMVector4&)aBodyPositionMC
             inBodyDirectionMC:(const KSMVector4&)aDirectionMC
{
    // construct and return the float
    return [[KSPFGFloat alloc] initWithDensity:aDensity 
                                        length:aLength 
                            crossSectionalArea:anArea 
                         attachedToPhysicsBody:aBody 
                        atBodyAttachPositionMC:aBodyPositionMC 
                                 inDirectionMC:aDirectionMC 
                             registerWithWater:self];
}

@end
