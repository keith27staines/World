//
//  KSPFGSpring.mm
//  World
//
//  Created by Keith Staines on 07/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPFGSpring.h"

@implementation KSPFGSpring

@synthesize naturalLength;
@synthesize springConstant;
@synthesize dampingConstant;
@synthesize isBungee;

-(void)mustOverride
{
    [NSException raise:@"Must override. Do not call this method." 
                format:@"The subclass should not call this method."];    
}

// override designated constructor of super
-(id)init 
{
    [NSException raise:@"init not to be used as constructor for this object." 
                format:@"Use undampedSpringWithNaturalLength:... to construct this object"];
    return nil;
}

// designated constructor
-(id)initWithNaturalLength:(double)length 
            springConstant:(double)spring 
           dampingConstant:(double)damping
                  isBungee:(BOOL)bungee
{
    self = [super init];
    if (self) 
    {
        [self setNaturalLength:length];
        [self setSpringConstant:spring];
        [self setDampingConstant:damping];
        [self setIsBungee:bungee];
    }
    return self;
}

-(double)dampingRatio
{
    return dampingConstant / [self criticalDampingConstant];
}

-(double)naturalAngularFrequency
{
    return sqrt(springConstant / [self mass]);
}

-(double)naturalPeriod
{
    return TWOPI / [self naturalAngularFrequency];
}

-(double)mass
{
    [self mustOverride];
    return 0.0;
}

-(void)applyForce
{
    [self mustOverride];
}

-(double)criticalDampingConstant
{
    return 2.0 * sqrt( [self mass] * springConstant );
}

-(void)setNaturalAngularFrequency:(double)requiredAngularFrequency
{
    springConstant = requiredAngularFrequency * requiredAngularFrequency 
                                              * [self mass];
}

-(void)setNaturalPeriod:(double)requiredPeriod
{
    double af = TWOPI / requiredPeriod;
    [self setNaturalAngularFrequency:af];
}

-(void)makeCriticallyDamped
{
    dampingConstant =  [self criticalDampingConstant];
}
@end
