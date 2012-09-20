//
//  KSPFGSphericalGravitySource.mm
//  World
//
//  Created by Keith Staines on 03/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPFGSphericalGravitySource.h"
#import "KSPPhysics.h"

@implementation KSPFGSphericalGravitySource
@synthesize source = _source;
@synthesize strength = _strength;

-(id)initWithSource:(KSPPhysicsBody*)source strength:(double)strength
{
    self = [super init];
    _source   = source;
    _strength = strength;
    return self;
}

-(id)init
{
    return [self initWithSource:nil strength:0];
}

-(void)makeStrengthLikeRealGravity
{
    _strength = [self.source mass] * kspcGravitationalConstant;
}

-(KSMVector3)forceOnBody:(KSPPhysicsBody*)body overInterval:(double)dt
{
    double m = [body mass];
    KSMVector3 sourcePosition     = [self.source position];
    KSMVector3 bodyPosition       = [body position];
    KSMVector3 r                  = bodyPosition - sourcePosition;
    double     d                  = r.length();
    KSMVector3 gravityForceOnBody = - (_strength * m / (d * d * d) ) * r;
    return gravityForceOnBody;
}

@end
