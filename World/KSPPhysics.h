//
//  KSPPhysics.h
//  World
//
//  Created by Keith Staines on 08/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#ifndef World_KSPPhysics_h
#define World_KSPPhysics_h
#import "KSMMaths.h"
#import "KSPConstants.h"

#import "KSPPhysicsBody.h"

// Force registry
#import "KSPForceGeneratorRegistry.h"
#import "KSPForceGeneratorBase.h"

// "universal" forces (can be applied to multiple bodies)
#import "KSPFGUniversalBodyForce.h"
#import "KSPFGUniformGravity.h"
#import "KSPFGUniformDrag.h"

// forces affecting one body or two linked bodies
#import "KSPFGSpring.h"
#import "KSPFGAnchoredSpring.h"
#import "KSPFGConnectingSpring.h"
#import "KSPFGFloat.h"

// local environment, wind fields, water bodies, etc
#import "KSPWater.h"

// solar system
#import "KSPSolarSystemObject.h"

// body and material properties
#import "KSPMomentsOfInertia.h"

#endif
