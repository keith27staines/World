//
//  KSPFGUniversalBodyForce.mm
//  World
//
//  Created by Keith Staines on 12/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPFGUniversalBodyForce.h"

@implementation KSPFGUniversalBodyForce

- (id)init 
{
    self = [super init];
    if (self) 
    {
        bodies = [NSMutableArray arrayWithCapacity:1024];
    }
    return self;
}

-(void)registerBody:(KSPPhysicsBody*)body
{
    [bodies addObject:body];
}

-(void)unregisterBody:(KSPPhysicsBody *)body
{
    [bodies removeObject:body];
}

-(KSMVector3)forceOnBody:(KSPPhysicsBody *)body overInterval:(double)dt
{
    // base class implementation returns zero force
    return KSMVector3();
}

// provide implementation for force due to gravity in a uniform gravitational
// field.
-(void)applyForceOverInterval:(double)dt
{
    for (KSPPhysicsBody * body in bodies) 
    {
        [body addForceThroughCMWithoutWaking:[self forceOnBody:body 
                                                  overInterval:dt]];
    }
}
@end
