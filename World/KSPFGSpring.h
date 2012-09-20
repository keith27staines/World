//
//  KSPFGSpring.h
//  World
//
//  Created by Keith Staines on 07/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSPForceGeneratorBase.h"

@interface KSPFGSpring : KSPForceGeneratorBase
{
    double naturalLength;
    double springConstant;
    double dampingConstant;
    BOOL isBungee;
}

@property (assign)   double naturalLength;
@property (assign)   double springConstant;
@property (assign)   double dampingConstant;
@property (assign)   BOOL  isBungee;
@property (readonly) double mass;

// designated constructor - must be overridden in derived classes
-(id)initWithNaturalLength:(double)length 
            springConstant:(double)spring 
           dampingConstant:(double)damping
                  isBungee:(BOOL)bungee;

// return the damping ratio. If > 1, then strongly damped. If = 1, critically
// damped. if < 1, weakly damped.
-(double)dampingRatio;

// returns the natural frequency of the system (assuming no other forces acting)
-(double)naturalAngularFrequency;

// returns the natural period of the system (assuming no other forces acting)
-(double)naturalPeriod;

// return the effective mass of the system
-(double)mass;

// called by methods that must be overridden and not called themselves
-(void)mustOverride;

// returns the value of the damping constant required to provide critical
// damping. Anything higher is strongly dampled, anything lower is weakly damped.
-(double)criticalDampingConstant;

// sets the spring constant to provide the specified natural period
-(void)setNaturalPeriod:(double)requiredPeriod;

// sets the spring constant to provide the specified natural angular frequency
-(void)setNaturalAngularFrequency:(double)requiredAngularFrequency;

// sets the damping factor to the value required for critical damping
-(void)makeCriticallyDamped;

@end
