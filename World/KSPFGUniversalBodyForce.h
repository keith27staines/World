//
//  KSPFGUniversalBodyForce.h
//  World
//
//  Created by Keith Staines on 12/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSPForceGeneratorBase.h"

@interface KSPFGUniversalBodyForce : KSPForceGeneratorBase
{
    NSMutableArray * bodies;
}

// registers the body so that if feels this body force
-(void)registerBody:(KSPPhysicsBody*)body;

// unregister the body so that it no longer feels the force
-(void)unregisterBody:(KSPPhysicsBody *)body;

// override this for subclasses
-(KSMVector3)forceOnBody:(KSPPhysicsBody*)body overInterval:(double)dt;

@end
