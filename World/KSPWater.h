//
//  KSPWater.h
//  World
//
//  Created by Keith Staines on 08/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"

@class KSPPhysicsBody;
@class KSPFGdouble;
@class KSPFGFloat;

@interface KSPWater : NSObject
{
    double density;
}
@property (assign) double density;

-(KSMVector3)surfaceNormalAtXposition:(double)x zPosition:(double)z;

//
-(double)surfaceHeightAtXposition:(double)x zPosition:(double)z;

// returns a new float, fully registered with the water it will
// float in.
-(KSPFGFloat*)floatWithDensity:(double)density 
                        length:(double)length
            crossSectionalArea:(double)area
                    attachedTo:(KSPPhysicsBody*)body 
              atBodyPositionMC:(const KSMVector4&)bodyPositionMC
             inBodyDirectionMC:(const KSMVector4&)directionMC;

@end
