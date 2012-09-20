//
//  KSPFGSphericalGravitySource.h
//  World
//
//  Created by Keith Staines on 03/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSPFGUniversalBodyForce.h"

@class KSPPhysicsBody;

@interface KSPFGSphericalGravitySource : KSPFGUniversalBodyForce
{
    // the body that is the source of the gravitational field
    KSPPhysicsBody __weak * _source;
    
    // nominally the product of universal gravitational constant with the 
    // mass of the source
    double _strength;
}

@property (weak) KSPPhysicsBody * source;
@property (assign) double strength;

-(id)initWithSource:(KSPPhysicsBody*)source strength:(double)strength;

-(void)makeStrengthLikeRealGravity;

@end
